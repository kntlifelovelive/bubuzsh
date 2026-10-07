# BuBuZsh Phase 0 Audit

> **Status:** Phase 0 complete — AUDIT ONLY. No source file, user configuration, or
> `TerminZsh_Banner/` file was created, modified, renamed, moved, or deleted.
> All experiments ran against **copies in `/tmp/zshaudit/`**; the live
> `~/.config/zsh/`, `~/.zshrc`, `~/.zshenv`, and `hyprbuti/` were only read.

**Audit target:** the Zsh configuration inside the `hyprbuti` repository
(`hyprbuti/config/zsh/` + `hyprbuti/config/zshenv/.zshenv`), copied
byte-identically into `/home/archibubu/bubuzsh/zsh/` (verified with `diff -rq`).

---

## 1. Environment

| Item | Value |
|---|---|
| OS | Arch Linux (rolling) |
| Desktop | Hyprland (`XDG_CURRENT_DESKTOP=Hyprland`) |
| Primary terminal (stated) | Kitty (`/usr/bin/kitty` installed) |
| This audit session's terminal | VS Code integrated terminal, `TERM=xterm-256color`, no `KITTY_*` vars |
| Other terminal present | GNOME Terminal (`/usr/bin/gnome-terminal`) |
| Zsh version | `zsh 5.9.2 (x86_64-pc-linux-gnu)` |
| Source project | `/home/archibubu/hyprbuti` |
| Audit workspace | `/home/archibubu/bubuzsh` (git repo, no commits, `?? zsh/` untracked) |
| Live config (NOT modified) | `/home/archibubu/.config/zsh/` + `/home/archibubu/.zshenv` |
| `/etc/zshenv` | does not exist; `/etc/zsh/zprofile` only sources `/etc/profile` — no system-wide `ZDOTDIR` |

**Key discovery — three variants exist:**

1. `hyprbuti/config/zsh/` — the audit target (baseline).
2. `bubuzsh/zsh/` — identical copy of (1), plus `agents.md`; missing only `.zshrcback`.
3. **Live** `~/.config/zsh/` — has **diverged** from (1):

| File | Live vs. audit target |
|---|---|
| `.zshrc` | identical |
| `.zshenv` | identical except trailing newline |
| `functions/prompt.zsh` | `battery_info=$(battery_status …)` **commented out** in live |
| `config/exports.zsh` | live adds `QT_QPA_PLATFORMTHEME=qt5ct` then `=qt6ct` (second wins) |
| `config/plugins.zsh` | live moves `zsh-system-clipboard` into OMZ `plugins=(…)`, quotes `source` |
| `config/aliases.zsh` | live adds `els` alias; comment spacing otherwise |
| `keybindings/main.zsh` | live adds `setopt ignoreeof` |
| `modules/fzf.zsh` | differs (minor) |
| `TerminZsh_Banner/textbanners.zsh` | trailing spaces of `Text_2`/`Text_3` only |
| live-only files | `functions/{fastdownload,help,video_convert,youtubedownload}.zsh`, `keybindings/{fzf,pkg}.zsh`, `installpackgezsh/installzshpackage.zsh` |
| live-removed files | `functions/wifi.zsh`, `keybindings/wifi.zsh`, `keybindings/spf.zsh` |

Phase 0 does **not** choose a baseline — that decision belongs to Phase 1.

---

## 2. Existing Zsh Structure

> **Final cleanup note:** `keybindings/wifi.zsh` and `functions/wifi.zsh`
> are **not** part of the final BuBuZsh project (Wi-Fi module intentionally
> excluded — see `docs/FINAL-REVIEW.md`). The tree below is the Phase 0
> baseline snapshot as audited.

```
hyprbuti/config/
├── zshenv/.zshenv                 # one-liner: export ZDOTDIR=$HOME/.config/zsh
├── zshroot/.zshrc                 # separate root shell config (legacy OMZ style)
├── zsh/
│   ├── .zshenv                    # ZDOTDIR + LANG/LC_ALL + TERM=kitty
│   ├── .zshrc                     # main entry, 100 lines, loads everything
│   ├── .zshrcback                 # old full OMZ .zshrc backup (not copied to bubuzsh)
│   ├── config/
│   │   ├── exports.zsh            # PATH, EDITOR, TERM conversion, locale   (28)
│   │   ├── options.zsh            # history + compinit + misc setopt        (22)
│   │   ├── aliases.zsh            # system/eza/pacman/yay aliases           (45)
│   │   └── plugins.zsh            # Oh My Zsh + clipboard plugin            (12)
│   ├── modules/
│   │   ├── battery.zsh            # battery_status() function only          (58)
│   │   ├── command-not-found.zsh  # command_not_found_handler (pacman UX)   (60)
│   │   ├── fzf.zsh                # eval fzf --zsh + Ctrl-T/Ctrl-F widgets  (78)
│   │   ├── nvm.zsh                # NVM_DIR + China mirrors                 (9)
│   │   ├── profiler.zsh           # zmodload zsh/zprof (call commented out) (6)
│   │   └── zoxide.zsh             # eval zoxide init zsh                    (4)
│   ├── keybindings/
│   │   ├── main.zsh               # vi mode, jk, cursor shape, ^Space       (32)
│   │   ├── spf.zsh                # superfile wrapper + Ctrl-G              (27)
│   │   └── wifi.zsh               # Alt-S / Alt-I widgets                   (19)
│   ├── functions/
│   │   ├── hooks.zsh              # preexec/precmd command-duration display (57)
│   │   ├── prompt.zsh             # set_bubu_prompt + add-zsh-hook          (62)
│   │   ├── utils.zsh              # print_banner + clear override           (18)
│   │   └── wifi.zsh               # wifi-passwords/status/info             (76)
│   ├── themes/prompt.zsh          # 5 lines, re-sources functions/prompt.zsh
│   └── TerminZsh_Banner/          # PROTECTED — 144K, see section 11
│       ├── asciibanners.zsh       # Banner_1…Banner_13 (116 lines)
│       ├── textbanners.zsh        # Text_1…Text_4 (13 lines)
│       ├── animations/            # 21 files → header_*() functions
│       └── text_effects/          # 12 files → text_*() functions
```

