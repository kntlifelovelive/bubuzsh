#!/usr/bin/env zsh

# ┌────────────────────────────────────────────┐
# │ Terminal Header Banner Animation Function  │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : SlideDown                   │
# └────────────────────────────────────────────┘
# --- Animation Functions (Argument Based) 


header_slide_down() {
    local lines=("${(@f)1}")
    for line in "${lines[@]}"; do
        printf "\e[1;35m%s\e[0m\n" "$line"
        sleep 0.05
    done
}

