#!/usr/bin/env zsh 


# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Cycle                       │
# └────────────────────────────────────────────┘

header_cycle() {
    local colors=("\e[1;31m" "\e[1;32m" "\e[1;33m" "\e[1;34m" "\e[1;35m" "\e[1;36m")
    for col in "${colors[@]}"; do
        printf "\033[H\033[J${col}%s\e[0m\n" "$1"
        sleep 0.1
    done
}
