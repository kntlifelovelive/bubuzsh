# ~/.config/zsh/config/aliases.zsh
# All aliases organized by category

# ============================================
# System
# ============================================
(( $+commands[pacman] )) && alias update='sudo pacman -Syu'   # Arch only
alias love='clear && myfetch -i A -f -c 16 -C " █ "'
alias grep='grep --color=auto'
alias bye='sudo shutdown -h now'
alias loop='sudo reboot'
alias fonts='fc-list -f "%{family}\n"'
alias fontcache='fc-cache -fv'
alias n='nvim'
alias hr='hyprctl reload'

# ============================================
# EZA (Modern ls replacement)
# ============================================
alias e='eza --icons'
alias ea='eza -a --icons'
alias el='eza -lh --icons --git --group-directories-first'
alias elt='eza -lh --total-size --icons --git --group-directories-first'
alias eltt='eza -lh --total-size --tree --icons --git --group-directories-first'
alias ela='eza -alh --icons --git --group-directories-first'

# ============================================
# Pacman (Arch Linux package manager — only when pacman exists)
# ============================================
if (( $+commands[pacman] )); then
    alias pacupf='sudo pacman -Syyu'      # Force update system
    alias pacmanrm='sudo pacman -Rns'     # Remove package with configs
    alias pacmanss='pacman -Ss'           # Search package in repo
    alias pacmani='sudo pacman -S'        # Install package
    alias pacq='pacman -Q'                # List installed packages
    alias pacql='pacman -Ql'              # List files of a package
    alias pacinfo='pacman -Si'            # Show package info
fi

# ============================================
# Yay (AUR helper — only when yay exists)
# ============================================
if (( $+commands[yay] )); then
    alias yupdate='yay -Syu'              # Update all (AUR + repo)
    alias yinstall='yay -S'               # Install package from AUR/repo
    alias yremove='yay -Rns'              # Remove with configs
    alias yclean='yay -Yc'                # Clean unneeded packages
    alias ysearch='yay -Ss'               # Search
fi
