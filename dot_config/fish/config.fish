fish_vi_key_bindings
function fish_mode_prompt; end
set fish_greeting ""

if status is-interactive
    source ~/.config/fish/env.fish
    source ~/.config/fish/aliases.fish
    source ~/.config/fish/binds.fish
end

if status is-login
and test -z "$DISPLAY"
and test "$XDG_VTNR" = "1"
    exec start-hyprland
end

