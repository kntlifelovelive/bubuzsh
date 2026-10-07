#!/usr/bin/env zsh


# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Bounce                      │
# └────────────────────────────────────────────┘

header_bounce() {
    tput civis
    for i in {4..0}; do
        printf "\033[H\033[J"
        for j in $(seq 1 $i); do echo ""; done
        printf "\e[1;35m%s\e[0m\n" "$1"
        sleep 0.06
    done
    tput cnorm
}

