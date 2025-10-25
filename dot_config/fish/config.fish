if status is-interactive
    fish_vi_key_bindings
    set fish_greeting ""
    set -gx EDITOR nvim
    set -gx TERMINAL foot
    set -gx BROWSER qutebrowser
    set -gx XDG_CONFIG_HOME $HOME/.config
    set -gx XDG_DATA_HOME $HOME/.local/share
    set -gx XDG_CACHE_HOME $HOME/.cache
    set -gx XAUTHORITY /tmp/Xauthority
    set -gx PASSWORD_STORE_DIR "$XDG_DATA_HOME/password-store"
    set -gx PATH $PATH $HOME/.local/bin
    set -gx PATH $PATH $HOME/.config/emacs/bin

    if test -z $DISPLAY; and test $XDG_VTNR -eq 1
        exec Hyprland
    end

    abbr p "sudo pacman"
    abbr v "nvim"
    abbr sdn "shutdown now"
    abbr sys "sudo systemctl"
    abbr g "git"
    abbr t "tailscale"
    abbr e "emacs"
    abbr y "yay"
    abbr cf "chezmoi edit ~/.config/"
    abbr sc "chezmoi edit ~/.local/bin/"
    abbr ca "chezmoi apply" 
    abbr cfh "chezmoi edit ~/.config/hypr/hyprland.conf"
    abbr cfv "chezmoi edit ~/.config/nvim/init.vim"
    abbr cfk "chezmoi edit ~/.config/kitty/kitty.conf"
    abbr cff "chezmoi edit ~/.config/fish/config.fish"
    abbr cfw "chezmoi edit ~/.config/waybar/config"
end
