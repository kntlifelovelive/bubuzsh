#!/usr/bin/env zsh 


# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : RainBow                     │
# └────────────────────────────────────────────┘

header_rainbow() {
    local lines=("${(@f)1}")
    local colors=("\e[1;31m" "\e[1;33m" "\e[1;32m" "\e[1;36m" "\e[1;34m" "\e[1;35m")
    tput civis
    for r in {1..10}; do
        printf "\033[H\033[J"
        for i in {1..${#lines[@]}}; do
            local c_idx=$(( (i + r) % ${#colors[@]} + 1 ))
            printf "${colors[$c_idx]}%s\e[0m\n" "${lines[$i]}"
        done
        sleep 0.08
    done
    printf "\033[H\033[J\e[1;35m%s\e[0m\n" "$1"
    tput cnorm
}
