#!/usr/bin/env zsh

# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : SlideIn                     │
# └────────────────────────────────────────────┘


header_slide_in() {
    local lines=("${(@f)1}")
    tput civis
    for i in {15..0..-3}; do
        printf "\033[H\033[J"
        for line in "${lines[@]}"; do
            printf "%*s\e[1;35m%s\e[0m\n" $i "" "$line"
        done
        sleep 0.04
    done
    tput cnorm
}