Runtime artifacts inside the audited directory (must not ship in BuBuZsh):
`.zhistory`, `.zcompdump`, `.zcompdump-love-5.9`, `.zcompdump-love-5.9.zwc`
(`love` = original machine's hostname).

---

## 3. Startup Flow

Verified from source **and** empirically (`env -i … zsh -c`, sandboxed interactive
sessions through a PTY).

```
zsh starts
  │
  ├─ /etc/zshenv                      (does not exist here)
  ├─ ${ZDOTDIR-$HOME}/.zshenv         ZDOTDIR unset → reads ~/.zshenv
  │      ~/.zshenv: export ZDOTDIR=$HOME/.config/zsh
  │      ⚠ ~/.config/zsh/.zshenv is NOT re-read at this point (proved: TERM
  │        stayed "foo" in `env -i TERM=foo zsh -c`). It is read only when
  │        ZDOTDIR is already exported — i.e. in NESTED zsh shells.
  │
  ├─ (login) /etc/zsh/zprofile, $ZDOTDIR/.zprofile
  │      $ZDOTDIR/.zprofile is a DANGLING symlink → silently skipped
  │
  ├─ (interactive) $ZDOTDIR/.zshrc    ← the 100-line main file
  │      step 1  config/exports.zsh, config/options.zsh  (compinit runs here)
  │      step 2  modules/*.zsh loop (battery, command-not-found, fzf,
  │                                   nvm, profiler, zoxide — alphabetical)
  │      step 3  config/aliases.zsh
  │      step 4  config/plugins.zsh  (Oh My Zsh: autosuggestions,
  │                                   syntax-highlighting, git, clipboard)
  │      step 5  keybindings/*.zsh loop (main, spf, wifi)
  │      step 6  functions/*.zsh loop (hooks, prompt, utils, wifi)
  │                 ├─ main.zsh (step 5) did: precmd_functions+=(_fix_cursor)
  │                 ├─ prompt.zsh: add-zsh-hook precmd set_bubu_prompt
  │                 └─ utils.zsh: defines `function clear` (override)
  │      step 7  themes/prompt.zsh → re-sources functions/prompt.zsh (2nd time)
  │      step 8  BANNER: sources TerminZsh_Banner variable files + 33
  │               animation/effect files, defines random_banner(), then —
  │               once — `[[ -o interactive ]] && { command clear; random_banner }`
  │
  └─ first prompt — precmd chain (empirical order, see section 8):
       1. named function precmd()           (hooks.zsh — duration display)
       2. precmd_functions[1]  _fix_cursor   (keybindings/main.zsh)
       3. precmd_functions[2]  set_bubu_prompt (functions/prompt.zsh)
          (+ Oh My Zsh hooks registered earlier in the array)
```

- Startup banner runs **exactly once per interactive shell** — only at the end of
  `.zshrc`. It is not in `precmd`/`preexec`, and there is no `TRAPWINCH`
  (no re-run on terminal resize).
- Non-interactive `zsh -c …` skips `.zshrc` entirely (verified: no banner).
- A new terminal tab = a new interactive shell = a new banner (intended meaning
  of "per new session").

---

## 4. .zshenv

Two `.zshenv` files exist:

**A. `~/.zshenv` (always loaded first, 1 line):**
```zsh
export ZDOTDIR=$HOME/.config/zsh
```

**B. `config/zsh/.zshenv` → deployed as `~/.config/zsh/.zshenv`:**
```zsh
export ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export TERM=kitty
```

File B is read **only when `ZDOTDIR` is already exported** (nested shells).
Empirical proof:

```
$ env -i HOME=… TERM=foo zsh -c 'echo $TERM'             → TERM=foo    (B not read)
$ env ZDOTDIR=~/.config/zsh TERM=foo zsh -c 'echo $TERM' → TERM=kitty  (B read)
```

```text
Problem:
TERM is forced to `kitty`.

Location:
config/zsh/.zshenv line 10

Current behavior:
Dead code in first-level shells, but forces TERM=kitty in every nested zsh
shell (ZDOTDIR is inherited). config/exports.zsh then patches TERM back to
xterm-256color, so nested shells end with a wrong TERM while first-level
shells keep the terminal's native TERM — inconsistent between levels.

Why it is a problem:
GNOME Terminal / VS Code / Debian sessions may receive a value intended for
Kitty; machines without the kitty terminfo entry can break tput/clear.

Recommended future change:
Delete all TERM manipulation; respect the terminal emulator's existing TERM.

Phase:
Phase 1
```

```text
Problem:
LC_ALL and LANG are hard-set to en_US.UTF-8 (twice).

Location:
config/zsh/.zshenv lines 8–9; config/exports.zsh lines 27–28

Current behavior:
Every shell forces en_US.UTF-8.

Why it is a problem:
Minimal Debian/Ubuntu installs may not have en_US.UTF-8 generated; tools then
warn "cannot change locale" or fall back inconsistently.

Recommended future change:
Do not force LC_ALL; set LANG only when the system has not provided one.

Phase:
Phase 1
```

---
## 5. .zshrc

100 lines, 8 numbered steps (full diagram in section 3). Observations:

- Steps 1, 3, 4, 7 use plain `source` **without existence guards** — a missing
  file prints an error but the shell continues (`.zshrc` is not aborted).
- Steps 2/5/6 loops guard with `[[ -f "$mod" ]]` — safe when a directory is empty.
- Step 8 (banner) loops have **no `[[ -f ]]` guard**:
  ```zsh
  for f in "$BANNER_DIR/animations/"*.zsh; do source "$f"; done
  for f in "$BANNER_DIR/text_effects/"*.zsh; do source "$f"; done
  ```
- `BANNER_DIR="$HOME/.config/zsh/TerminZsh_Banner"` hardcodes the location
  instead of using `$ZDOTDIR`.
- `random_banner()` calls `tput cols/lines` with defaults (`80`/`24`) and shows
  a tiny time banner when the terminal is `< 80×20`.
- Last line: `[[ -o interactive ]] && { command clear; random_banner }` —
  `command clear` deliberately bypasses the `clear` override defined in step 6;
  this is what prevents a double banner at startup.

```text
Problem:
Banner loader loops have no file-existence guard and BANNER_DIR is hardcoded.

Location:
.zshrc lines 47, 54–55

Current behavior:
If TerminZsh_Banner is absent or installed outside $HOME/.config/zsh, zsh tries
to `source` a literal glob string and prints errors; banner silently disappears
when ZDOTDIR != $HOME/.config/zsh.

Why it is a problem:
BuBuZsh installs by copying into the user's environment; a hardcoded install
path breaks any non-default ZDOTDIR.

Recommended future change:
Use BANNER_DIR="$ZDOTDIR/TerminZsh_Banner" and add [[ -f "$f" ]] guards —
without touching any file inside TerminZsh_Banner/.

Phase:
Phase 1
```

---

## 6. Config Loading Order

Exact order (all paths under `$ZDOTDIR`):

| # | Source | Purpose | Guarded? |
|---|---|---|---|
| 1 | `config/exports.zsh` | PATH, `EDITOR=nvim`, TERM conversion, locale | no |
| 1 | `config/options.zsh` | history options, **`compinit`**, zstyle, misc | no |
| 2 | `modules/battery.zsh` | defines `battery_status()` | loop-guarded |
| 2 | `modules/command-not-found.zsh` | defines `command_not_found_handler` | loop-guarded |
| 2 | `modules/fzf.zsh` | `eval "$(fzf --zsh)"` + Ctrl-T/Ctrl-F widgets | no (inner) |
| 2 | `modules/nvm.zsh` | sources `~/.nvm/nvm.sh` if present | yes (`[ -s ]`) |
| 2 | `modules/profiler.zsh` | `zmodload zsh/zprof` (loaded always, output off) | n/a |
| 2 | `modules/zoxide.zsh` | `eval "$(zoxide init zsh)"` | no |
| 3 | `config/aliases.zsh` | aliases (after PATH) | no |
| 4 | `config/plugins.zsh` | Oh My Zsh + clipboard plugin | no |
| 5 | `keybindings/main.zsh` | `bindkey -v`, jk, cursor shapes, ^Space, `_fix_cursor` precmd | no |
| 5 | `keybindings/spf.zsh` | spf wrapper + Ctrl-G widget | no |
| 5 | `keybindings/wifi.zsh` | Alt-S/Alt-I widgets | no |
| 6 | `functions/hooks.zsh` | named `preexec`/`precmd` (duration display) | n/a |
| 6 | `functions/prompt.zsh` | `set_bubu_prompt` + `add-zsh-hook precmd` | n/a |
| 6 | `functions/utils.zsh` | `print_banner`, **`clear` override** | n/a |
| 6 | `functions/wifi.zsh` | wifi helper functions | n/a |
| 7 | `themes/prompt.zsh` | **re-sources `functions/prompt.zsh`** | no |
| 8 | banner block in `.zshrc` | 2 variable files + 33 animation files + one-shot run | partial |

Order interactions worth noting:

- `bindkey -v` runs **after** Oh My Zsh (OMZ defaults to emacs) — vi mode wins.
- `zsh-syntax-highlighting` is sourced in step 4 (OMZ), i.e. **not last** —
  its docs ask it to be sourced after everything else; it currently works
  because nothing later redefines widgets, but the arrangement is fragile.
- `_fix_cursor` (step 5) is appended to `precmd_functions` **before**
  `set_bubu_prompt` (step 6) — hook order matters for `$?` (section 8).
- `modules/fzf.zsh` (step 2) binds Ctrl-T/Ctrl-F **before** `bindkey -v`
  (step 5); fzf.zsh then explicitly re-binds `viins`/`vicmd` — consistent
  today, but order-dependent.
- The `clear` override (step 6) exists **before** the banner block (step 8),
  which is why the banner must use `command clear`.

```text
Problem:
functions/prompt.zsh is sourced twice.

Location:
.zshrc step 6 (functions loop) and step 7 (themes/prompt.zsh line 5)

Current behavior:
Loaded twice per startup. `add-zsh-hook` de-duplicates (verified empirically —
precmd_functions contained the hook only once) and the function is simply
redefined, so there is no visible breakage today.

Why it is a problem:
Redundant work and a misleading architecture; it would break the day the file
gains side effects (variables, output, bindkey…).

Recommended future change:
Load the prompt file exactly once (either from the loop or from the theme).

Phase:
Phase 1
```

---

## 7. Prompt System

The prompt is built by **`set_bubu_prompt()`** (`functions/prompt.zsh`),
registered via `add-zsh-hook precmd set_bubu_prompt` and re-evaluated before
every prompt. `themes/prompt.zsh` merely re-sources that file.

Anatomy of `set_bubu_prompt()` (62 lines):

1. `local exit_code=$?` — first statement, captures the previous command's exit.
2. `battery_info=$(battery_status 2>/dev/null)` — **(repo variant only; live
   variant has this line commented out).**
3. venv/conda detection → green `(name)` segment.
4. Git: `git rev-parse --git-dir` → branch via `git branch --show-current`;
   dirty via `git status --porcelain` → **turns the arrow AND the git icon red**.
5. `exit_code != 0` → turns the arrow red (again).
6. User color: root = red, normal = yellow bold.
7. Builds the two-line `PROMPT`:

```
%F{magenta}┌(%F{220}%Bn%f…)-[%F{cyan}%~%f…]<git><battery><ssh>
%F{magenta}└─${prompt_symbol} %f
```

Renders as (live session, observed):

```
┌(archibubu)-[~/bubuzsh]  main  
└─>
```

**Compliance matrix vs. the BuBuZsh final specification:**

| Spec requirement | Current state |
|---|---|
| Arrow `└─>` always exists | ✅ always present, never omitted |
| Arrow color depends ONLY on exit status | ❌ **git-dirty also turns the arrow red** (line 30) |
| Exit 0 → normal arrow, exit ≠ 0 → red arrow | ✅ implemented (line 37–39) |
| Git icon red when dirty, unaffected arrow | ⚠ icon turns red ✅, but arrow does too ❌ |
| No battery in the main prompt | ❌ present in the audited variant (line 14 + 56); live variant comments line 14 but still interpolates `${battery_info}` on line 56 |
| Git checks independent of arrow color | ❌ see above |

```text
Problem:
Git dirty state controls the arrow color.

Location:
functions/prompt.zsh line 30 (inside the `git status --porcelain` branch)

Current behavior:
prompt_symbol="%F{red}>%f" is set both for dirty git and for failed commands.

Why it is a problem:
The BuBuZsh spec requires the arrow color to depend ONLY on the previous
command's exit status; git state must only affect the git icon.

Recommended future change:
Remove the arrow recoloring from the git branch; keep only the git icon
recoloring; keep the exit-status recoloring.

Phase:
Phase 1
```

```text
Problem:
Battery information is displayed in the main prompt.

Location:
functions/prompt.zsh lines 14 and 56 (audited variant); line 56 also in the
live variant

Current battery_info is interpolated into every PROMPT line.

Why it is a problem:
The BuBuZsh spec forbids battery information in the main prompt.

Recommended future change:
Remove ${battery_info} from the PROMPT template. Keep modules/battery.zsh as
an independent optional module (it defines only a pure function — see
section 10).

Phase:
Phase 1
```

```text
Problem:
`${ssh_indicator}` is referenced but never defined anywhere.

Location:
functions/prompt.zsh line 56

Current behavior:
Expands to an empty string (plus stray spaces) every prompt. Grep across the
entire audited tree finds only this one reference.

Why it is a problem:
Dead variable; if `setopt nounset` is ever enabled the prompt will crash with
"ssh_indicator: parameter not set".

Recommended future change:
Either define ssh_indicator (e.g. detect $SSH_CONNECTION) or remove it from
the template.

Phase:
Phase 1
```

```text
Problem:
`battery_info` is assigned without `local`.

Location:
functions/prompt.zsh line 14

Current behavior:
Becomes a global variable that persists between prompts and leaks into the
environment of the interactive session.

Why it is a problem:
Global state from a prompt hook; harmless today, but a hygiene bug that
compounds as the prompt grows.

Recommended future change:
Declare it local (moot once removed from the prompt template).

Phase:
Phase 1
```

---

## 8. Exit Status Handling

**Conclusion: the current implementation is CORRECT — no `$?` bug exists.**

How it works:

- `set_bubu_prompt()` captures `local exit_code=$?` as its **first statement**.
- Hooks are invoked by zsh in this order (empirically observed):
  1. named function `precmd()` (`hooks.zsh`, duration display)
  2. `_fix_cursor` (`precmd_functions[1]`)
  3. `set_bubu_prompt` (`precmd_functions[2]`)
  4. (plus Oh My Zsh hooks registered earlier in the array)

Empirical test (sandboxed config in `/tmp/zshaudit`, run through a real PTY,
feeding `false` then `true`):

```
# after `false`:
A named-precmd sees: 0
B fix_cursor sees: 0
C set_p captured: 1      ← set_p's first line was `local ec=$?`
# after `true`:
C set_p captured: 0
```

Even though earlier hooks ran commands that set `$?` to 0, zsh **restores the
original exit status before entering each `precmd_functions` entry** — so
`set_bubu_prompt` always sees the user's real previous exit code. (The values
printed by hooks A and B are misleading by construction: each hook's last
command before printing had already overwritten `$?` — irrelevant, because only
the first statement of `set_bubu_prompt` matters.)

