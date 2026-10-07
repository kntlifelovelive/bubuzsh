# Oh-My-Zsh
DISABLE_AUTO_UPDATE="true"
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
    source "$ZSH/oh-my-zsh.sh"
fi

# Custom plugins
if [[ -f "${ZSH_CUSTOM:-~/.zsh}/plugins/zsh-system-clipboard/zsh-system-clipboard.zsh" ]]; then
    source "${ZSH_CUSTOM:-~/.zsh}/plugins/zsh-system-clipboard/zsh-system-clipboard.zsh"
fi
#git clone https://github.com/kutsan/zsh-system-clipboard ${ZSH_CUSTOM:-~/.zsh}/plugins/zsh-system-clipboard
