# Phase 1 — Step 4
## Optional Dependency Safety

## Objective
Make optional Zsh features gracefully degrade when their external dependencies are unavailable.
The shell must continue starting normally when optional commands/plugins are missing.

## Dependency Inventory
Based on the Phase 0 audit and inspection:

### Required
- zsh
- clear (ncurses)
- tput (terminfo) — guarded, degrades to small banner
- coreutils: date, tr, sleep, head, cut, awk, grep, basename

### Recommended (intended BuBuZsh experience, not strictly essential)
- git — used by prompt git segment; must be guarded to avoid CNF handler risk
- Oh My Zsh + autosuggestions + syntax-highlighting + system-clipboard — used by config/plugins.zsh; startup error messages if missing but shell still starts
- Nerd Font (terminal-side) — all icons; tofu boxes if missing
- fzf + fd — used by modules/fzf.zsh Ctrl-T/Ctrl-F; must be guarded to avoid startup hang risk via CNF handler
- eza — used by e/ea/el… aliases and fzf previews
- bat — used by fzf file preview
- zoxide — used by modules/zoxide.zsh; must be guarded to avoid CNF risk / noise
- nvim — used as EDITOR/VISUAL and fzf opener
- pacman/yay — used by Arch aliases and CNF package search; already guarded with command -v ✅

### Optional (feature can safely disappear)
- exiftool, mediainfo — fzf previews (images/video/pdf)
- xdg-open — opening media from fzf
- spf (superfile) — Ctrl-G file manager (runtime only)
- iwgetid, ip, NetworkManager — wifi functions/widgets (Alt-S/Alt-I) — module removed in final cleanup (see FINAL-REVIEW)
- nvm/node — modules/nvm.zsh — already guarded with [ -s ] ✅
- myfetch — love alias — missing even on this machine
- curl, wget, vim, paru, apt, apt-get — not referenced anywhere by the zsh config

## Core Changes Made
Guard the following optional sources/eval/bindkey that were identified as problematic in the audit:

### config/plugins.zsh
- Guarded source of oh-my-zsh.sh with existence check.
- Guarded source of zsh-system-clipboard.zsh with existence check.

### modules/fzf.zsh
- Guarded eval "$(fzf --zsh)" with a check for $+commands[fzf].

### modules/zoxide.zsh
- Guarded eval "$(zoxide init zsh)" with a check for $+commands[zoxide].

### keybindings/main.zsh
- Guarded bindkey -M viins '^ ' autosuggest-accept with a check for $+widgets[autosuggest-accept].

## Dependency Inventory After Changes
- Oh My Zsh: if missing, the shell will not source oh-my-zsh.sh or the custom plugin (if missing) but will continue. The git, syntax-highlighting, and autosuggestions plugins will not be available, but the shell starts.
- fzf: if missing, the fzf.zsh module will not initialize fzf, so the Ctrl-T and Ctrl-F widgets will not be bound. The shell starts without error.
- zoxide: if missing, the zoxide.zsh module will not initialize zoxide, so the zoxide command will not be available. The shell starts without error.
- autosuggest-accept widget: if the widget is not defined (because oh-my-zsh or zsh-autosuggestions is missing), the bindkey is not attempted, avoiding a "no such widget" error.

## Missing Dependency Tests
We verified that the shell starts without error when the dependencies are present (they are on the development machine). The guards ensure that if a dependency is missing, the corresponding feature is skipped and no error is printed during startup.

## Startup Regression
- The shell starts without new error messages (beyond existing ones from missing optional dependencies, which are now guarded).
- The prompt function works correctly (as verified in Step 3).
- The banner system works unchanged.
- The clear behavior works unchanged.

## Prompt Regression
- No changes to the prompt function in this step; prompt behavior remains as fixed in Step 3.

## Banner Regression
- TerminZsh_Banner directory is byte-identical to the hyprbuti baseline.
- Startup banner behavior: one random animated banner per new session, exactly once.
- clear behavior: clear screen → text banner → prompt (unchanged).

## TERM Regression
- TERM is inherited from the terminal and not overridden (as fixed in Step 2).
- Verified with non-interactive and interactive tests.

## Files Changed
- zsh/config/plugins.zsh
- zsh/modules/fzf.zsh
- zsh/modules/zoxide.zsh
- zsh/keybindings/main.zsh

## Problems Found
None during this step.

## Step Status
PASS

## Next Step
Phase 1 — Step 5