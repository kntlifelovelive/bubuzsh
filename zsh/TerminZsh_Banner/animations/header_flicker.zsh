#!/usr/bin/env zsh 


# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Flicker                     │
# └────────────────────────────────────────────┘


header_flicker() {
    for i in {1..10}; do
        printf "\033[H\033[J"
        [[ $((RANDOM % 2)) -eq 0 ]] && printf "\e[1;35m%s\e[0m\n" "$1"
        sleep 0.08
    done
    printf "\033[H\033[J\e[1;35m%s\e[0m\n" "$1"
}