Other `$?` interactions checked:

| Interaction | Result |
|---|---|
| `preexec` (duration timer) | only sets `cmd_start_time` via `date +%s`; runs **before** the command, cannot corrupt the next prompt's `$?` |
| named `precmd` (duration display) | runs before `set_bubu_prompt` but zsh restores `$?` for the next hook — safe |
| git/battery/external commands inside `set_bubu_prompt` | run **after** `exit_code` is captured — safe |
| double-sourcing of `functions/prompt.zsh` | `add-zsh-hook` de-duplicates (verified) — `set_bubu_prompt` executes once per prompt |
| first prompt of a new shell | `$?` = 0 → normal arrow (correct) |

No fix required in Phase 1 for exit-status capture itself; it must simply be
**preserved** when the prompt is refactored (keep `local exit_code=$?` as the
first line, or move to a `precmd` that stores it before anything else runs).

---

## 9. Git Integration

Detection chain inside `set_bubu_prompt()` (runs on **every** prompt):

```zsh
if git rev-parse --git-dir >/dev/null 2>&1; then          # (1) repo?
    branch_name=$(git branch --show-current 2>/dev/null)   # (2) branch
    git_branch=" %F{cyan}%f %F{blue}$branch_name%f"
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then# (3) dirty?
        prompt_symbol="%F{red}>%f"                         # (4) ⚠ arrow red
        git_branch=" %F{red}%f %F{blue}$branch_name%f"
    fi
fi
```

Audit answers:

- **Repository detection:** `git rev-parse --git-dir`, output suppressed,
  guarded by `2>&1` — outside a repository it fails silently, prints nothing,
  and the git segment stays empty. ✅ safe outside repos.
- **Branch info:** `git branch --show-current` (requires git ≥ 2.22, released
  2019 — fine for all target distros). Empty on detached HEAD (icon alone
  shows, no branch name).
- **Dirty detection:** `git status --porcelain` — full worktree scan
  (including untracked files) on **every prompt**.
- **Does git change arrow color?** ❌ **YES — spec violation** (line 30,
  documented in section 7).
- **Are git checks expensive?** 1–3 `git` forks per prompt. 0.00s in this tiny
  repo, but `git status` scales with repository size/untracked count — on large
  repos it is the classic source of prompt lag. No async/timeout/caching used.
- Repo contains an `.oh-my-zsh` `git` plugin (prompt themes unused since
  `ZSH_THEME=""`).

```text
Problem:
Git status work runs synchronously on every prompt with no caching or guard.

Location:
functions/prompt.zsh lines 24–33

Current behavior:
Up to 3 external git processes fork before every prompt whenever cwd is inside
a repository; `git status --porcelain` scans the whole worktree each time.

Why it is a problem:
Prompt latency grows with repository size; the final BuBuZsh prompt must stay
lightweight.

Recommended future change:
Phase 1+: cache dirty-state per directory, use `git status --porcelain -uno`
or an async/zsh-native check, and skip the dirty check when only the branch is
needed. Keep behavior synchronous-compatible (results must be correct by the
time the prompt draws, or use zsh-async with a redraw).

Phase:
Phase 2 (after Phase 1 correctness fixes)
```

---

## 10. Battery Integration

`modules/battery.zsh` (58 lines) defines exactly one function — **`battery_status()`**:

- Reads `/sys/class/power_supply/BAT0/capacity` and `…/status` (2 `cat`
  subprocesses inside a command substitution).
