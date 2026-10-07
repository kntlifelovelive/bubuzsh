# ~/.config/zsh/keybindings/main.zsh
# Core keybindings and Vi mode

# ============================================
# Vi Mode Setup
# ============================================
bindkey -v
export KEYTIMEOUT=20

# jk to exit insert mode (fast escape)
bindkey -M viins 'jk' vi-cmd-mode

# ============================================
# Autosuggestions
# ============================================
# Tab to accept suggestion (fixed: removed duplicate)
if (( $+widgets[autosuggest-accept] )); then
    bindkey -M viins '^ ' autosuggest-accept
fi

# ============================================
# Cursor Shape (block for normal, beam for insert)
# ============================================
function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
        echo -ne '\e[2 q'   # Normal mode: block cursor
    else
        echo -ne '\e[6 q'   # Insert mode: beam cursor
    fi
}
zle -N zle-keymap-select

_fix_cursor() { echo -ne '\e[6 q' }
precmd_functions+=(_fix_cursor)
