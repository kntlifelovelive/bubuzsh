#!/usr/bin/env zsh 

# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Wave                        │
# └────────────────────────────────────────────┘

header_wave() {
    local lines=("${(@f)1}")
    tput civis
    for i in {1..10}; do
        printf "\033[H\033[J"
        local shift=$(( (i % 6) ))
        [[ $shift -gt 3 ]] && shift=$(( 6 - shift ))
        for line in "${lines[@]}"; do
            printf "%*s\e[1;36m%s\e[0m\n" $shift "" "$line"
        done
        sleep 0.08
    done
    printf "\033[H\033[J\e[1;36m%s\e[0m\n" "$1"
    tput cnorm
}