- Selects a Nerd-Font icon per capacity bracket (95/90/80/…/10 %) and a color
  per state: Charging/Full = green, <10 % red, <20 % yellow, <30 % orange,
  otherwise cyan.
- **No battery present** (desktop / BAT0 missing) → returns a blue plug icon
  `%F{blue}󰒒%f` — i.e. it never errors, it degrades to an icon.
- Loading the module has **zero side effects**: no hooks, no globals, no
  keybindings — it is a pure function file.

Prompt integration (audited variant):

```zsh
battery_info=$(battery_status 2>/dev/null)   # line 14 — commented out in LIVE variant
…
PROMPT="…${git_branch} ${battery_info} ${ssh_indicator}…"   # line 56 — both variants
```

Audit answers required by the spec:

```text
Problem:
Battery information is shown in the main prompt (audited variant).

Location:
functions/prompt.zsh lines 14 + 56

Current battery_info text is part of PROMPT line 1 (the live variant already
comments out line 14 but still interpolates the empty ${battery_info} on 56).

Why it is a problem:
BuBuZsh final spec: "Battery information → NOT displayed in the main prompt".

Recommended future change:
Remove ${battery_info} from the PROMPT template (and the now-unused capture).
Keep modules/battery.zsh loaded as an independent OPTIONAL module — it is
already side-effect-free and can remain available for opt-in use (e.g. a
toggleable segment or a `battery` command).

Phase:
Phase 1
```

```text
Problem:
Battery device name BAT0 is hardcoded.

Location:
modules/battery.zsh lines 4–6

Current behavior:
Only /sys/class/power_supply/BAT0 is probed; machines naming their battery
BAT1 (or using BAT0+BAT1) get the "desktop" plug icon despite having a battery.

Why it is a problem:
Wrong (though harmless) output on some laptops; limits portability.

Recommended future change:
If the module is kept: glob /sys/class/power_supply/BAT*/ instead of a fixed
name. Not urgent — module is being removed from the prompt anyway.

Phase:
Phase 2 (optional module polish)
```

---

## 11. Banner System (PROTECTED)

**`TerminZsh_Banner/` was treated as a protected component: inspected only.
No file in it was modified, renamed, moved, deleted, or rewritten.** Its
integration with Zsh was traced as follows.

Inventory (144 K total):

| Part | Count | Role |
|---|---|---|
| `asciibanners.zsh` | `Banner_1`…`Banner_13` (13) | global variables holding ASCII headers |
| `textbanners.zsh` | `Text_1`…`Text_4` (4) | global variables holding quote lines |
| `animations/*.zsh` | 21 files → `header_*()` functions | header animation effects |
| `text_effects/*.zsh` | 12 files → `text_*()` functions | quote animation effects |

Integration points (all in `.zshrc` step 8 — *outside* the protected dir):

1. `BANNER_DIR="$HOME/.config/zsh/TerminZsh_Banner"` (line 47).
2. Source the two variable files (guarded with `[[ -f ]]`).
3. Source every `animations/*.zsh` and `text_effects/*.zsh` (unguarded loops —
   reported in section 5 as an *integration* issue, not a banner issue).
4. Define `random_banner()` in `.zshrc`:
   - `tput cols/lines` (defaults 80/24 if tput fails);
   - if `< 80×20` → print only the small `🌺 HH:MM 🌾` time banner and return;
   - else pick 1 random `Banner_*` + 1 random `Text_*` + 1 random `header_*`
     function + 1 random `text_*` function via `$RANDOM`, run header first,
     then the text effect.
5. Run exactly once: `[[ -o interactive ]] && { command clear; random_banner }`.

**Two banner behaviors (documented separately, per spec §4):**

| Behavior | Implementation | Verified |
|---|---|---|
| **Startup banner** | One random animated banner, executed only at the end of `.zshrc` for interactive shells | ✅ Observed exactly one banner per new interactive session (`zsh -i -c exit` through PTY → single banner). Not in `precmd`/`preexec`; no `TRAPWINCH`; not re-run on prompt redraw, resize, or `clear`. |
| **`clear` command** | `function clear { command clear; print_banner }` in `functions/utils.zsh` — plain clear → static text banner (the “Trust your heart…” line, or the small time banner on <80-col terminals) → prompt redrawn by `precmd` | ✅ `clear` never calls `random_banner` (grep: `random_banner` referenced only in `.zshrc` line 100). The large startup animation is NOT triggered by `clear`. Startup uses `command clear` to bypass the override — no double banner. |

The current source **already follows the required behavior**:
`clear screen → existing text banner → prompt`, and startup animation exactly
once per new session.

Animation technique (read-only inspection): `printf "\033[H\033[J"` full-screen
redraws, `tput civis/corm` cursor hide/show, `sleep 0.01–0.05` per frame,
`$RANDOM`-driven scrambling, `tr`-based character substitution. All output is
raw ANSI + terminfo — **no Kitty-specific sequences anywhere in the banner
directory** (grep for `kitty` and `/home/` returned zero hits).

Measured cost of a full animation run (PTY sized 100×30, complete startup):
**1.76 s wall** (vs. 0.40–0.48 s warm startup when the small-banner fallback
path is taken).

Notes (inspection only — nothing changed):

- `animations/header_expand.zsh.zsh` is a stray duplicate filename; the glob
  `*.zsh` loads **both** `header_expand.zsh` and `header_expand.zsh.zsh`
  (alphabetical order → the doubled one wins). Documented, not touched.
- All 21 animation files use `sleep` — banner duration depends on which random
  combination is picked.
- The protected directory contains no external commands besides `tput`, `tr`,
  `date`, `sleep` (all core system tools).

---

## 12. clear Command

Implementation — `functions/utils.zsh` (complete):

```zsh
print_banner() {
    local cols=$(tput cols 2>/dev/null || echo 80)
    if [[ $cols -ge 80 ]]; then
        printf "\e[0m\e[1;36m🌺 Trust your heart if the sea catch fire,…🌸🌾 …\e[0m\n"
    else
        printf "\e[0;36m🌺 $(date +%H:%M) 🌾\e[0m\n"
    fi
}

function clear {
    command clear
    print_banner
}
```

Resulting behavior:

```
clear
  ↓ command clear        (real screen wipe — bypasses the function, no recursion)
  ↓ print_banner         (static text banner, or small time banner <80 cols)
  ↓ return → precmd runs → set_bubu_prompt rebuilds PROMPT → prompt drawn
```

Audit verdict — **the current source already follows the required behavior:**

| Requirement | Status |
|---|---|
| `clear` → clear screen → existing **text** banner → prompt | ✅ exactly this |
| `clear` must NOT trigger the large startup animation | ✅ `random_banner` is referenced only from `.zshrc` line 100 (startup) |
| Startup animation not re-run from `precmd`/`preexec`/redraw/resize | ✅ see section 11 |
| No double banner at startup (`command clear` bypass) | ✅ verified statically and in captured PTY runs |

Notes (not problems): the `clear` override only exists in interactive shells
(it lives in `.zshrc`-loaded files), so scripts calling `clear` are unaffected;
`alias love='clear && myfetch …'` goes through the override (quote banner +
fetch output). No changes made or needed in Phase 0.

---

## 13. Terminal Compatibility

Inventory of every terminal-related assumption in the audited configuration:

| Location | Assumption | Portable to GNOME Terminal? |
|---|---|---|
| `config/zsh/.zshenv:10` | `export TERM=kitty` (nested shells only — section 4) | ❌ forces Kitty's value |
| `config/exports.zsh:25` | `[[ $TERM == kitty ]] && export TERM=xterm-256color` | ⚠ rewrites native TERM (see block below) |
| `keybindings/main.zsh` | DECSCUSR cursor escapes `\e[2 q` (block) / `\e[6 q` (beam) | ✅ supported by Kitty and GNOME Terminal (VTE ≥ 0.52); harmless elsewhere |
| `keybindings/main.zsh` | `_fix_cursor` emits beam cursor on every prompt | ✅ same escape, safe |
| prompt/battery/`eza --icons` | Nerd Font glyphs (``, `󰁹`, `┌└`) + 256 colors (`%F{220}`) | ⚠ code is fine, but **both terminals must use a Nerd Font** |
| banner dir + `print_banner` | raw ANSI (`\e[…m`, `\033[H\033[J`) + `tput` terminfo | ✅ no Kitty-specific sequences found (grep `kitty` = 0 hits in `TerminZsh_Banner/`) |
| anywhere | `KITTY_WINDOW_ID`, `KITTY_*`, `kitten`, `icat`, `TERM=xterm-kitty` handling | **none found** — no Kitty detection at all |
| `modules/fzf.zsh` widgets | `\e[1;35m` colors in preview | ✅ plain ANSI |

