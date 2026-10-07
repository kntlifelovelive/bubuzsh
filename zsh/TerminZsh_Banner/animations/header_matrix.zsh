#!/usr/bin/env zsh


# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Matrix                      │
# └────────────────────────────────────────────┘

header_matrix() {
    local banner="$1"
    local chars="!@#$%^&*()_+"
    tput civis
    for i in {1..7}; do
        printf "\033[H\033[J"
        echo "$banner" | while read -r line; do
            local nl=""
            for ((j=0; j<${#line}; j++)); do
                (( RANDOM % 10 < 2 )) && nl+="${chars[$((RANDOM%${#chars}+1))]}" || nl+="${line:$j:1}"
            done
            printf "\e[1;32m%s\e[0m\n" "$nl"
        done
        sleep 0.06
    done
    printf "\033[H\033[J\e[1;35m%s\e[0m\n" "$banner"
    tput cnorm
}
