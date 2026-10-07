#!/usr/bin/env zsh


# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Fade                        │
# └────────────────────────────────────────────┘

header_fade() {
    local colors=("\e[2;35m" "\e[0;35m" "\e[1;35m" "\e[1;95m")
    tput civis
    for col in "${colors[@]}"; do
        printf "\033[H\033[J"
        printf "${col}%s\e[0m\n" "$1"
        sleep 0.15
    done
    tput cnorm
}