There is **no** `TERM=kitty` forcing at first shell level (`.zshenv` A never
sets TERM); the forcing appears only in nested shells and is immediately
band-aided by `exports.zsh`. That two-file contradiction is the entire
terminal-specific story — everything else is already cross-terminal.

```text
Problem:
exports.zsh rewrites TERM when it equals "kitty".

Location:
config/exports.zsh line 25

Current behavior:
[[ "$TERM" == "kitty" ]] && export TERM=xterm-256color — an intentional
band-aid for the .zshenv line. In nested shells: TERM is forced to kitty by
.zshenv, then immediately rewritten to a generic value; in first-level shells
the line never fires and the native TERM survives.

Why it is a problem:
The native TERM (e.g. xterm-kitty, gnome-256color, vscode) is lost in nested
shells; behavior differs per shell level; the code exists only to undo another
bug. GNOME Terminal in a nested zsh gets xterm-256color instead of its own
value.

Recommended future change:
Delete line 25 together with the `.zshenv` TERM line (Phase 1). Respect the
terminal emulator's TERM everywhere.

Phase:
Phase 1
```

```text
Problem:
Prompt assumes a Nerd Font is installed in the terminal.

Location:
functions/prompt.zsh, modules/battery.zsh, config/aliases.zsh (eza --icons)

Current behavior:
Glyphs such as , 󰁹, ┌└ render as tofu boxes unless the terminal font is a
Nerd Font-patched face.

Why it is a problem:
Kitty and GNOME Terminal must both be configured with a Nerd Font; this is an
undocumented environment requirement, not a code bug.

Recommended future change:
Document the font requirement in the BuBuZsh README/installer checks; no code
change required.

Phase:
Phase 1 (documentation)
```

---

## 14. Cross-Distro Compatibility

Distro-specific code inventory (target matrix: Arch / Debian / Ubuntu):

| Location | Distro assumption | On Debian/Ubuntu |
|---|---|---|
| `config/aliases.zsh:7` | `update='sudo pacman -Syu'` | fails only when used; no apt equivalent provided |
| `config/aliases.zsh:30–36` | 7 `pacman` aliases (`pacupf`, `pacmanrm`, `pacmanss`, `pacmani`, `pacq`, `pacql`, `pacinfo`) | fail when used; no `apt` aliases exist |
| `config/aliases.zsh:41–45` | 5 `yay` aliases (`yupdate`, `yinstall`, `yremove`, `yclean`, `ysearch`) | AUR helper absent; fail when used |
| `config/aliases.zsh:15` | `hr='hyprctl reload'` | Hyprland-only (desktop, not distro — GNOME target lacks `hyprctl`) |
| `config/aliases.zsh:8` | `love='clear && myfetch …'` | `myfetch` is a custom tool — **missing even on this Arch machine** |
| `modules/command-not-found.zsh` | pacman search/install UX behind `if command -v pacman` | ✅ graceful fallback: plain "Command not found" message |
| `modules/nvm.zsh:7–9` | npmmirror.com node/electron mirrors | network-region assumption, unrelated to distro |
| `hyprbuti/scripts/install-zsh.sh` | `sudo pacman -S`, `git clone`, `chsh` | installer is Arch-only (`archysetup.sh`, `install-yay.sh`, `mainstaller` likewise) |
| `config/zsh/.zshenv` + `exports.zsh` | `LANG/LC_ALL=en_US.UTF-8` | minimal Debian/Ubuntu may lack the locale (reported in section 4) |

There is **no** `apt`/`apt-get`/`dnf`/`paru` reference anywhere in the audited
zsh configuration (18 hits total for `pacman|yay`, confined to
`config/aliases.zsh`, `modules/command-not-found.zsh`, and hyprbuti install
scripts). `apt`/`apt-get` happen to exist on this machine but are never
referenced by the zsh config.

```text
Problem:
Arch-only assumptions are baked into shared alias files (and the whole
hyprbuti installer).

Location:
config/aliases.zsh lines 7–45; modules/command-not-found.zsh; hyprbuti/scripts/*

Current behavior:
pacman/yay/hyprctl/myfetch aliases and the pacman-based package-search UX are
loaded unconditionally on every system; the installer only knows pacman.

Why it is a problem:
BuBuZsh must support Debian and Ubuntu; the aliases are dead weight there and
the installer cannot run at all.

Recommended future change:
Split aliases into distro-detected groups (e.g. loaded only when pacman
exists, apt aliases when apt exists); keep the existing command-not-found
fallback design (it already degrades correctly). Write a new copy-based,
distro-aware installer for BuBuZsh — do not port mainstaller as-is.

Phase:
Phase 1 (aliases) / Phase 2 (installer)
```

```text
Problem:
The interactive command-not-found handler runs inside command substitutions
and blocks on `read -k1`.

Location:
modules/command-not-found.zsh (`read -k1 choice` calls), triggered via
.zshrc step 4 `eval "$(fzf --zsh)"`, step 2 `eval "$(zoxide init zsh)"`, and
every prompt's `git …` calls when the binary is missing.

Current behavior:
Empirically verified: zsh invokes command_not_found_handler even for commands
inside `$( … 2>/dev/null)` in interactive shells (sandbox marker test wrote the
marker). Because the handler's stdout is captured by the substitution
(invisible) while `read -k1` reads the real terminal, a missing fzf/zoxide/git
on a pacman system makes startup or the prompt silently wait for a keypress.
On non-pacman systems the handler returns without reading, leaving only noise.

Why it is a problem:
Missing optional tools (or git) can appear as a frozen shell instead of a
clean degradation — directly against the "optional feature disappears
gracefully" requirement.

Recommended future change:
Guard optional tools (`(( $+commands[fzf] )) && eval …`), make the handler
refuse to run when stdin is not a terminal / inside substitutions, and never
let prompt-time git calls reach the handler (guard with `command -v git`).

Phase:
Phase 1
```

---

## 15. Dependencies

Commands referenced by the audited configuration (verified present on this
machine except where noted):

### Required — the system cannot reasonably work without these

| Command | Used by | If missing |
|---|---|---|
| `zsh` (5.9 tested) | everything | no shell |
| `clear` (ncurses) | startup (`command clear`), `clear` override | banner/clear break |
| `tput` (terminfo) | `random_banner`, `print_banner` | guarded → defaults 80/24; degrades to small banner |
| coreutils: `date`, `tr`, `sleep`, `head`, `cut`, `awk`, `grep`, `basename` | banner animations, hooks, wifi, CNF | individual features break |

### Recommended — intended BuBuZsh experience, not strictly essential

| Command | Used by | If missing |
|---|---|---|
| `git` | prompt git segment | ⚠ CNF-handler risk (section 14 block) — must be guarded |
| Oh My Zsh + autosuggestions + syntax-highlighting + system-clipboard | `config/plugins.zsh`, `^Space` binding | startup error messages; widgets missing; shell still starts |
| Nerd Font (terminal-side) | all icons | tofu boxes (section 13) |
| `fzf` + `fd` | `modules/fzf.zsh` Ctrl-T/Ctrl-F | ⚠ startup hang risk via CNF handler (section 14 block) |
| `eza` | `e/ea/el…` aliases, fzf previews | aliases fail when used |
| `bat` | fzf file preview | preview errors |
| `zoxide` | `modules/zoxide.zsh` | ⚠ same CNF risk / noise |
| `nvim` | `EDITOR`/`VISUAL`, fzf opener | editor commands fail when used |

### Optional — feature can safely disappear

| Command | Feature |
|---|---|
| `exiftool`, `mediainfo` | fzf previews (images/video/pdf) |
| `xdg-open` | opening media from fzf |
| `spf` (superfile) | Ctrl-G file manager (runtime only) |
| `iwgetid`, `ip`, NetworkManager | wifi functions/widgets (Alt-S/Alt-I) |
| `nvm`/node | `modules/nvm.zsh` — properly guarded with `[ -s ]` ✅ |
| `pacman`/`yay` | Arch aliases + CNF package search — guarded `command -v` ✅ |
| `hyprctl` | `hr` alias (Hyprland) |
| `myfetch` | `love` alias — missing even on this machine |
| `curl`, `wget`, `vim`, `paru`, `apt`, `apt-get` | **not referenced anywhere** by the zsh config (installer uses `git clone`) |

Code that misbehaves when an optional command is missing — each reported as a
problem block: unguarded `eval "$(fzf --zsh)"`, `eval "$(zoxide init zsh)"`,
`source $ZSH/oh-my-zsh.sh` (also unquoted), the clipboard plugin `source`, and
`bindkey … autosuggest-accept` (widget error without OMZ). None abort
`.zshrc`, but they print errors — or hang via the CNF handler — instead of
degrading silently.

```text
Problem:
Optional/plugin sources are unguarded in .zshrc-loaded files.

Location:
config/plugins.zsh lines 8 and 11; modules/fzf.zsh line 10;
modules/zoxide.zsh line 4; keybindings/main.zsh line 17

Current behavior:
Each missing dependency produces startup error messages ("no such file", "no
such widget", "command not found") or a silent hang via the CNF handler
(section 14). Today all dependencies exist, so nothing shows.

Why it is a problem:
The BuBuZsh spec requires optional features to disappear safely when their
command is unavailable.

Recommended future change:
Wrap every optional source/eval/bindkey in existence checks:
[[ -f … ]], (( $+commands[fzf] )), (( $+widgets[autosuggest-accept] )).
Also quote "$ZSH/oh-my-zsh.sh".

Phase:
Phase 1
```

---

## 16. Hardcoded Paths / Usernames

Search performed: `grep -rE '/home/[a-z]+|archibubu|bubu|love|niribubu'`
across the audited tree (banner dir included, then excluded to separate
concerns).

### In code (audited variant)

| Location | Value | Verdict |
|---|---|---|
| `.zshenv:5` | `ZDOTDIR:-$HOME/.config/zsh` | ✅ portable form (`$HOME`) |
| `.zshrc:47` | `BANNER_DIR="$HOME/.config/zsh/TerminZsh_Banner"` | ⚠ assumes layout equals `$HOME/.config/zsh` regardless of `$ZDOTDIR` (block in section 5) |
| `config/plugins.zsh:3` | `export ZSH="$HOME/.oh-my-zsh"` | ✅ `$HOME`, conventional OMZ location |
| `config/plugins.zsh:11` | `${ZSH_CUSTOM:-~/.zsh}/plugins/zsh-system-clipboard/…` | ⚠ fallback `~/.zsh` is a stale hardcoded path (block below) |
| `config/options.zsh:4` | `HISTFILE="$ZDOTDIR/.zhistory"` | ✅ portable |
| `config/exports.zsh:7–8` | `$HOME/.local/bin`, `$HOME/.npm-global/bin` | ✅ `$HOME` |
| `modules/nvm.zsh:2` | `$HOME/.nvm` | ✅ `$HOME` |
| `keybindings/spf.zsh:9` | `${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir` | ✅ XDG-correct |
| anywhere | `/home/archibubu`, `/home/bubu`, `/home/love` literals | ✅ **none found in code** |
| `config/aliases.zsh:8` | `alias love=…` | ✅ command name, not a path |
| `.zcompdump-love-5.9*` | `love` = original hostname | ⚠ runtime artifact, not code (must not ship) |

### Outside code (live environment / installer)

| Location | Value | Verdict |
|---|---|---|
| `~/.config/zsh/` live | 6 dangling symlinks → `/home/bubu/niribubu/.config/zsh/…` (`.aliases`, `.aliases.local`, `.xdg.local`, `.zprofile`, `.zprofile.local`, `.zshrc.local`) | ❌ foreign-machine absolute paths; target does not exist |
| `hyprbuti/scripts/archysetup.sh:6` | `REPO="$HOME/hyprbuti/config"` | ⚠ hardcoded repository path |
| `hyprbuti/scripts/install-zsh.sh` | clones to fixed `$HOME/.oh-my-zsh`, `$ZSH_CUSTOM/...` | acceptable but Arch-only |

```text
Problem:
plugins.zsh falls back to a stale `~/.zsh` plugin path.

Location:
config/plugins.zsh line 11

Current behavior:
source "${ZSH_CUSTOM:-~/.zsh}/plugins/zsh-system-clipboard/zsh-system-clipboard.zsh"
— if ZSH_CUSTOM were unset (OMZ missing/not yet sourced), it looks in ~/.zsh,
a directory that does not exist on this machine (verified: no ~/.zsh/plugins).

Why it is a problem:
Another hardcoded location that only worked on the original machine's layout;
silently contributes a startup error when OMZ is absent.

Recommended future change:
Resolve the plugin path relative to $ZSH_CUSTOM only, guard with [[ -f ]].

Phase:
Phase 1
```

```text
Problem:
Live configuration contains dangling symlinks to another machine's /home.

Location:
~/.config/zsh/{.aliases,.aliases.local,.xdg.local,.zprofile,.zprofile.local,
.zshrc.local} → /home/bubu/niribubu/…

Current behavior:
All six targets are missing; zsh silently skips nonexistent startup files, so
nothing visibly breaks — but the links are dead and reference absolute paths
of a different user/machine.

Why it is a problem:
BuBuZsh must use copied configuration files (no symlinks, no Stow, no
hardcoded repo paths). These must not be reproduced or copied into the new
project.

Recommended future change:
When the Phase 1 baseline is chosen, build BuBuZsh from plain files only;
installer must copy (not link). Optionally clean the dead links from the live
environment in a later phase (user-approved action).

Phase:
Phase 1 (hygiene rule) / Phase 2 (cleanup)
```

```text
Problem:
hyprbuti installer hardcodes the repository location.

Location:
hyprbuti/scripts/archysetup.sh line 6 (REPO="$HOME/hyprbuti/config")

Current behavior:
The setup script only works if the repo was cloned to ~/hyprbuti; the zsh
special-case copies ONLY `.zshrc` into $HOME and `continue`s — it never
deploys the rest of the config into ~/.config/zsh, so the live layout was
clearly produced by additional manual steps.

Why it is a problem:
Deployment method is implicit, partly manual, and not reproducible — and the
BuBuZsh spec requires a copy-based installer with no hardcoded repository
paths.

Recommended future change:
Design a fresh installer in Phase 2: detect repo location, copy files into
$ZDOTDIR/$HOME with backups, no symlinks, distro-aware.

Phase:
Phase 2
```

**Symlink / Stow check (spec §13):** the hyprbuti installer uses `cp`/`mv`
exclusively — **no GNU Stow, no symlink-based installation** in the source
project ✅. The only symlinks found are the six dead ones in the live
environment (above), which came from a different setup — they must not be
carried over.

---

## 17. Performance Concerns

### Measurements (this machine, audited config copied to `/tmp`)

| Scenario | Wall time |
|---|---|
| `zsh -c exit` (non-interactive, no rc files) | ~0.00 s (baseline) |
| `zsh -i -c exit`, warm (compinit dump exists), small-banner fallback path | **0.40–0.48 s** (3 runs) |
| `zsh -i -c exit`, first run (compinit had to build `.zcompdump`) | 1.37 s |
| `zsh -i -c exit`, full-size PTY (100×30) → **complete startup animation** | **1.76 s** |
| `git status --porcelain` + `git rev-parse` in this repo | <0.01 s (tiny repo) |

### What runs at shell startup (every interactive shell)

1. `compinit` (step 1) — full completion system init; **Oh My Zsh runs its own
   `compinit` again** inside `oh-my-zsh.sh` → effectively two compinit passes
   per startup.
2. Oh My Zsh load (step 4) — largest single framework cost.
3. `eval "$(fzf --zsh)"` and `eval "$(zoxide init zsh)"` — two external process
   forks + eval.
4. `modules/nvm.zsh` — sources `~/.nvm/nvm.sh` (bash script, tens of ms).
5. `modules/profiler.zsh` — `zmodload zsh/zprof` always loaded although `zprof`
   output is commented out (small but pointless).
6. Banner block (step 8) — sources **2 + 33 files** (144 K) on every startup,
   then the animation itself (up to ~1.3 s of `sleep`-driven frames + 2 `tput`
   calls + `date`).
