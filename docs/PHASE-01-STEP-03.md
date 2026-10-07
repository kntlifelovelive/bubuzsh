# Phase 1 — Step 3
## Prompt Specification

## Objective
Fix the prompt behavior so that:
1. The prompt arrow always exists.
2. Arrow color depends ONLY on previous command exit status.
3. Git dirty state affects ONLY the Git indicator.
4. Battery is removed from the main prompt.
5. Undefined `ssh_indicator` is removed from prompt usage.
6. Existing prompt appearance should otherwise remain as unchanged as practical.
7. Prompt performance should not be unnecessarily redesigned.

## Files Inspected
- zsh/functions/prompt.zsh
- zsh/themes/prompt.zsh
- zsh/modules/battery.zsh
- zsh/modules/command-not-found.zsh
- zsh/config/plugins.zsh
- zsh/functions/hooks.zsh
- zsh/config/options.zsh

## Files Changed
- zsh/functions/prompt.zsh

## Arrow Implementation
The arrow (prompt_symbol) is set based solely on `$exit_code` (the captured exit status of the previous command). The arrow is always present as `└─${prompt_symbol} ` in the PROMPT.

## Exit Status Handling
The exit status is captured at the beginning of `set_bubu_prompt()`:
    local exit_code=$?
This occurs before any helper commands (like git) that could overwrite `$?`.

## Git Indicator
Git state is reflected only in the `git_branch` variable:
- Clean Git: `%F{cyan}%f %F{blue}$branch_name%f`
- Dirty Git: `%F{red}%f %F{blue}$branch_name%f` (only the Git indicator turns red)
The arrow color is never changed by Git state.

## Battery Removal From Prompt
All references to `battery_info` and the `battery_status` function call have been removed from the prompt function. The battery module (zsh/modules/battery.zsh) remains intact but is no longer invoked in the prompt.

## SSH Indicator
The undefined `ssh_indicator` variable has been removed from the PROMPT construction.

## Prompt Performance
No additional external commands are added. Git checks remain limited to inside repositories (guarded by `git rev-parse --git-dir`). The prompt function remains lightweight.

## Four-State Test Matrix
Tested in an isolated PTY environment:
1. success + clean Git → Arrow normal, Git normal
2. success + dirty Git → Arrow normal, Git RED
3. failure + clean Git → Arrow RED, Git normal
4. failure + dirty Git → Arrow RED, Git RED
All states passed.

## Git Outside Repository Test
Outside a Git repository, `git_branch` remains empty and the prompt renders without Git segments. Arrow color still depends on exit status.

## Banner Regression
Startup banner behavior unchanged: one random animated banner per new session, exactly once. Verified by PTY log and visual inspection.

## TERM Regression
TERM is inherited from the terminal and not overridden. Verified:
- Non-interactive session with TERM=foo preserves foo.
- Kitty (xterm-kitty) and GNOME Terminal (xterm-256color) environments preserve the terminal-provided TERM.
No forced `export TERM=kitty` or equivalent remains in the source.

## Live Configuration Verification
Live user configuration (~/.config/zsh/, ~/.zshrc, ~/.zshenv) was not modified. Only runtime files (.zhistory) changed as expected.

## Git Diff Review
Only zsh/functions/prompt.zsh was modified. Changes:
- Removed battery status collection.
- Fixed Git dirty block to only recolor Git indicator, not arrow.
- Updated comment to reflect arrow color rule.
- Removed battery_info and ssh_indicator from PROMPT.

## Problems Found
None during this step.

## Step Status
PASS

## Next Step
Phase 1 — Step 4