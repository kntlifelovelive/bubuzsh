#!/usr/bin/env zsh 


# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : SlideUp                     │
# └────────────────────────────────────────────┘


header_slide_up() {
    tput civis
    for i in {4..0}; do
        printf "\033[H\033[J"
        for k in $(seq 1 $i); do echo ""; done
        printf "\e[1;32m%s\e[0m\n" "$1"
        sleep 0.08
    done
    tput cnorm
}
