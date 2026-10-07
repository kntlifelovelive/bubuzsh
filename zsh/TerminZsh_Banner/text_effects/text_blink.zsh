#!/usr/bin/env zsh


# ┌────────────────────────────────────────────┐
# │ Terminal Text Banner Animation Function    │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Blink                       │
# └────────────────────────────────────────────┘

text_blink() { 
  local text="$1"
  for i in {1..6}; do
  printf "\r\e[2m%s\e[0m" "$text"
  sleep 0.1
  printf "\r\e[1;36m%s\e[0m" "$text"
  sleep 0.1
  done
  echo
}

