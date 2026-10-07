#!/usr/bin/env zsh


# ┌────────────────────────────────────────────┐
# │ Terminal Text Banner Animation Function    │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# │ Animation    : Slide                       │
# └────────────────────────────────────────────┘


text_slide() {
  local text="$1"
  local padding=35
  local speed=0.01
  tput civis
  for ((i=padding;i>=0;i--)); do
  printf "\r%*s\e[1;36m%s\e[0m" "$i" "" "$text"
  sleep $speed
  done
  printf "\r\e[5m\e[1;36m%s\e[25m\e[0m\n" "$text"
  tput cnorm
}
