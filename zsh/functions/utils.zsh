# ~/.config/zsh/functions/utils.zsh

print_banner() {
    local cols=$(tput cols 2>/dev/null || echo 80)
    
    # Only show full banner if terminal is wide enough
    if [[ $cols -ge 80 ]]; then
        printf "\e[0m\e[1;36m🌺 Trust your heart if the sea catch fire,\e[0m\e[5m\e[1;31mlive\e[0m\e[1;36m by \e[0m\e[5m\e[1;32mlove\e[0m\e[1;36m though the stars walk backwack. 🌸🌾 \e[25m\e[0m\n"
    else
        # Small banner or nothing
        printf "\e[0;36m🌺 $(date +%H:%M) 🌾\e[0m\n"
    fi
}

function clear {
    command clear
    print_banner
}
