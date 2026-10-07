#!/usr/bin/env zsh 


# ┌────────────────────────────────────────────┐
# │ Terminal Text Banner Animation Function    │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Bounce                      │
# └────────────────────────────────────────────┘

text_bounce() {
    local msg="$1"
    tput civis
    for i in {1..3}; do
        printf "\r %s" "$msg"; sleep 0.1
        printf "\r%s " "$msg"; sleep 0.1
    done
    printf "\r\e[1;36m%s\e[0m\n" "$msg"
    tput cnorm
}