7. No network commands, no package-manager queries, no filesystem walks at
   startup ✅.

### What runs before every prompt (`precmd`)

| Work | Cost per prompt |
|---|---|
| named `precmd()` duration hook — `$(date +%s)` (only when `cmd_start_time` set, i.e. after any command) | 1 fork (`date`) — runs even when the result is never displayed (<5 s) |
| `_fix_cursor` — `echo -ne '\e[6 q'` | builtin, free |
| `set_bubu_prompt` — `battery_info=$(battery_status)` (audited variant): command substitution + 2 × `cat` | ~3 forks |
| `set_bubu_prompt` — `git rev-parse --git-dir` | 1 fork |
| `set_bubu_prompt` — `git branch --show-current` (in repos) | 1 fork |
| `set_bubu_prompt` — `git status --porcelain` (in repos, unguarded full scan) | 1 fork + worktree scan |
| **Total in a repo (audited variant)** | **≈ 6–7 forks + a full `git status` scan per prompt** |

### What runs per command (`preexec`)

- `date +%s` → 1 fork per executed command (timer start).

### Not present (good)

- No network calls, no `pacman`/`apt` calls, no `sysinfo`/fetch at prompt time.
- No `TRAPWINCH`, no per-prompt `tput` (only at startup/`clear`).
- Banner is one-shot, not per-prompt.

```text
Problem:
Every prompt performs several unconditional subprocess forks, including a
`date` call whose result is only displayed for commands >5 s, and a full
`git status` scan in repositories.

Location:
functions/hooks.zsh lines 13–14 (date); functions/prompt.zsh lines 14, 24–33
(battery + git)

Current behavior:
~6–7 forks per prompt inside a git repository (audited variant); git scan cost
grows with repository size.

Why it is a problem:
The final BuBuZsh prompt must remain lightweight; fork storms are the main
source of perceptible prompt lag on large repos / slow hardware.

Recommended future change:
Phase 2: only compute duration when it will be shown, cache git dirty state
or make it async, drop battery from the prompt (Phase 1), consider zsh-native
alternatives to `$(cat …)`.

Phase:
Phase 2
```

```text
Problem:
Startup loads everything unconditionally and initializes the completion system
twice.

Location:
config/options.zsh line 16 (compinit), config/plugins.zsh (OMZ also compinit),
modules/*.zsh loop, .zshrc step 8 (33 banner files sourced per startup)

Current behavior:
0.40–0.48 s warm startup; 1.37 s when compinit rebuilds its dump; 1.76 s with
the full animation. Two compinit passes and 35 banner file-sources happen
every time.

Why it is a problem:
All target distros/terminals should feel instant; the cost will be worse on
older hardware or right after OS updates.

Recommended future change:
Phase 2: single compinit with an explicit dump file + `compinit -C` fast path;
lazy-load nvm; keep banner sourcing (protected behavior) but consider a
compiled `.zwc` cache of the banner functions; drop `zsh/zprof` from normal
startup. Do NOT change animation timing (protected).

Phase:
Phase 2
```

---

## 18. Multi-Session Safety

Audit of everything shared between simultaneously open terminal sessions:

| State | Shared? | Verdict |
|---|---|---|
| Startup banner | No files, no flags — pure `$RANDOM` in each shell's memory; executed once per shell at `.zshrc` end | ✅ **startup-banner state is truly per interactive session** — two terminals can never trigger or suppress each other's banner |
| `cmd_start_time` | plain shell variable, per-process | ✅ safe |
| `set_bubu_prompt` / PROMPT | per-process | ✅ safe |
| `.zhistory` | shared **by design** (`SHARE_HISTORY` + `INC_APPEND_HISTORY`) — 1.8 MB live file, appended by every session | ✅ intended behavior; zsh handles append concurrency |
| `.zcompdump` | shared dump file; rewritten when stale — concurrent startups *can* race on the write | ⚠ possible (block below), cosmetic risk |
| `SPF_LAST_DIR` (`keybindings/spf.zsh`) | shared file under `$XDG_STATE_HOME/superfile/lastdir` | ⚠ two concurrent `spf` sessions can clobber each other's last-dir (only affects `spf`'s cd-back) |
| Terminal resize | no `TRAPWINCH`; banner never re-evaluated | ✅ |
| `clear` in session A | affects only A's screen | ✅ |
| Environment exports (`PATH`, `EDITOR`…) | per-process (children inherit) | ✅ |

```text
Problem:
Shared completion dump file can be written by concurrent shell startups.

Location:
config/options.zsh line 16 (`autoload -Uz compinit && compinit`)

Current behavior:
Every new shell runs compinit against the same `$ZDOTDIR/.zcompdump*`; if two
sessions start simultaneously while the dump is stale, both may rewrite it
concurrently. Several stale dump variants already litter the live directory
(.zcompdump, -love-5.9, -love-5.9.1, -love-5.9.2, .zwc files).

Why it is a problem:
A torn/partial dump can degrade one session's completion init; the artifact
litter also leaks into the BuBuZsh repository copy.

Recommended future change:
Phase 2: one explicit dump file (ZSH_COMPDUMP), `compinit -C` fast path after
first build, and .gitignore all dump/history artifacts in the repo.

Phase:
Phase 2
```

---

## 19. Bugs Found

### Confirmed bugs (verified from source and/or empirically)

1. **Undefined `${ssh_indicator}` in the prompt template** — section 7 block.
2. **`TERM=kitty` forced in `$ZDOTDIR/.zshenv`** (nested shells) — section 4 block.
3. **`exports.zsh` rewrites native TERM** as a band-aid — section 13 block.
4. **Git dirty state recolors the arrow** (spec violation) — section 7 block.
5. **Battery shown in the main prompt** (spec violation, audited variant) — sections 7/10 blocks.
6. **Banner loader loops unguarded + `BANNER_DIR` hardcoded** — section 5 block.
7. **CNF handler fires inside command substitutions → silent startup/prompt
   hang when fzf/zoxide/git is missing (pacman systems)** — section 14 block
   (handler invocation inside `$(…)` verified with a marker test; the
   `read -k1` blocking follows directly from the handler code).
8. **Unguarded OMZ/clipboard/fzf/zoxide/autosuggest sources** — section 15 block.
9. **Live config dangling symlinks to `/home/bubu/niribubu/…`** — section 16 block.
10. **hyprbuti installer: hardcoded repo path + incomplete zsh deployment**
    (copies only `.zshrc` to `$HOME`, never populates `~/.config/zsh`) — section 16 block.
11. **Double-sourcing of `functions/prompt.zsh`** (harmless today thanks to
    `add-zsh-hook` de-duplication — confirmed empirically) — section 6 block.
12. **Stale `~/.zsh` fallback path in `plugins.zsh`** — section 16 block.

### Possible issues (not fully provable without changing state)

| # | Issue | Evidence | Risk |
|---|---|---|---|
| P1 | `battery_info` not declared `local` (global leak) | section 7 block | low |
| P2 | `SHARE_HISTORY` + `INC_APPEND_HISTORY` set together (historically conflicting pair; zsh resolves toward sharing, but intent is muddy) | `options.zsh:7–8` | low, cosmetic |
| P3 | `LC_ALL=en_US.UTF-8` on locale-less Debian/Ubuntu | section 4 block | medium on fresh installs |
| P4 | `git branch --show-current` empty on detached HEAD → icon without branch name (arguably intended) | `prompt.zsh:26` | low |
| P5 | Live-only: `QT_QPA_PLATFORMTHEME` exported twice (qt5ct then immediately overwritten by qt6ct — the first is dead) | live `exports.zsh` | low (outside audited baseline) |
| P6 | `alias love` references `myfetch`, absent even on this machine | `aliases.zsh:8` | fails only when invoked |
| P7 | `keybindings/main.zsh` binds `^ ` to `autosuggest-accept`, which only exists after OMZ loads — ordering works today, no existence check | `main.zsh:17` | errors if OMZ removed |
| P8 | `header_expand.zsh.zsh` duplicate file silently overrides `header_expand.zsh` (protected dir — documented, **NOT touched**) | banner glob order | cosmetic |

**No bug found in exit-status capture** (section 8), and **no deviation from
the required `clear` / startup-banner behavior** (sections 11–12) — both
verified empirically.

---

## 20. Components To Preserve

