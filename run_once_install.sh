#!/usr/bin/env bash

set -e
export TERM=ansi

CSV_FILE="programs.csv"

welcomemsg() {
	whiptail --title "Добро пожаловать!" \
        --msgbox "Добро пожаловать! Этот скрипт установит все необходимые программы." 10 60
}

csvfilecheck() {
    if [[ ! -f "$CSV_FILE" ]]; then
        whiptail --title "Ошибка" --msgbox "Не найден файл с программами: $CSV_FILE" 8 60
        exit 1
    fi
}

check_newt() {
    if ! is_installed libnewt &> /dev/null; then
        sudo pacman -S --noconfirm newt &> /dev/null
    fi
}

check_yay() {
    if ! command -v yay &>/dev/null; then
        whiptail --title "Установка AUR" --infobox "Устанавливаем AUR..." 5 60
        sudo pacman -S --needed --noconfirm git base-devel &> /dev/null
        tmpdir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$tmpdir" &> /dev/null
        cd "$tmpdir"
        makepkg -si --noconfirm &> /dev/null
        cd -
        rm -rf "$tmpdir"
        whiptail --title "Установка AUR" --infobox "AUR установлен!" 5 60
    fi
}

is_installed() {
    local pkg="$1"
    pacman -Q "$pkg" &> /dev/null
}

installation_loop() {
    while IFS=',' read -r type package description; do
        [[ -z "$package" || "$package" =~ ^# ]] && continue
        if is_installed "$package"; then
            continue
        elif [[ "$type" == "A" ]]; then
             whiptail --title "Установка..." \
                 --infobox "Устанавливаем $package\\n\\n$description" 10 60
        yay -S --noconfirm --needed "$package" &> /dev/null
        else
         whiptail --title "Установка..." \
             --infobox "Устанавливаем $package\\n\\n$description" 10 60
        sudo pacman -S --noconfirm --needed "$package" &> /dev/null
        fi
    done < "$CSV_FILE"
}

finalize() {
    whiptail --title "Готово!" --msgbox \
    "Поздравляю! Все пакеты из списка установлены.\\n\\nМожно пользоваться системой!" 10 80
}

welcomemsg
csvfilecheck
check_newt
check_yay
installation_loop
finalize
