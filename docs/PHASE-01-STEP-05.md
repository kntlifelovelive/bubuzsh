# Phase 1 — Step 5
## Command-Not-Found / CNF Safety

## Objective
Make the command-not-found handler safe in every execution context so that a
missing optional command can never silently hang the shell, while preserving
the existing interactive y/N package-search UX on pacman systems.

## Problem From Phase 0
Bug #7 (docs/PHASE-00-AUDIT.md, section 14 block):
`command_not_found_handler` runs even for commands inside `$( … )` in
interactive shells. Its stdout is captured by the substitution (invisible)
while `read -k1` reads the real terminal → a missing fzf/zoxide/git on a
pacman system makes startup or the prompt silently wait for a keypress.
Audit recommendation 4 also required that prompt-time git calls never reach
the handler (`command -v git` guard around the prompt git block).

## Files Inspected
- zsh/modules/command-not-found.zsh (handler)
- zsh/functions/prompt.zsh (prompt-time git calls)
- zsh/.zshrc (module load order: step 2 `modules/*.zsh` loop)
- zsh/functions/utils.zsh (clear → print_banner, for regression)
- docs/PHASE-00-AUDIT.md (section 14 block, bug #7, recommendation 4)

## Files Changed
- zsh/modules/command-not-found.zsh
- zsh/functions/prompt.zsh (only the git-block guard line; Step 3 changes unchanged)

## Changes Made

### 1. Handler context guard (modules/command-not-found.zsh)
Added at the top of `command_not_found_handler()`:

```zsh
if [[ ! -o interactive || ! -t 0 || ! -t 1 ]]; then
    echo -e "󰅙 Command not found: $cmd" >&2
    return 127
fi
```

- The interactive y/N flow (and both `read -k1` calls) now only runs when the
  shell is interactive AND stdin AND stdout are real terminals.
- Inside `$( … )` stdout is a pipe → guard triggers → plain message to stderr,
  `return 127`, no input is ever read → no hang.
- The pacman branch, prompts, search, and install flow are otherwise untouched.

### 2. Prompt git guard (functions/prompt.zsh)
```zsh
if (( $+commands[git] )) && git rev-parse --git-dir >/dev/null 2>&1; then
```
When git is not installed, the prompt git block is skipped entirely, so
prompt-time git calls can never reach the CNF handler (which at prompt time
has a TTY stdout and would otherwise show the y/N prompt on every prompt).
Same guard style as Step 4 (`(( $+commands[...] ))`).

## Handler Behavior Matrix
| Context | stdin/tty | stdout/tty | interactive | Behavior |
|---|---|---|---|---|
| Direct typed command (PTY) | yes | yes | yes | full pacman y/N UX (unchanged) |
| Inside `$( … )` in interactive shell | yes | pipe | yes | plain message → stderr, 127, no read |
| `zsh -i -c 'cmd'` with stdin redirected | no | no | yes | plain message, 127, no read |
| Startup/prompt-time git missing | — | — | — | never reaches handler (prompt guard) |
| Non-interactive / scripts / pipelines | varies | pipe/file | no | plain message, 127, no read |

## Syntax Validation
`zsh -n` PASS on all 9 changed/startup files:
.zshenv, config/exports.zsh, config/plugins.zsh, functions/prompt.zsh,
modules/fzf.zsh, modules/zoxide.zsh, modules/command-not-found.zsh,
keybindings/main.zsh, .zshrc.

## Runtime / Isolated Validation
All tests ran against an isolated copy (`/tmp/step5`, `ZDOTDIR=/tmp/step5`);
the live configuration was never sourced or modified.

1. **Test A — non-TTY stdin:** `zsh -i -c 'definitely_not_a_cmd_xyz' </dev/null`
   → immediately prints "Command not found", exit 127, no hang (timeout not hit).
2. **Test C — substitution (the Phase 0 hang scenario):** interactive PTY,
   `x=$(definitely_not_a_cmd_xyz); echo SUBST_RC=$?`
   → message printed, `SUBST_RC=127`, `echo ALIVE` ran, shell never blocked.
3. **Test D — interactive UX preserved:** interactive PTY, direct missing command
   → "Search Package? [y/N]" appeared, `n` → "Cancelled", shell continued,
   clean exit 0.
4. **Test E — full regression session:** startup banner once → `clear` →
   single text banner → prompt; `T=xterm-kitty` preserved; 4-state matrix in a
   scratch git repo (raw-escape analysis of every prompt render):
   - success+clean → git icon cyan, arrow normal
   - success+dirty → git icon RED, arrow normal
   - failure+dirty → git icon RED, arrow RED
   - failure+clean → git icon cyan, arrow RED
   All four required combinations PASS. Arrow recolor occurs only after `false`.
5. **Test F — git missing:** interactive PTY with a symlink-farm PATH containing
   no `git` → shell starts, prompt renders with permanent `└─>` arrow, zero git
   segment, zero CNF noise, `echo`/`false`/`exit` all work (no hang).
6. **Step 3/4 re-verified** during this step: battery absent from PROMPT,
   `ssh_indicator` absent, TERM passthrough intact.

## Banner Verification
`diff -rq hyprbuti/config/zsh/TerminZsh_Banner/ zsh/TerminZsh_Banner/`
→ **no differences** (byte-identical).

Startup banner: exactly one animated banner per new interactive session
(counted 1 in plain PTY session), never re-runs on prompt redraw.
`clear`: clear screen → single existing text banner → prompt; no startup
animation. Both unchanged.

## Live Configuration Verification
- `~/.config/zsh/` config files: unmodified (only runtime `.zhistory` changed
  by the user's own sessions).
- `~/.zshenv`: untouched (mtime Mar 26 2026); `~/.zshrc`: does not exist.
- hyprbuti repository: clean, HEAD c4d0058 unchanged.
- No symlinks in `zsh/` (`find zsh -type l` → none).

## Git Diff Review
Repository has no commits yet (`git diff` unusable); comparison performed
against the canonical baseline with `diff -rq hyprbuti/config/zsh/ zsh/`.
Changed files (Steps 2–5 combined): exactly 8 —
1. zsh/.zshenv (Step 2: forced TERM removed)
2. zsh/config/exports.zsh (Step 2: TERM workaround removed)
3. zsh/functions/prompt.zsh (Step 3: prompt spec + Step 5: git guard)
4. zsh/config/plugins.zsh (Step 4: OMZ/clipboard source guards)
5. zsh/modules/fzf.zsh (Step 4: fzf guard)
6. zsh/modules/zoxide.zsh (Step 4: zoxide guard)
7. zsh/keybindings/main.zsh (Step 4: widget guard)
8. zsh/modules/command-not-found.zsh (Step 5: context guard)
Plus `agents.md` (intentional BuBuZsh-only metadata from Step 1).
No unrelated changes present.

## Problems Found
```text
Problem:
None blocking. Note: the non-interactive fallback message now goes to stderr
(previously stdout) so it stays visible inside $( … ); the interactive
stdout flow is unchanged.

Location:
zsh/modules/command-not-found.zsh

Current behavior:
Guard added this step; behavior verified by tests A/C/D.

Why it is a problem:
N/A — documented for transparency.

Recommended future change:
None required.

Phase:
N/A
```

## Step Status
PASS

## Next Step
Phase 1 — Step 6

