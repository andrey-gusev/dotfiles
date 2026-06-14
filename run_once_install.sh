#!/usr/bin/env bash

set -euo pipefail

CSV_FILE="$HOME/.local/share/chezmoi/programs.csv"
SHELL="/usr/bin/zsh"

# Переменная для хранения PID фонового процесса обновления sudo
SUDO_PID=""

# Функция для очистки фоновых процессов при выходе из скрипта
cleanup() {
    if [[ -n "$SUDO_PID" ]]; then
        kill "$SUDO_PID" >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT INT TERM

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
            # yay сам подхватит уже активный sudo-токен
            yay -S --noconfirm --needed "$package" ||
                echo "⚠ Ошибка установки AUR: $package"
        else
            echo "📦 Установка пакетa: $package"
            sudo pacman -S --noconfirm --needed "$package" ||
                echo "⚠ Ошибка установки: $package"
        fi

    done <"$CSV_FILE"
}

change_shell() {
    local current
    current=$(getent passwd "$USER" | cut -d: -f7)

    [[ "$current" == "$SHELL" ]] && return

    if command -v chsh >/dev/null 2>&1; then
        echo "🔄 Изменение shell"
        # Передаем sudo, так как chsh часто требует пароль для не-интерактивной смены
        sudo chsh -s "$SHELL" "$USER" ||
            echo "⚠ Не удалось изменить shell"
    fi
}

main() {
    if [[ $EUID -eq 0 ]]; then
        echo "❌ Не запускай этот скрипт от root"
        exit 1
    fi

    csvfilecheck

    # --- МАГИЯ SUDO НАЧИНАЕТСЯ ТУТ ---
    echo "🔐 Для установки программ необходимы права sudo."
    # Запрашиваем пароль один раз. Если пароль неверный — скрипт упадет благодаря set -e
    sudo -v

    # Запускаем фоновый процесс, который каждые 60 секунд обновляет тайм-аут sudo,
    # пока работает основной скрипт.
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
    SUDO_PID=$!
    # --- МАГИЯ SUDO ЗАКАНЧИВАЕТСЯ ТУТ ---

    check_yay
    installation_loop
    change_shell

    echo "✅ Все пакеты обработаны. Система готова."
}

main "$@"
