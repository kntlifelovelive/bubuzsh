# ~/.config/zsh/modules/zoxide.zsh
# Zoxide (smarter cd) configuration

if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi
