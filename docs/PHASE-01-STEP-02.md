# Phase 1 — Step 2

## Remove Forced TERM Chain

Remove `export TERM=kitty` and the `kitty → xterm-256color` rewrite so BuBuZsh
inherits and respects the terminal emulator's own `TERM`.

## Objective

Eliminate the forced TERM chain identified in Phase 0 (`.zshenv` forces
`TERM=kitty` → `exports.zsh` rewrites it again) and make the shell respect the
terminal/session-provided `TERM` — with the narrowest possible change, without
touching any other Phase 1 item.

## Problem From Phase 0

```text
.zshenv
    ↓
forced TERM=kitty
    ↓
exports.zsh
    ↓
TERM rewritten again ([[ "$TERM" == "kitty" ]] && export TERM=xterm-256color)
```

Consequences (from `docs/PHASE-00-AUDIT.md` §4/§13): dead code in first-level
shells, forced `kitty` in nested shells (empirically: `TERM=foo` became
`TERM=kitty`), native TERM lost in nested shells, behavior inconsistent
between shell levels.

## Files Inspected

- `zsh/.zshenv`, `zsh/config/exports.zsh` (the chain itself)
- Complete `zsh/` tree — recursive greps for
  `(export)?TERM=` and `TERM.*kitty|kitty.*TERM`
- `zsh/.zshrc` (does not reference TERM), `zsh/TerminZsh_Banner/`
  (zero TERM references), `zsh/.zshrcback`, `zsh/agents.md`,
  `zsh/.zhistory`, `zsh/.zcompdump*`
- Docs read first: `docs/PHASE-00-AUDIT.md`, `docs/BASELINE.md`,
  `docs/PHASE-01-STEP-01.md`

## Files Changed

| File | Change |
|---|---|
| `zsh/.zshenv` | removed 1 line (`export TERM=kitty`) |
| `zsh/config/exports.zsh` | removed 6 lines (dead `# Terminal` section header + the kitty→xterm-256color mutation + blank line) |

Exactly 2 files, **7 deletions, 0 insertions**. Nothing else in the repository
was touched (see Git Diff Review).

## TERM Changes

Every `TERM` occurrence in the tree, classified per instruction §4:

| Location | Classification | Action |
|---|---|---|
| `zsh/.zshenv:10` `export TERM=kitty` | **actual environment mutation** | **REMOVED** |
| `zsh/config/exports.zsh:25` `[[ "$TERM" == "kitty" ]] && export TERM=xterm-256color` | **actual environment mutation (workaround)** | **REMOVED** (with its now-empty `# Terminal` section) |
| `zsh/.zhistory:205,214,215,306` | runtime history records of old user commands (`ssh … export TERM=…`) — never executed by the config | kept (not code) |
| `zsh/agents.md:19,327,336,559,1085` | documentation/rules — these lines *instruct* not to force TERM (`Do NOT force: export TERM=kitty`) | kept (documentation) |
| `zsh/.zshrcback:61` `export TERM=kitty` | historical Oh-My-Zsh `.zshrc` backup; grep proves **nothing sources `zshrcback`** — inert archive of the old system | kept (inactive history; see Problems Found) |
| `zsh/.zcompdump*` | binary completion dumps containing TERM strings | kept (runtime artifacts) |
| `zsh/TerminZsh_Banner/*` | zero TERM references | untouched |

No `TERM` is set, exported, or rewritten anywhere in loadable code now.

## Terminal Assumptions Removed

- `TERM=kitty` forced in `.zshenv` → **removed**.
- `kitty → xterm-256color` rewrite in `exports.zsh` → **removed**.
- The "Terminal" section of `exports.zsh` (existed only for that workaround)
  → removed.
- **No replacement hardcoded TERM value was introduced** (no
  `export TERM=xterm-256color`, no other forced value).
- No other terminal assumptions exist (Phase 0: no `KITTY_*`, no `kitten`,
  no kitty escape sequences anywhere; cursor-shape DECSCUSR checks are
  capability outputs, not TERM mutations — left untouched).

## Kitty Compatibility

Kitty provides its own `TERM` (`xterm-kitty`, terminfo present on this
machine: `/usr/bin/kitty` installed). Isolated results with injected
`TERM=xterm-kitty`:

- non-interactive (`.zshenv` chain): `A_TERM=xterm-kitty` ✓
- interactive, full `.zshrc` (incl. `exports.zsh`): `C_RESULT_TERM=xterm-kitty` ✓
- full PTY session (banner → commands → clear → exit): echoed
  `T=xterm-kitty` unchanged ✓

The shell now inherits exactly what Kitty sets. Kitty's own configuration
(`~/.config/kitty/`) was not read or modified.

## GNOME Terminal Compatibility

GNOME Terminal/VTE provides its own `TERM` (typically `xterm-256color`; the
actual value recorded from this audit session's terminal environment is
`xterm-256color` — recorded, not invented). Isolated results:

- injected `TERM=xterm-256color`, interactive full `.zshrc`:
  `D_RESULT_TERM=xterm-256color` ✓
- this session's real TERM passed through the new config:
  `F_RESULT_TERM=xterm-256color` ✓
- additional standards-compliant value `TERM=screen-256color`:
  `E_RESULT_TERM=screen-256color` ✓ (proves arbitrary passthrough)

GNOME Terminal profiles were not read or modified.

## Syntax Validation

```text
zsh -n zsh/.zshenv              → OK
zsh -n zsh/config/exports.zsh   → OK
zsh -n zsh/.zshrc               → OK (unchanged, sanity check)
```

