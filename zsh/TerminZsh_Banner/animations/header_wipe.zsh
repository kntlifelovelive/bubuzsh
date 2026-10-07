#!/usr/bin/env zsh 


# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Wipe                        │
# └────────────────────────────────────────────┘

# 17 Bottom-Up Wipe - Fixed
header_wipe() {
    local lines=("${(@f)1}")
    local n=${#lines[@]} 
    
    tput civis
    for i in {1..$n}; do
        printf "\033[H\033[J"
        
        local start_at=$(( n - i + 1 ))
        
        for p in {1..$((start_at - 1))}; do
            [[ $start_at -gt 1 ]] && echo ""
        done
        
        for j in {$start_at..$n}; do
            printf "\e[1;36m%s\e[0m\n" "${lines[$j]}"
        done
        
        sleep 0.08
    done
    
    printf "\033[H\033[J\e[1;36m%s\e[0m\n" "$1"
    tput cnorm
}
