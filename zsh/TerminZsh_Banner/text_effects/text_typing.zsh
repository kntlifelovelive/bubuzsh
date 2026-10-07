#!/usr/bin/env zsh

# ┌────────────────────────────────────────────┐
# │ Terminal Text Banner Animation Function    │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Typin                       │
# └────────────────────────────────────────────┘


text_typing() {
    local msg="$1"
    tput civis
    for ((i=0;i<${#msg};i++)); do
        printf "\e[1;36m%s\e[0m" "${msg:$i:1}"
        sleep 0.01
    done
    echo; tput cnorm
}
