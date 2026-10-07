#!/usr/bin/env zsh

# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Zoom                        │
# └────────────────────────────────────────────┘
header_zoom() {
    local lines=("${(@f)1}")
    tput civis
    for i in {1..15}; do
        printf "\033[H\033[J"
        for line in "${lines[@]}"; do
            local len=${#line}
            local width=$((i * 6))
            local start=$(((len - width) / 2))
            [[ $start -lt 0 ]] && start=0
            printf "\e[1;35m%s\e[0m\n" "${line:$start:$width}"
        done
        sleep 0.04
    done
    tput cnorm
}
