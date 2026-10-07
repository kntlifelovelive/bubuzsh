#!/usr/bin/env zsh


# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Typing                      │
# └────────────────────────────────────────────┘

header_typing() {
    local banner="$1"
    tput civis; printf "\033[H\033[J"
    for ((i=1; i<=${#banner}; i++)); do
        printf "\e[1;35m%s\e[0m" "${banner:$i-1:1}"
        [[ $((i % 15)) -eq 0 ]] && sleep 0.01
    done
    printf "\n"
    tput cnorm
}
