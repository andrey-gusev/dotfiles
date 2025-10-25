#!/usr/bin/env bash
set -e

# Цвета для красивого вывода
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RED="\033[1;31m"
RESET="\033[0m"

CSV_FILE="$HOME/.local/share/chezmoi/programms.csv"

# Проверка существования CSV
if [[ ! -f "$CSV_FILE" ]]; then
    echo -e "${RED}❌ Не найден файл с программами: $CSV_FILE${RESET}"
    exit 1
fi

echo -e "${BLUE}🚀 Начинаем установку необходимых пакетов...${RESET}"

# Проверяем наличие yay
if ! command -v yay &>/dev/null; then
    echo -e "${YELLOW}⚙️  yay не найден. Устанавливаем...${RESET}"
    sudo pacman -S --needed --noconfirm git base-devel
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmpdir"
    cd "$tmpdir"
    makepkg -si --noconfirm
    cd -
    rm -rf "$tmpdir"
    echo -e "${GREEN}✅ yay установлен!${RESET}"
else
    echo -e "${GREEN}✅ yay уже установлен.${RESET}"
fi

# Установка пакетов из CSV
while IFS=',' read -r type package description; do
    # Пропускаем пустые строки и комментарии
    [[ -z "$package" || "$package" =~ ^# ]] && continue

    if [[ "$type" == "A" ]]; then
        echo -e "${BLUE}📦 Устанавливаем AUR-пакет:${RESET} ${YELLOW}$package${RESET} — $description"
        yay -S --noconfirm --needed "$package"
    else
        echo -e "${BLUE}📦 Устанавливаем пакет:${RESET} ${YELLOW}$package${RESET} — $description"
        sudo pacman -S --noconfirm --needed "$package"
    fi
done < "$CSV_FILE"

echo -e "\n${GREEN}🎉 Установка завершена! Все пакеты из списка установлены.${RESET}"

