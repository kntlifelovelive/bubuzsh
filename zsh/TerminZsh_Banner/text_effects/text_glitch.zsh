#!/usr/bin/env zsh


# ┌────────────────────────────────────────────┐
# │ Terminal Text Banner Animation Function    │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Glitch                      │
# └────────────────────────────────────────────┘

text_glitch() { 
  local text="$1"

  for i in {1..10}; do
  printf "\r"
  for ((j=0;j<${#text};j++)); do
    if (( RANDOM % 8 == 0 )); then
    printf "%s" "$(printf \\$(printf '%03o' $((RANDOM%26+33))))"
    else
    printf "%s" "${text:$j:1}"
    fi
  done
  sleep 0.01
  done
  printf "\r\e[1;36m%s\e[0m\n" "$text" 
}
