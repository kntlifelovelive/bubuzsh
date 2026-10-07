# ~/.config/zsh/keybindings/spf.zsh
# SPF (Super File Manager) keybindings

function spf() {
    os=$(uname -s)
    
    # Linux
    if [[ "$os" == "Linux" ]]; then
        export SPF_LAST_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
    fi
    
    command spf "$@"
    
    [ ! -f "$SPF_LAST_DIR" ] || {
        . "$SPF_LAST_DIR"
        rm -f -- "$SPF_LAST_DIR" > /dev/null
    }
}

function spf_widget() {
    zle push-line
    BUFFER="spf"
    zle accept-line
}

zle -N spf_widget
bindkey '^g' spf_widget