| Component | Why |
|---|---|
| **`TerminZsh_Banner/` in its entirety** | Protected by spec §3 — animations, timing, effects, content all untouched in Phase 0 and must stay untouched unless explicitly ordered later |
| **Startup-banner integration pattern** | `[[ -o interactive ]] && { command clear; random_banner }` at `.zshrc` end = exactly-once semantics already correct; `command clear` bypass prevents double banners |
| **`clear` → text banner → prompt behavior** (`functions/utils.zsh`) | Exactly the behavior required by spec §4 — implemented and verified |
| **Exit-status capture pattern** (`local exit_code=$?` as first line of `set_bubu_prompt`) | Empirically proven correct (section 8) — must survive any prompt refactor |
| **Modular `.zshrc` architecture** (numbered steps, directory loops, `ZDOTDIR`-relative sourcing) | Clean, greppable loading order — the right skeleton for BuBuZsh |
| **Prompt visual identity** | Two-line layout `┌(user)-[path] <git>` / `└─>`, magenta/yellow/cyan palette, root-vs-user coloring, git icon + blue branch, venv/conda segment — the "intentional terminal experience" |
| **`└─>` arrow always present** | Already satisfies the permanent-arrow rule |
| **Vi mode + `jk` + cursor shape switching + `KEYTIMEOUT=20`** | Core UX; works on Kitty and GNOME Terminal |
| **Command-duration hook** (`hooks.zsh`, shown only >5 s) | Intentional UX feature, harmless (documented perf nit is Phase 2) |
| **command-not-found guarded design** (`command -v pacman` with plain fallback) | Correct degradation pattern — only its blocking behavior needs fixing |
| **`modules/battery.zsh` as a standalone pure function file** | Zero side effects — can remain as an independent optional module (out of the prompt) |
| **Keybinding set** | `^G` spf, `Alt-S/Alt-I` wifi, `^T/^F` fzf, `^Space` autosuggest — functional and portable |
| **Alias organization by category** | Good structure; only the distro-specific members need conditioning |
| **History configuration scale** (`HISTSIZE/SAVEHIST=150000`, dedup options) | Sensible; just tidy the option conflicts later |
| **`print_banner` quote banner** | Part of the required `clear` behavior / visual identity |
| **XDG/`ZDOTDIR` layout with `$HOME`/`$ZDOTDIR` variables** | Portable — no `/home/user` literals found in code |

---

## 21. Components That Need Refactoring

| # | Component | What's wrong | Target phase |
|---|---|---|---|
| 1 | `config/zsh/.zshenv` | forces `TERM=kitty` + `LC_ALL`; two `.zshenv` files with different content confuse deployment | Phase 1 |
| 2 | `config/exports.zsh:25` | TERM rewrite band-aid; duplicate locale export | Phase 1 |
| 3 | `functions/prompt.zsh` | git-controls-arrow (spec), battery in prompt (spec), undefined `ssh_indicator`, non-local `battery_info`, double-sourced | Phase 1 |
| 4 | `config/plugins.zsh` | unguarded OMZ/clipboard source, unquoted `$ZSH/oh-my-zsh.sh`, stale `~/.zsh` fallback | Phase 1 |
| 5 | `modules/fzf.zsh` / `modules/zoxide.zsh` | unguarded `eval` (CNF-hang risk) | Phase 1 |
| 6 | `modules/command-not-found.zsh` | `read -k1` can block inside substitutions/invisible contexts | Phase 1 |
| 7 | `keybindings/main.zsh` | `autosuggest-accept` bind without existence check | Phase 1 |
| 8 | `.zshrc` banner block (integration only) | unguarded loops, `BANNER_DIR` not `$ZDOTDIR` — **files inside `TerminZsh_Banner/` stay untouched** | Phase 1 |
| 9 | `config/aliases.zsh` | Arch-only aliases unconditional; no Debian/Ubuntu group | Phase 1 |
| 10 | `config/options.zsh` | double compinit (with OMZ), history option conflicts, dump hygiene | Phase 2 |
| 11 | `functions/hooks.zsh` | unconditional `date` fork per prompt; compute only when displayed | Phase 2 |
| 12 | Git segment performance | sync `git status` scan every prompt; needs caching/async/`-uno` | Phase 2 |
| 13 | `modules/nvm.zsh` | eager nvm source + region-specific mirrors | Phase 2 |
| 14 | `modules/profiler.zsh` | `zsh/zprof` loaded for a commented-out call | Phase 2 |
| 15 | Installer (whole hyprbuti approach) | Arch-only, hardcoded repo path, incomplete deployment — needs a fresh copy-based design | Phase 2 |
| 16 | Repo hygiene (`bubuzsh/zsh/`) | `.zhistory`, `.zcompdump*` artifacts committed into the working tree; needs `.gitignore` + removal | Phase 1 |
| 17 | Baseline divergence (live vs hyprbuti) | three variants exist; must consciously merge live-only improvements (battery commented out, `setopt ignoreeof`, clipboard-in-OMZ, extra functions) | Phase 1 decision |
| 18 | `LC_ALL`/locale strategy | hard-forced locale breaks minimal Debian/Ubuntu | Phase 1 |

---

## 22. Phase 1 Recommendations

Phase 0 is complete; **Phase 1 has not been started.** Recommended scope for
Phase 1, in order:

1. **Choose and document the baseline.** Decide consciously between the
   hyprbuti repo copy (audited target) and the live `~/.config/zsh` divergences
   (battery line already commented, `setopt ignoreeof`, clipboard plugin moved
   into OMZ, extra utility functions, wifi/spf files removed). Merge the
   *good* live changes deliberately rather than by accident.
2. **Fix the TERM chain (portability blocker).** Remove `export TERM=kitty`
   from `.zshenv` and the `TERM == kitty` rewrite from `exports.zsh`; respect
   the terminal emulator's TERM. This is the single most important change for
   the Kitty ↔ GNOME Terminal matrix.
3. **Make the prompt spec-compliant.**
   - Arrow `└─>` stays forever; its color comes **only** from `$?`.
   - Git dirty → red git icon only; arrow untouched.
   - Remove `${battery_info}` and `${ssh_indicator}` from `PROMPT`; keep
     `modules/battery.zsh` as an independent optional module.
   - Keep `local exit_code=$?` as the first line (verified-correct pattern).
4. **Graceful degradation guards.** `(( $+commands[fzf] ))`, `[[ -f ]]` for
   OMZ/clipboard sources, widget check for `autosuggest-accept`, `command -v
   git` around the prompt git block, and fix the CNF handler so it never
   `read`s when stdin isn't a TTY (or inside substitutions).
5. **Banner integration hardening (banner files themselves stay untouched).**
   `BANNER_DIR="$ZDOTDIR/TerminZsh_Banner"`, `[[ -f "$f" ]]` in the loader
   loops. Do not change animations, timing, effects, or content.
6. **Single-source the prompt file** (remove the step-7 re-source).
7. **Distro-aware aliases** (pacman/yay group loaded only when present; add
   apt equivalents later or in Phase 2; keep `hyprctl`/`myfetch` behind
   existence checks).
8. **Locale policy.** Stop forcing `LC_ALL`; set `LANG` only if unset.
9. **Repository hygiene.** Add `.gitignore` for `.zhistory`/`.zcompdump*`;
   remove already-copied artifacts from `bubuzsh/zsh/` (they are untracked —
   just exclude them before the first commit).
10. **Constraints for Phase 1 (unchanged from Phase 0 rules).** Read-only
    rules on the live `~/.config/zsh`/`~/.zshrc`/`~/.zshenv` lift only when
    the user explicitly approves editing them; no new software (no Starship,
    no Powerlevel10k, no new frameworks); `TerminZsh_Banner/` remains
    protected; no automatic Phase 2 work.

**Suggested Phase 1 verification matrix** (per change): Arch + Hyprland/Kitty,
Arch + GNOME + Kitty, Arch + GNOME Terminal, Debian, Ubuntu — checking:
startup banner exactly once, `clear` = text banner + prompt, arrow colors by
exit status only, git icon by dirty state only, no battery in prompt, no
startup errors with optional tools hidden/uninstalled.

Phase 2 (preview only): copy-based distro-aware installer (no symlinks/Stow,
no hardcoded repo paths), compinit single-pass + dump hygiene, git segment
caching/async, deferred nvm, profiler removal, dangling-symlink cleanup in the
live environment (with user approval), and `.zcompdump` concurrency hardening.




