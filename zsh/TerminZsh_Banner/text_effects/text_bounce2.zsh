#!/usr/bin/env zsh 


# ┌────────────────────────────────────────────┐
# │ Terminal Text Banner Animation Function    │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Bounce2                     │
# └────────────────────────────────────────────┘

text_bounce() {
    local msg="$1"
    tput civis
    
    # 3 time up and down
    for i in {1..3}; do
        printf "\n\033[1A\r\e[1;36m%s\e[0m" "$msg"
        sleep 0.15
        
        printf "\r\033[K\n\e[1;34m%s\e[0m" "$msg"
        printf "\033[1A" 
        sleep 0.15
    done
    
    printf "\r\033[K\n\e[1;36m%s\e[0m\n" "$msg"
    tput cnorm
}
