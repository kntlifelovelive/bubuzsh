#!/usr/bin/env zsh


# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : GlitchRise                  │
# └────────────────────────────────────────────┘


header_glitch_rise() {
    local lines=("${(@f)1}")
    local chars="!@#$%^&*"
    tput civis
    for i in {3..0}; do
        printf "\033[H\033[J"
        for ((k=1; k<=i; k++)); do echo ""; done
        for line in "${lines[@]}"; do
            local gl=""
            for ((j=0; j<${#line}; j++)); do
                (( RANDOM % 20 < 2 )) && gl+="${chars[$((RANDOM%${#chars}+1))]}" || gl+="${line:$j:1}"
            done
            printf "\e[1;35m%s\e[0m\n" "$gl"
        done
        sleep 0.08
    done
    printf "\033[H\033[J\e[1;35m%s\e[0m\n" "$1"
    tput cnorm
}
