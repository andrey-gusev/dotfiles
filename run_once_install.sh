#!/usr/bin/env bash

set -euo pipefail

CSV_FILE="$HOME/.local/share/chezmoi/programs.csv"
SHELL="/usr/bin/fish"

csvfilecheck() {
    if [[ ! -f "$CSV_FILE" ]]; then
        echo "❌ Не найден файл с программами: $CSV_FILE"
        exit 1
    fi
}

check_yay() {
    if command -v yay >/dev/null 2>&1; then
        return
    fi

    echo "📦 Установка yay..."

    sudo pacman -S --needed --noconfirm git base-devel

    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmpdir" || exit 1

    pushd "$tmpdir" >/dev/null
    makepkg -si --noconfirm
    popd >/dev/null

    rm -rf "$tmpdir"

    command -v yay >/dev/null 2>&1 || {
        echo "❌ Ошибка установки yay"
        exit 1
    }
}

is_installed() {
    local pkg="$1"
    pacman -Q "$pkg" >/dev/null 2>&1
}

installation_loop() {
    while IFS=',' read -r type package; do
        package="${package%%#*}"
        package="$(echo "$package" | xargs)"

        [[ -z "$package" ]] && continue

        if is_installed "$package"; then
            continue
        fi

        if [[ "$type" == "A" ]]; then
            echo "📦 Установка AUR пакета: $package"
            yay -S --noconfirm --needed "$package" || \
                echo "⚠ Ошибка установки AUR: $package"
        else
            echo "📦 Установка пакетa: $package"
            sudo pacman -S --noconfirm --needed "$package" || \
                echo "⚠ Ошибка установки: $package"
        fi

    done < "$CSV_FILE"
}

change_shell() {
    local current
    current=$(getent passwd "$USER" | cut -d: -f7)

    [[ "$current" == "$SHELL" ]] && return

    if command -v chsh >/dev/null 2>&1; then
        echo "🔄 Изменение shell на fish..."
        chsh -s "$SHELL" || \
            echo "⚠ Не удалось изменить shell"
    fi
}

main() {
    if [[ $EUID -eq 0 ]]; then
        echo "❌ Не запускай этот скрипт от root"
        exit 1
    fi

    csvfilecheck
    check_yay
    installation_loop
    change_shell

    echo "✅ Все пакеты обработаны. Система готова."
}

main "$@"
