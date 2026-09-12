#!/usr/bin/env bash

set -Eeuo pipefail

LIST_FILE="$HOME/.local/share/chezmoi/programs.txt"
INTERACTIVE_MODE=false

if [[ $EUID -eq 0 ]]; then
  echo "ERROR: Do not run this script as root." >&2
  exit 1
fi

# Prompt user for interactive mode
prompt_interactive_mode() {
  echo "Do you want to interactively select packages via fzf? [y/N]: "
  read -r -n 1 response || response="n"
  echo ""

  if [[ "$response" =~ ^[Yy]$ ]]; then
    INTERACTIVE_MODE=true
  fi
}

# Check if the programs list file exists
check_list_file() {
  if [[ ! -f "$LIST_FILE" ]]; then
    echo "ERROR: Programs file not found: $LIST_FILE" >&2
    exit 1
  fi
}

# Verify system
check_arch_system() {
  if command -v pacman >/dev/null 2>&1; then
    return 0
  else
    echo "ERROR: Other systems besides Arch are not supported! I use Arch btw :)" >&2
    return 1
  fi
}

# Check and install yay (AUR helper) if not present
check_yay() {
  if command -v yay >/dev/null 2>&1; then
    return 0
  fi

  echo "Installing yay (AUR helper)..."
  sudo pacman -S --needed --noconfirm git base-devel

  local tmpdir
  tmpdir=$(mktemp -d)

  git clone https://aur.archlinux.org/yay.git "$tmpdir"

  pushd "$tmpdir" >/dev/null
  makepkg -si --noconfirm
  popd >/dev/null

  rm -rf "$tmpdir"

  command -v yay >/dev/null 2>&1 || {
    echo "ERROR: Failed to install yay" >&2
    exit 1
  }
}

select_packages_interactively() {
  local -n all_pkgs="$1"
  local selected_pkgs=()

  # Install fzf first if missing
  if ! command -v fzf >/dev/null 2>&1; then
    echo "Installing fzf for interactive mode..."
    yay -S --needed --noconfirm fzf
  fi

  echo "Opening package selection menu..."

  mapfile -t selected_pkgs < <(
    printf '%s\n' "${all_pkgs[@]}" | fzf \
      --multi \
      --bind="space:toggle+down,ctrl-a:select-all,ctrl-d:deselect-all,ctrl-r:toggle-all" \
      --header="[TAB/Space]: Select | [Ctrl+A]: Select All | [Ctrl+D]: Deselect All | [Ctrl+R]: Invert Selection | [ENTER]: Confirm" \
      --prompt="Select packages to install > "
  )

  if [[ ${#selected_pkgs[@]} -eq 0 ]]; then
    echo "INFO: No packages selected. Exiting."
    exit 0
  fi

  all_pkgs=("${selected_pkgs[@]}")
}

# Parse package list and run installer
install_packages() {
  local packages=()

  echo "Reading package list from $LIST_FILE..."

  # Read file line by line, skipping comments (#) and blank lines
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Trim leading/trailing whitespace
    line=$(echo "$line" | xargs)
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    packages+=("$line")
  done <"$LIST_FILE"

  if [[ ${#packages[@]} -eq 0 ]]; then
    echo "INFO: No packages found for installation."
    return 0
  fi

  if [[ "$INTERACTIVE_MODE" == true ]]; then
    select_packages_interactively packages
  fi

  echo "Found ${#packages[@]} packages to install."
  echo "Starting installation..."
  if yay -S --needed --noconfirm "${packages[@]}"; then
    echo "SUCCESS: Installation completed successfully!"
  else
    echo "ERROR: Package installation failed." >&2
    return 1
  fi
}

enable_daemons() {
  local services=(
    "keyd.service"
    "bluetooth.service"
    "NetworkManager.service"
    "paccache.timer"
  )

  echo "Checking system daemons..."

  for service in "${services[@]}"; do
    if systemctl is-enabled --quiet "$service" 2>/dev/null && systemctl is-active --quiet "$service" 2>/dev/null; then
      echo "INFO: $service is already running."
    else
      echo "Enabling and starting $service..."
      if sudo systemctl enable --now "$service"; then
        echo "SUCCESS: $service has been started!"
      else
        echo "ERROR: Failed to start $service" >&2
      fi
    fi
  done
}

change_shell() {
  # Check if zsh is installed
  if ! command -v zsh >/dev/null 2>&1; then
    echo "ERROR: zsh is not installed. Skipping shell change." >&2
    return 1
  fi

  local target_shell
  target_shell="$(command -v zsh)"

  # Check if zsh is already the default shell for the current user
  if [[ "$SHELL" == "$target_shell" ]]; then
    echo "INFO: Default shell is already set to zsh."
    return 0
  fi

  echo "Changing default shell to zsh ($target_shell)..."

  # Ensure target_shell is listed in /etc/shells
  if ! grep -qxF "$target_shell" /etc/shells 2>/dev/null; then
    echo "Adding $target_shell to /etc/shells..."
    echo "$target_shell" | sudo tee -a /etc/shells >/dev/null
  fi

  # Change the shell for the current user
  if chsh -s "$target_shell" "$USER"; then
    echo "SUCCESS: Default shell changed to zsh. Log out and back in for changes to take effect."
  else
    echo "ERROR: Failed to change default shell." >&2
    return 1
  fi
}

check_wal_cache() {
  if [ ! -d "$HOME/.cache/wal" ]; then
    setbg
  fi
}

main() {
  check_list_file
  check_arch_system
  check_yay
  prompt_interactive_mode
  install_packages
  enable_daemons
  change_shell
  check_wal_cache
}

main "$@"
