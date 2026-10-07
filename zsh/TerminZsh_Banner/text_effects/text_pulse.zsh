#!/usr/bin/env zsh 


# ┌────────────────────────────────────────────┐
# │ Terminal Text Banner Animation Function    │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Pulse                       │
# └────────────────────────────────────────────┘

text_pulse() {
    local msg="$1"
    # Dim (2), Normal (0), Bold (1), Bright (1;96)
    local colors=("\e[2;36m" "\e[0;36m" "\e[1;36m" "\e[1;96m" "\e[1;36m" "\e[0;36m")
    tput civis
    for col in "${colors[@]}"; do
        printf "\r${col}%s\e[0m" "$msg"
        sleep 0.15
    done
    echo; tput cnorm
}
