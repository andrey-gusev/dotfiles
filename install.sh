#!/bin/bash
# GARBS by Andrey Gusev
# License: GNU GPLv3
set -euo pipefail

### CONFIGURATION ###
dotfilesrepo="https://github.com/andrey-gusev/dotfiles.git"
repobranch="main"
progsfile="https://raw.githubusercontent.com/andrey-gusev/dotfiles/progs.csv"
aurhelper="yay"
logfile="/tmp/install_errors.log"

### FUNCTIONS ###
check_internet() {
    echo "Checking internet connection..."
    if ! ping -c 1 8.8.8.8 &>/dev/null; then
        echo "No internet connection. Please check your network!" >>"$logfile"
        exit 1
    fi
}

installpkg() {
    echo "Installing $1 via pacman..."
    pacman --noconfirm --needed -S "$1" 2>>"$logfile" || { echo "Failed to install $1 via pacman" >>"$logfile"; exit 1; }
}

install_build_tools() {
    echo "Installing build dependencies..."
    for pkg in base-devel; do installpkg "$pkg"; done
}

aurinstall() {
    pacman -Qq "$1" &>/dev/null && { echo "$1 is already installed, skipping..." >>"$logfile"; return 0; }
    echo "Installing $1 via $aurhelper..."
    sudo -u "$name" $aurhelper -S --noconfirm "$1" 2>>"$logfile" || { echo "Failed to install $1 from AUR" >>"$logfile"; exit 1; }
}

gitmakeinstall() {
    progname="${1##*/}"
    progname="${progname%.git}"
    dir="$repodir/$progname"
    echo "Cloning and installing $progname from $1..."
    if [ -d "$dir" ]; then
        echo "Updating $progname in $dir..."
        (cd "$dir" && sudo -u "$name" git pull --force 2>>"$logfile") || { echo "Failed to update $1 in $dir" >>"$logfile"; exit 1; }
    else
        sudo -u "$name" git clone --depth 1 "$1" "$dir" 2>>"$logfile" || { echo "Failed to clone $1 to $dir" >>"$logfile"; exit 1; }
    fi
    cd "$dir" || { echo "Failed to enter $dir" >>"$logfile"; exit 1; }
    make 2>>"$logfile" && make install 2>>"$logfile" || { echo "Failed to build/install $progname" >>"$logfile"; exit 1; }
}

pipinstall() {
    command -v pip >/dev/null || { echo "Installing python-pip..."; installpkg python-pip; }
    echo "Installing $1 via pip..."
    yes | pip install "$1" 2>>"$logfile" || { echo "Failed to install $1 via pip" >>"$logfile"; exit 1; }
}

installationloop() {
    echo "Choose source for progs.csv:"
    read -p "Enter URL or path to CSV (leave empty to use default): " csv_source
    csv_source="${csv_source:-$progsfile}"

    if [[ "$csv_source" =~ ^https?:// ]]; then
        echo "Downloading progs.csv from $csv_source..."
        curl -Ls "$csv_source" -o /tmp/progs.csv || { echo "Failed to download CSV" >>"$logfile"; exit 1; }
    else
        echo "Using local CSV: $csv_source"
        cp "$csv_source" /tmp/progs.csv || { echo "Failed to copy CSV" >>"$logfile"; exit 1; }
    fi

    while IFS=, read -r tag program comment; do
        program="${program//\"/}"
        echo "Processing $program..."
        case "$tag" in
            A) aurinstall "$program" ;;
            G) gitmakeinstall "$program" ;;
            P) pipinstall "$program" ;;
            *) installpkg "$program" ;;
        esac
    done </tmp/progs.csv
}

putgitrepo() {
    dir=$(mktemp -d)
    mkdir -p "$2" || { echo "Failed to create directory $2" >>"$logfile"; exit 1; }
    chown "$name":wheel "$dir" "$2"
    echo "Cloning dotfiles from $1..."
    sudo -u "$name" git clone --depth 1 -b "$repobranch" "$1" "$dir" 2>>"$logfile" || { echo "Failed to clone dotfiles from $1" >>"$logfile"; exit 1; }
    sudo -u "$name" cp -rfT "$dir" "$2" 2>>"$logfile" || { echo "Failed to copy dotfiles to $2" >>"$logfile"; exit 1; }
    rm -rf "$dir/.git"
}

usercheck() {
    if id -u "$name" >/dev/null 2>&1; then
        whiptail --title "WARNING" --yes-button "CONTINUE" \
            --no-button "Cancel" \
            --yesno "The user \`$name\` already exists. GARBS will overwrite dotfiles/settings, but not personal files (Documents, Videos, etc.). Continue?" 14 70 || {
                echo "Installation aborted by user."
                exit 1
            }
    fi
}

### MAIN SCRIPT ###
[ "$EUID" -ne 0 ] && { echo "Run as root!" >>"$logfile"; exit 1; }

check_internet

# Имя пользователя
read -p "Enter username to install for: " name

# Проверка существующего пользователя
usercheck

# Создаём пользователя, если он не существует
if ! id -u "$name" >/dev/null 2>&1; then
    echo "Creating user $name..."
    useradd -m -G wheel -s /bin/zsh "$name" || { echo "Failed to create user $name" >>"$logfile"; exit 1; }
    echo "Setting password for $name..."
    passwd "$name" || { echo "Failed to set password for $name" >>"$logfile"; exit 1; }
fi

repodir="/home/$name/.local/src"
mkdir -p "$repodir" || { echo "Failed to create $repodir" >>"$logfile"; exit 1; }

install_build_tools

# Установка AUR-хелпера
aurinstall "$aurhelper"

# Установка всех программ из CSV
installationloop

# Установка dotfiles
putgitrepo "$dotfilesrepo" "/home/$name"

# Установка zsh по умолчанию
chsh -s /bin/zsh "$name" || { echo "Failed to set zsh as default shell for $name" >>"$logfile"; exit 1; }

echo "Installation complete! Check $logfile for any errors. Log in as $name and enjoy your environment."
