set -gx EDITOR nvim
set -gx TERMINAL foot
set -gx BROWSER qutebrowser
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XAUTHORITY /tmp/Xauthority
set -gx PASSWORD_STORE_DIR "$XDG_DATA_HOME/password-store"
fish_add_path $HOME/.local/bin