No modified configuration was sourced into `~/.config/zsh` or any live path.

## Runtime / Isolated Validation

All runs used isolated copies under `/tmp` (`/tmp/termtest` = post-edit copy;
`/tmp/step1-snapshot` = pre-edit copy for diffing). Live `ZDOTDIR` untouched.

| # | Scenario | Injected TERM | Observed TERM | Result |
|---|---|---|---|---|
| A | `.zshenv` chain, non-interactive (nested-shell path) | `xterm-kitty` | `xterm-kitty` | PASS |
| B | exact Phase 0 regression case | `foo` | **`foo`** (Phase 0 recorded `kitty`) | PASS |
| C | Kitty-style, interactive full `.zshrc` | `xterm-kitty` | `xterm-kitty` | PASS |
| D | GNOME Terminal-style, interactive full `.zshrc` | `xterm-256color` | `xterm-256color` | PASS |
| E | other compliant terminal, interactive | `screen-256color` | `screen-256color` | PASS |
| F | this session's real provided TERM, interactive | (inherited `xterm-256color`) | `xterm-256color` | PASS |

PTY regression run (`script` + pty sized 79→100 cols, `TERM=xterm-kitty`,
commands: `stty cols 100` → `echo T=$TERM` → `clear` → `exit`, exit code 0):

| Assertion | Result |
|---|---|
| Startup banner exactly once | **1** small time banner (`🌺 HH:MM 🌾`) — PASS |
| `TERM` preserved end-to-end | `T=xterm-kitty` — PASS |
| `clear` clears the screen | 2 clear-screen escapes in raw log (startup `command clear` + the explicit `clear`) — PASS (the "0" seen on the escape-stripped copy is expected: the strip step removes those sequences before counting) |
| `clear` shows the existing text banner | `🌺 Trust your heart…🌸🌾` ×1 after `clear` — PASS |
| Prompt redrawn after `clear` | `└─>` prompts ×4 across the session — PASS |
| Startup animation NOT triggered by `clear` | clear output contains only the static text banner — PASS |

Prompt content itself is unchanged (battery segment still present as before —
untouched on purpose; that is a separate step).

## Banner Verification

```bash
diff -rq hyprbuti/config/zsh/TerminZsh_Banner/ zsh/TerminZsh_Banner/
→ no differences (BANNER_UNCHANGED)
```

Zero TERM references inside the protected directory; not a single banner file
was touched. Startup-banner and `clear` implementations (`.zshrc` step 8,
`functions/utils.zsh`) are byte-identical to Step 1 — confirmed by the diff
review below.

## Live Configuration Verification

```text
find ~/.config/zsh -type f -newermt '2026-10-06 20:40'  → only .zhistory
  (runtime history appended by the running user shells; not written by this step)
~/.config/zsh/.zshrc   mtime 2026-08-11 23:09  (unchanged)
~/.config/zsh/.zshenv  mtime 2026-08-11 23:13  (unchanged)
~/.zshenv              mtime 2026-03-26 23:54  (unchanged)
~/.zshrc               does not exist (unchanged state)
hyprbuti git status     clean (0 entries), HEAD c4d0058
```

No writes to `~/.zshenv`, `~/.zshrc`, `~/.config/zsh/`, `~/.config/kitty/`,
or GNOME Terminal profiles. No software installed.

## Git Diff Review

The repository has **no commits yet**, so plain `git diff` is empty (nothing
tracked). The Step 1 state was snapshotted to `/tmp/step1-snapshot` *before*
editing and compared with `git diff --no-index`:

```text
 {/tmp/step1-snapshot => zsh}/.zshenv            | 1 -
 {/tmp/step1-snapshot => zsh}/config/exports.zsh | 6 ------
 2 files changed, 7 deletions(-)
```

Complete diff (verbatim):

```diff
--- a/tmp/step1-snapshot/.zshenv
+++ b/zsh/.zshenv
@@ -7,4 +7,3 @@ export ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}"
 # Basic environment
 export LANG=en_US.UTF-8
 export LC_ALL=en_US.UTF-8
-export TERM=kitty

--- a/tmp/step1-snapshot/config/exports.zsh
+++ b/zsh/config/exports.zsh
@@ -18,11 +18,5 @@ export LIBVIRT_DEFAULT_URI="qemu:///system"
 export EDITOR=nvim
 export VISUAL=nvim

-# ============================================
-# Terminal
-# ============================================
-
-[[ "$TERM" == "kitty" ]] && export TERM=xterm-256color
-
 export LANG=en_US.UTF-8
 export LC_ALL=en_US.UTF-8
```

Reviewed: only the TERM chain; no prompt/git/battery/banner/alias/locale/
installer/performance changes; no unrelated files. `git status` still shows
only `?? docs/` and `?? zsh/`. **No `git commit` and no `git push` performed.**

## Problems Found

1. **`zsh/.zshrcback:61` still contains `export TERM=kitty`.** It is a
   historical OMZ backup that nothing sources (grep-verified) — classified as
   inactive archive and deliberately left untouched to preserve the canonical
   history. If desired, a later repository-hygiene step may delete the file;
   not done here (would exceed this step's scope).
2. **`git diff` is unusable pre-first-commit** — resolved with a
   pre-edit snapshot + `git diff --no-index` (documented above).
3. **Remaining `TERM` strings** in `.zhistory` (past user commands),
   `agents.md` (rules text), `.zcompdump*` (binaries) were reviewed and
   classified — none is executable configuration. Not reported as failures.

## Step Status

PASS

## Next Step

Phase 1 — Step 3

