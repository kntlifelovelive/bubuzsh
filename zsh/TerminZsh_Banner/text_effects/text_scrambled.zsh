#!/usr/bin/env zsh 


# ┌────────────────────────────────────────────┐
# │ Terminal Text Banner Animation Function    │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Scrambled                   │
# └────────────────────────────────────────────┘


text_scrambled() {
    local msg="$1"; local chars="!@#$%^&*"
    for r in {1..8}; do
        local out=""
        for ((i=0; i<${#msg}; i++)); do
            (( RANDOM % 5 < 2 )) && out+="${chars[$((RANDOM%${#chars}+1))]}" || out+="${msg:$i:1}"
        done
        printf "\r\033[1;37m%s\e[0m" "$out"; sleep 0.08
    done
    printf "\r\033[1;36m%s\e[0m\n" "$msg"
}
