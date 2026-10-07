#!/usr/bin/env zsh 


# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Expand                      │
# └────────────────────────────────────────────┘

header_expand() {
    local lines=("${(@f)1}")
    tput civis
    for i in {1..15}; do
        printf "\033[H\033[J"
        for line in "${lines[@]}"; do
            local len=${#line}
            local lp="${line[1,$i]}"
            local rp="${line[$((len-i+1)),$len]}"
            printf "\e[1;33m%s%*s%s\e[0m\n" "$lp" $((len - i*2)) "" "$rp"
        done
        sleep 0.05
    done
    printf "\033[H\033[J\e[1;33m%s\e[0m\n" "$1"
    tput cnorm
}
