#!/usr/bin/env zsh


# ┌────────────────────────────────────────────┐
# │ Terminal Text Banner Animation Function    │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : FadeIn                      │
# └────────────────────────────────────────────┘


text_faded_in() {
    local msg="$1"
    # White (1;37) Purple (1;35) 
    local colors=("\e[1;37m" "\e[1;97m" "\e[1;95m" "\e[1;35m")
    tput civis
    for col in "${colors[@]}"; do
        printf "\r${col}%s\e[0m" "$msg"
        sleep 0.2
    done
    echo; tput cnorm
}
