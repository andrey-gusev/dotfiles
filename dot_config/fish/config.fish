fish_vi_key_bindings
function fish_mode_prompt; end
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

bind -M insert alt-l accept-autosuggestion 
bind -M insert ctrl-l forward-word

if test -z $DISPLAY; and test $XDG_VTNR -eq 1
    exec Hyprland
end

# abbr -a --position anywhere -- --help '--help | bat -plhelp'
# abbr -a --position anywhere -- -h '-h | bat -plhelp'
# abbr cat "bat"
abbr c "clear"
abbr ca "chezmoi apply" 
abbr cdc "cd ~/.local/share/chezmoi/"
abbr cf "chezmoi edit ~/.config/"
abbr cff "chezmoi edit ~/.config/fish/config.fish"
abbr cfh "chezmoi edit ~/.config/hypr/hyprland.conf"
abbr cft "chezmoi edit ~/.config/foot/foot.ini"
abbr cfv "chezmoi edit ~/.config/nvim/init.vim"
abbr cfw "chezmoi edit ~/.config/waybar/config"
abbr cfws "chezmoi edit ~/.config/waybar/style.css"
abbr e "emacs"
abbr g "git"
abbr ga "git add"
abbr gc "git commit -m"
abbr gd "git diff"
abbr gp "git push"
abbr gr "git remote set-url origin git@github.com:andrey-gusev/"
abbr gs "git status"
abbr man "batman"
abbr p "sudo pacman"
abbr sc "chezmoi edit ~/.local/bin/"
abbr sdn "shutdown now"
abbr sys "sudo systemctl"
abbr t "sudo tailscale"
abbr v "nvim"
abbr y "yay"
