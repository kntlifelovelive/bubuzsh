#!/usr/bin/env zsh


# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Mirror                      │
# └────────────────────────────────────────────┘

header_mirror() {
    local lines=("${(@f)1}")
    local n=${#lines[@]}
    local half=$(( (n + 1) / 2 ))
    tput civis
    for i in {1..$half}; do
        printf "\033[H"
        for j in {1..$n}; do
            [[ $j -le $i || $j -ge $((n-i+1)) ]] && printf "\e[1;34m%s\e[0m\n" "${lines[$j]}" || echo ""
        done
        sleep 0.15
    done
    printf "\033[H\033[J\e[1;34m%s\e[0m\n" "$1"
    tput cnorm
}
