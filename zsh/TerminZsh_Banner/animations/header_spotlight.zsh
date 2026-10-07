#!/usr/bin/env zsh 


# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : SpotLight                   │
# └────────────────────────────────────────────┘


header_spotlight() {
    local lines=("${(@f)1}")
    tput civis
    for i in {1..2}; do
        for line in "${lines[@]}"; do
            printf "\e[2;37m%s\e[0m\r" "$line"
            sleep 0.04
            printf "\e[1;37m%s\e[0m\n" "$line"
        done
        printf "\033[${#lines[@]}A"
    done
    printf "\033[H\033[J\e[1;35m%s\e[0m\n" "$1"
    tput cnorm
}

