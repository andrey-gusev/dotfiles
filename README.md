# 🏠 Dotfiles

Добро пожаловать в проект dotfiles! Это коллекция моих конфигурационных файлов для **Arch Linux** (Wayland / Hyprland). Проект использует [chezmoi](https://www.chezmoi.io/) для управления конфигурациями и автоматического развёртывания рабочего окружения.

---

## ✨ Особенности

- **Управление через chezmoi**: конфигурации хранятся прозрачно и легко синхронизируются.
- **Автоматическая установка**: установка всех необходимых пакетов из официальных репозиториев и AUR одной командой.
- **Гибкая настройка**: возможность интерактивного выбора пакетов при установке через `fzf`.
- **Автоматизация сервисов**: автоматическое применение настроек `keyd` при изменении конфигурационного файла.

---

## 🚀 Установка

1. Установите `chezmoi` и `git`:

```bash
sudo pacman -S chezmoi git

```

1. Инициализируйте и примените конфигурацию:

```bash
chezmoi init --apply [https://github.com/andrey-gusev/dotfiles](https://github.com/andrey-gusev/dotfiles)

```

> 📌 **Примечание**: При первом запуске `chezmoi` склонирует репозиторий в `~/.local/share/chezmoi` и выполнит скрипт [`run_once_install.sh`](https://www.google.com/search?q=./run_once_install.sh) для установки программ и настройки окружения.

---

## 🧩 Структура проекта

```
.
├── dot_config/                 # Конфигурационные файлы (~/.config)
│   ├── foot/                   # Терминал Foot
│   ├── hypr/                   # Тайлинговый композитор Hyprland, hyprlock, hypridle
│   ├── keyd/                   # Переназначение клавиш (default.conf)
│   ├── lf/                     # Файловый менеджер LF и скрипты превью
│   ├── rofi/                   # Меню запуска приложений и powermenu
│   ├── shell/                  # Общие алиасы (aliasrc) и профиль
│   ├── waybar/                 # Статус-бар Waybar
│   ├── zsh/                    # Настройки Zsh (.zshrc)
│   └── ...                     # btop, mako, mpv, zathura, wal и др.
├── dot_local/                  # Пользовательские директории (~/.local)
│   ├── bin/                    # Скрипты (setbg, displayselect, record и др.)
│   └── share/applications/     # Ярлыки приложений (lf.desktop)
├── dot_zshenv                  # Глобальные переменные Zsh (~/.zshenv)
├── programs.txt                # Список программ для установки
├── run_once_install.sh         # Скрипт первичной установки системы
├── run_onchange_keyd.sh.tmpl   # Скрипт автоприменения конфигурации keyd
└── README.md

```

---

## ⚙️ Автоматизация и скрипты

### 📦 Первичная установка (`run_once_install.sh`)

При первом запуске скрипт автоматически:

- Проверяет систему (запуск только на Arch Linux и не под `root`).
- Устанавливает AUR-хелпер `yay` (если он отсутствует).
- Считывает список программ из `programs.txt` и предлагает выбрать их вручную через `fzf` (или установить всё).
- Включает и запускает системные службы (`keyd`, `bluetooth`, `NetworkManager`, `paccache.timer`).
- Переключает дефолтную оболочку на `zsh`.

### ⌨️ Настройка keyd (`run_onchange_keyd.sh.tmpl`)

Скрипт отслеживает изменения файла `dot_config/keyd/default.conf`. При его изменении `chezmoi` автоматически перезагружает сервис `keyd`.

---

## 🛠️ Использование

- **Редактирование конфигураций**:

```bash
chezmoi edit ~/.config/hypr/hyprland.lua

```

*(или с использованием алиасов `cfv` / `ca` из `shell/aliasrc`)*

- **Применение изменений**:

```bash
chezmoi apply

```

- **Просмотр разницы перед применением**:

```bash
chezmoi diff

```

---

## 💡 Полезные советы

- Регулярно обновляйте репозиторий с помощью `chezmoi update`.
- Чтобы добавить новую программу в автоустановку, внесите её в `programs.txt`.

---

## 🔗 Лицензия

Проект распространяется под [MIT License](https://www.google.com/search?q=LICENSE) © [andrey-gusev](https://github.com/andrey-gusev/).
