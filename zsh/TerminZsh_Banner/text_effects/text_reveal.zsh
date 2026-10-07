#!/usr/bin/env zsh 


# ┌────────────────────────────────────────────┐
# │ Terminal Text Banner Animation Function    │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Reveal                      │
# └────────────────────────────────────────────┘


text_reveal() {
    local msg="$1"; local len=${#msg}
    for i in {1..$((len/2+1))}; do
        printf "\r%*s%s%*s" $((len/2-i+1)) "" "${msg:$((len/2-i+1)):$((i*2))}" $((len/2-i+1)) ""
        sleep 0.02
    done
    printf "\r\e[1;36m%s\e[0m\n" "$msg"
}

