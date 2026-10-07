#!/usr/bin/env zsh 


# ┌────────────────────────────────────────────┐
# │ Terminal Text Banner Animation Function    │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : RainBow                     │
# └────────────────────────────────────────────┘

text_rainbow() {
    local msg="$1"
    local colors=("\e[1;31m" "\e[1;33m" "\e[1;32m" "\e[1;36m" "\e[1;34m" "\e[1;35m")
    for i in {1..15}; do
        local col="${colors[$((RANDOM % ${#colors[@]} + 1))]}"
        printf "\r${col}%s\e[0m" "$msg"
        sleep 0.1
    done
    echo
}
