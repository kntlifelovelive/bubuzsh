# ~/.config/zsh/config/exports.zsh
# PATH and environment variables

# ============================================
# PATH additions
# ============================================
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# ============================================
# Virtualization
# ============================================
export LIBVIRT_DEFAULT_URI="qemu:///system"

# ============================================
# Editor
# ============================================
export EDITOR=nvim
export VISUAL=nvim

# LANG/LC_ALL are set once in .zshenv (loaded before this file) — not duplicated here
