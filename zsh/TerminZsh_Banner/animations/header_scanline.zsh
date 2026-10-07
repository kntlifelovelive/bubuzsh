#!/usr/bin/env zsh


# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Scanline                    │
# └────────────────────────────────────────────┘

header_scanline() {
    local lines=("${(@f)1}")
    tput civis
    for i in {1..${#lines[@]}}; do
        printf "\033[H\033[J"
        for j in {1..${#lines[@]}}; do
            [[ $i -eq $j ]] && printf "\e[1;97m%s\e[0m\n" "${lines[$j]}" || printf "\e[2;35m%s\e[0m\n" "${lines[$j]}"
        done
        sleep 0.15
    done
    printf "\033[H\033[J\e[1;35m%s\e[0m\n" "$1"
    tput cnorm
}
