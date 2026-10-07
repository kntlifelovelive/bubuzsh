# ~/.config/zsh/functions/prompt.zsh
# Prompt function (split from main)

function set_bubu_prompt() {
    local exit_code=$?
    local git_branch=""
    local prompt_symbol=">"
    local venv_name=""
    local user_color=""

    # Detect active Python virtual environment
    if [[ -n "$VIRTUAL_ENV" ]]; then
        venv_name="(%F{green} $(basename $VIRTUAL_ENV)%f) "
    elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        venv_name="(%F{green} $CONDA_DEFAULT_ENV%f) "
    fi

    # Git branch & dirty check (skip entirely when git is not installed —
    # prompt must never reach the command-not-found handler)
    if (( $+commands[git] )) && git rev-parse --git-dir >/dev/null 2>&1; then
        local branch_name
        branch_name=$(git branch --show-current 2>/dev/null)
        git_branch=" %F{cyan}%f %F{blue}$branch_name%f"

        if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
            # Git dirty: recolor the Git indicator ONLY — never the arrow
            git_branch=" %F{red}%f %F{blue}$branch_name%f"
        fi
    fi


    # Command error check (arrow color: exit status ONLY — nothing else)
    if [[ $exit_code -ne 0 ]]; then
        prompt_symbol="%F{red}>%f"
    fi

    # User color
    if [[ $EUID -eq 0 ]]; then
        user_color="%F{red}"   # root = red
    else
        user_color="%F{220}%B" # normal user = yellow
    fi

    PROMPT="%F{magenta}┌(${venv_name}${user_color}%n%f%F{magenta})-[%F{cyan}%~%f%F{magenta}]${git_branch}
%F{magenta}└─${prompt_symbol} %f"

}

autoload -Uz add-zsh-hook
add-zsh-hook precmd set_bubu_prompt
