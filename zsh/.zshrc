# ~/.config/zsh/.zshrc
# ============================================
# Minimal, modular Zsh configuration
# ============================================

# 1. Core settings (must be first)
source "$ZDOTDIR/config/exports.zsh"
source "$ZDOTDIR/config/options.zsh"

# 2. Modules (tool-specific configs)
# (N): missing dir/empty glob = empty loop, not an error that aborts .zshrc
for mod in "$ZDOTDIR/modules/"*.zsh(N); do
    [[ -f "$mod" ]] && source "$mod"
done

# 3. Aliases (after PATH is set)
source "$ZDOTDIR/config/aliases.zsh"

# 4. Plugins (after aliases)
source "$ZDOTDIR/config/plugins.zsh"




# 5. Keybindings
for kb in "$ZDOTDIR/keybindings/"*.zsh(N); do
    [[ -f "$kb" ]] && source "$kb"
done

# 6. Functions
for func in "$ZDOTDIR/functions/"*.zsh(N); do
    [[ -f "$func" ]] && source "$func"
done

# 7. Theme (last!)
source "$ZDOTDIR/themes/prompt.zsh"



# 8. Banner System (Full Original Code)
# ============================================
# ┌────────────────────────────────────────────┐
# │ Terminal Banner ScriptPath Import Variable │
# │ AuthorModify : KyawNyeinThant,Gemini flash │
# │ Date         : 2026 , March, 17            │
# └────────────────────────────────────────────┘
# Terminal Banner Script Path folder
# Resolve via $ZDOTDIR (default ~/.config/zsh) so self-contained/isolated
# installs use the banner bundled next to this config, not a hardcoded path
BANNER_DIR="$ZDOTDIR/TerminZsh_Banner"

# 1 Load Variable Files
[[ -f "$BANNER_DIR/asciibanners.zsh" ]] && source "$BANNER_DIR/asciibanners.zsh"
[[ -f "$BANNER_DIR/textbanners.zsh" ]] && source "$BANNER_DIR/textbanners.zsh"

# 2 Load All Functions (Animations & Effects)
for f in "$BANNER_DIR/animations/"*.zsh(N); do source "$f"; done
for f in "$BANNER_DIR/text_effects/"*.zsh(N); do source "$f"; done

# ┌────────────────────────────────────────────┐
# │ Terminal Banner Animation Main Function    │
# │ Optimized Version - 27 March 2026          │
# └────────────────────────────────────────────┘
random_banner() {
    # Get terminal size once (faster)
    local cols=$(tput cols 2>/dev/null)
    local lines=$(tput lines 2>/dev/null)

    # Default values if tput fails
    [[ -z "$cols" ]] && cols=80
    [[ -z "$lines" ]] && lines=24

    # If terminal is too small, show simple banner and return FAST
    if (( cols < 80 || lines < 20 )); then
        printf "\e[0;36m🌺 %s 🌾\e[0m\n" "$(date +%H:%M)"
        return 0
    fi

    # Only run animations for large terminals (original code)
    local ascii_list=( ${(k)parameters[(I)Banner_*]} )
    local selected_ascii_name="${ascii_list[$(( RANDOM % ${#ascii_list[@]} + 1 ))]}"
    local selected_ascii="${(P)selected_ascii_name}"

    local text_list=( ${(k)parameters[(I)Text_*]} )
    local selected_text_name="${text_list[$(( RANDOM % ${#text_list[@]} + 1 ))]}"
    local selected_text="${(P)selected_text_name}"

    local header_anims=( ${(k)functions[(I)header_*]} )
    local text_effects=( ${(k)functions[(I)text_*]} )

    if [[ ${#header_anims[@]} -gt 0 ]]; then
        local h_idx=$(( RANDOM % ${#header_anims[@]} + 1 ))
        ${header_anims[$h_idx]} "$selected_ascii"
    fi

    if [[ ${#text_effects[@]} -gt 0 ]]; then
        local t_idx=$(( RANDOM % ${#text_effects[@]} + 1 ))
        ${text_effects[$t_idx]} "$selected_text"
    fi
}

# Terminal startup
[[ -o interactive ]] && { command clear; random_banner }
