#!/usr/bin/env zsh 


# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Shutter                     │
# └────────────────────────────────────────────┘


# 15 Vertical Shutter fixed error 
header_shutter() {
    local lines=("${(@f)1}")
    local n=${#lines[@]}
    
    tput civis
    printf "\033[H\033[J" 
    
    for i in {1..$n}; do
        printf "\033[H"
        
        for j in {1..$n}; do
            if [[ $j -le $i ]]; then
                printf "\e[1;35m%s\e[0m\n" "${lines[$j]}"
            else
                echo ""
            fi
        done
        sleep 0.08
    done

    printf "\033[H\033[J\e[1;35m%s\e[0m\n" "$1"
    tput cnorm
}
