#!/usr/bin/env zsh 


# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Static                      │
# └────────────────────────────────────────────┘


header_static() {
    for i in {1..8}; do
        printf "\033[H\033[J"
        echo "$1" | tr '[:graph:]' '?' | tr '?' '$(printf "\\$(printf '%03o' $((RANDOM%90+33))))'
        sleep 0.05
    done
    printf "\033[H\033[J\e[1;35m%s\e[0m\n" "$1"
}
