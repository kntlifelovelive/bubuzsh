#!/usr/bin/env zsh 


# ┌────────────────────────────────────────────┐
# │ Terminal Text Banner Animation Function    │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Zoom                        │
# └────────────────────────────────────────────┘


text_zoom_in() {
    local msg="$1"
    local len=${#msg}
    tput civis
    for i in {1..10}; do
        local segment=$(( (len * i) / 10 ))
        local start=$(( (len - segment) / 2 ))
        printf "\r%*s%s%*s" $start "" "${msg:$start:$segment}" $((len - start - segment)) ""
        sleep 0.05
    done
    printf "\r\e[1;36m%s\e[0m\n" "$msg"
    tput cnorm
}
