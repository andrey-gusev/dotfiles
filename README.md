# 🏠 My Dotfiles

Мои персональные конфигурационные файлы и установочный скрипт для Arch Linux.  
Проект построен с помощью [chezmoi](https://www.chezmoi.io/) для простого развёртывания конфигов и автоматической установки программ.

---

## 🚀 Установка

1. **Установить chezmoi**
```bash
sudo pacman -S chezmoi
```

2. **Инициализировать конфигурацию**

```bash
chezmoi init --apply git@github.com:andrey-gusev/dotfiles.git
```

   > ⚙️ При первом запуске `chezmoi` автоматически выполнит скрипт [`run_once_install.sh`](./run_once_install.sh), который установит все необходимые пакеты.

---

## 🧩 Структура

```
.
├── dot_config/             
│   ├── nvim/               
│   ├── fish/               
│   └── ...
├── programms.csv           
├── run_once_install.sh     
├── .chezmoi.toml.tmpl      
└── README.md               
```

---

## 📦 Установочные пакеты

Файл [`programms.csv`](./programms.csv) содержит список всех программ для установки.
Формат:

```csv
# тип,пакет,описание
,neovim,Современный текстовый редактор
A,brave-bin,Браузер Brave (AUR)
```

* `тип` — пустой для обычных пакетов из `pacman`, `A` для пакетов из AUR.
* `пакет` — имя пакета.
* `описание` — комментарий (для читаемости).

---

## ⚙️ Автоматическая установка пакетов

Скрипт [`run_once_install.sh`](./run_once_install.sh):

1. Проверяет наличие `yay` и устанавливает его при необходимости.
2. Считывает список пакетов из `programms.csv`.
3. Устанавливает их через `pacman` или `yay`.
4. Пропускает уже установленные программы.

---

## 🧠 Примечания

* Все файлы в `dot_config` и других директориях автоматически копируются или линкуются в `$HOME` при `chezmoi apply`.
* Файлы, не предназначенные для копирования в домашнюю директорию (например, `README.md` и `programms.csv`), указаны в `.chezmoiignore`.

---

## ❤️ Благодарности

* [chezmoi](https://www.chezmoi.io/) — инструмент для управления dotfiles.
* [Arch Linux](https://archlinux.org/) — за чистоту и контроль над системой.

---

## 🔗 Лицензия

MIT License © [andrey-gusev](https://github.com/andrey-gusev/)
