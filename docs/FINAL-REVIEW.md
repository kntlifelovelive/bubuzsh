# BuBuZsh Final Review

## Final Status

PASS

## Objective

Bring BuBuZsh to a release-ready state prioritizing correctness, reliability,
simplicity, maintainability, graceful dependency handling, cross-terminal
compatibility, and error-free/hang-free startup — without adding features,
frameworks, or dependencies.

## Bugs Fixed

Confirmed bugs fixed during finalization (on top of Phase 1 Steps 1–5):

1. **Banner loader could abort `.zshrc`** (audit bug #6). Glob loops without a
   no-match qualifier made `zsh` abort the rest of `.zshrc` with
   `no matches found` whenever a directory was missing. Fixed with the `(N)`
   glob qualifier on all five loader loops in `.zshrc`.
2. **`BANNER_DIR` hardcoded to `$HOME/.config/zsh`** (audit bug #6). Now
   resolved via `$ZDOTDIR` — identical path in production (ZDOTDIR defaults to
   `$HOME/.config/zsh`), correct in isolated installs/tests.
3. **Arch-specific aliases unconditionally defined** (§14). `update`,
   pacman and yay alias groups are now guarded with `(( $+commands[...] ))` —
   no behavior change on Arch, no dead/wrong aliases on Debian/Ubuntu.
4. **Duplicated locale exports.** `LANG`/`LC_ALL` were exported twice
   (`.zshenv` + `config/exports.zsh`); the duplicate in `exports.zsh` was
   removed (`.zshenv` loads first for every shell — zero behavior change).
5. **Dead commented-out duplicate `PROMPT` block** in `functions/prompt.zsh`
   removed.
6. **Runtime artifacts in the repo** (`.zhistory` containing full shell
   history, `.zcompdump*`) removed from `zsh/` and ignored via a new
   `.gitignore` (audit bug #9) — prevents leaking history in the first commit.
7. **Wi-Fi module excluded (final cleanup):** `zsh/functions/wifi.zsh` and
   `zsh/keybindings/wifi.zsh` were moved to the system Trash by an external
   process during finalization, restored byte-identical, and then
   **intentionally removed** in the final cleanup — the Wi-Fi module is not
   part of the final BuBuZsh feature set (no loader referenced them; glob
   loaders skip missing files).

Fixed earlier in Phase 1 (Steps 2–5): forced `TERM=kitty` removal, prompt
arrow/Git coupling, battery/`ssh_indicator` removal from prompt, optional
dependency guards (fzf/zoxide/plugins/keybindings), CNF non-interactive hang
guards, missing-git prompt guard.

## Files Changed

Finalization phase (this step):

- `zsh/.zshrc` — `(N)` glob qualifiers on 5 loader loops; `BANNER_DIR` via `$ZDOTDIR`
- `zsh/config/aliases.zsh` — pacman/yay/`update` guarded by `$+commands`
- `zsh/config/exports.zsh` — duplicate `LANG`/`LC_ALL` removed
- `zsh/functions/prompt.zsh` — dead commented `PROMPT` duplicate removed
- `.gitignore` — new (ignores `zsh/.zhistory`, `zsh/.zcompdump*`)
- `zsh/` — removed runtime artifacts: `.zhistory`, `.zcompdump`,
  `.zcompdump-love-5.9`, `.zcompdump-love-5.9.zwc`
- `zsh/functions/wifi.zsh`, `zsh/keybindings/wifi.zsh` — **removed** in the
  final cleanup (Wi-Fi module intentionally not part of the final feature set)

Cumulative vs hyprbuti baseline (Steps 1–5 + finalization + cleanup):
10 files differ (`.zshenv`, `.zshrc`, `config/exports.zsh`,
`config/aliases.zsh`, `config/plugins.zsh`, `functions/prompt.zsh`,
`keybindings/main.zsh`, `modules/command-not-found.zsh`, `modules/fzf.zsh`,
`modules/zoxide.zsh`), 2 baseline files removed (`functions/wifi.zsh`,
`keybindings/wifi.zsh`), plus repo-only additions `agents.md`, `docs/`,
`.gitignore`, and removal of the 4 runtime artifacts.

## Files Not Changed

- `zsh/TerminZsh_Banner/` — protected; byte-identical to baseline (verified
  with `diff -rq` before and after finalization).
- `/home/archibubu/hyprbuti/` — untouched; git clean at `c4d0058`.
- Live `~/.config/zsh/` and `~/.zshenv` — never modified by development or
  testing (`.zshenv` mtime 2026-03-26; only `.zhistory` appended by normal
  interactive use of the running live shell).
- `zsh/.zshrcback` — untouched backup (contains an old `export TERM=kitty`
  line but is never sourced by any file; kept as historical baseline).

## Dependency Behavior

Optional tools fail gracefully, verified by running the full matrix with a
`PATH` that excludes `git`, `fzf`, and `zoxide`, plus a copy missing the
banner and module directories:

- `fzf` / `zoxide` absent → init skipped; startup, prompt, keybindings fine.
- `git` absent → prompt skips the Git segment entirely (never reaches CNF);
  arrow behavior unchanged.
- Banner directory absent → prompt still starts; no glob error; shell usable.
- `modules/` or `keybindings/` absent → those sections skip cleanly.
- Missing command → plain message + exit 127 (never blocks).

## Prompt Validation

Four states verified from raw escape codes in PTY sessions (15 renders parsed):

| State | Git | Arrow |
|---|---|---|
| success + clean | cyan (normal) | normal |
| success + dirty | **RED** | normal |
| failure + clean | cyan (normal) | **RED** |
| failure + dirty | **RED** | **RED** |

- Arrow `└─>` always present; color driven only by `$?`.
- Git indicator independent of arrow color; outside a repo → no Git segment.
- Battery absent from main prompt; `ssh_indicator` absent from codebase.

## Terminal Validation

- **Kitty** (PTY with `TERM=xterm-kitty`): full matrix PASS; `echo $TERM`
  returns `xterm-kitty` unchanged.
- **GNOME Terminal** (session `TERM=xterm-256color`): full matrix PASS;
  `$TERM` unchanged.
- Static scan: no `TERM=` assignment anywhere in loadable files; no
  `TERM=kitty` in any sourced file.

## Startup Validation

- `ZDOTDIR=… zsh -lic 'exit'` → exit 0, **stderr empty**, no errors/hangs.
- `zsh -n` passes on all runtime files (config, functions, keybindings,
  modules, themes, banner files).
- Interactive PTY sessions: startup completes ~2–3 s, banner plays once,
  no unexpected output, no infinite loops.
- Non-interactive `zsh -c` → zsh's built-in message only (config not loaded).

## CNF Validation

- **Interactive (TTY stdin+stdout):** `Search Package? [y/N]` shown once,
  `n` → `Cancelled`, shell continues; arrow RED (exit 127) on next prompt.
- **Command substitution** `x=$(missing); echo $?` → plain message only,
  `SUBST_RC=127`, no prompt, no hang (exactly 1 interactive prompt per session
  proves the `$()` path never reads input).
- **Redirected stdin** (`zsh -i -c missing </dev/null`) → plain message,
  exit 127, returns within timeout (no hang).
- `read -k1` executes only inside the guarded interactive branch.

## Banner Validation

- New interactive shell → clear screen → one random animated banner (header
  animation + text effect) → prompt. Phrase/frame evidence parsed per session.
- Banner phrase count adds 0 during the whole session → not triggered by
  precmd, preexec, prompt redraw, or command execution.
- `clear` → exactly **one** text banner line (`walk backwack` delta = +1),
  animation does **not** rerun (cursor-home delta = 1).
- Banner directory resolved from `$ZDOTDIR`; loader loops cannot abort
  `.zshrc`.

## Regression Results

| Area | Result |
|---|---|
| Prompt 4-state matrix (git × exit) | PASS |
| Outside-Git prompt | PASS |
| Startup (`zsh -lic`, PTY, stderr) | PASS |
| clear behavior | PASS |
| Banner once-per-session | PASS |
| Missing git/fzf/zoxide | PASS (2 runs, 2 TERMs) |
| Missing banner/modules dirs | PASS |
| CNF interactive / `$()` / redirected | PASS |
| TERM passthrough (kitty + GNOME) | PASS |
| `zsh -n` all runtime files | PASS |
| Static scan (TERM, ssh_indicator, hardcoded homes) | PASS |
| Alias guards (with/without pacman/yay) | PASS |
| Banner byte-identity vs baseline | PASS |
| hyprbuti untouched (clean @ c4d0058) | PASS |
| Live config untouched | PASS |
| No symlinks / no stow | PASS |
| Wi-Fi module removal (no loader refs, startup OK) | PASS |
| No commit / no push | PASS |

## Known Limitations

1. `.zshenv` still exports `LANG`/`LC_ALL=en_US.UTF-8` (baseline behavior).
   Harmless on systems with that locale; minimal systems without it may warn.
   Left unchanged — changing locale policy is a behavior change, not a bug fix.
2. `themes/prompt.zsh` re-sources `functions/prompt.zsh` (`.zshrc` loads both).
   Proven idempotent (`add-zsh-hook` dedupes; prompt deterministic) — left
   unchanged to avoid restructuring working code.
3. `modules/profiler.zsh` loads `zsh/zprof` for optional manual profiling
   (`zprof` call commented out). Tiny, harmless, kept.
4. `modules/nvm.zsh` sets China-region npm/electron mirrors (user preference,
   guarded, does not affect startup correctness).
5. `functions/hooks.zsh` runs `date` twice for commands >5 s to print duration
   (minor fork cost; Phase 2 performance item, not a correctness issue).
6. `love` alias calls `myfetch`, which is not on this machine's PATH —
   user-specific alias, kept as-is (degrades to a plain CNF message).

## Installer Validation

Installer: `./install` (single official entry point, Bash, ~200 lines,
executable). Files added: `install`, `README.md`. No core runtime file was
modified by the installer work.

- **Supported distributions:** Arch Linux, Debian, Ubuntu (exact `ID` match;
  derivatives are not auto-accepted).
- **OS detection:** reads `ID`, `ID_LIKE`, `VERSION_ID`, `PRETTY_NAME` from
  `/etc/os-release`.
- **Package manager detection:** `arch` → `pacman`; `debian`/`ubuntu` → `apt`.
  Never runs `pacman -Syu`, `apt upgrade/full-upgrade/dist-upgrade`, never
  touches `/etc/pacman.conf` or `/etc/apt/`, never adds repos/PPAs/AUR helpers.
- **Required dependencies:** `zsh` only (checked by `command`, installed only
  if missing, verified after install). `fzf`, `zoxide`, `git` reported as
  optional and never force-installed.
- **Sudo/root:** root execution is refused with an explanatory message (no
  install into `/root`); `sudo` is used only for package installation and is
  checked before any install attempt.
- **Backup behavior:** existing `~/.zshenv` and `~/.config/zsh/` are copied to
  `~/.config/zsh-backup-YYYYMMDD-HHMMSS/` (collision-safe suffix), outside the
  repository; old backups are never deleted.
- **Copy installation:** `cp -a` of the whole `zsh/` tree to `~/.config/zsh/`
  (stage-then-activate to avoid partial states) plus `zsh/.zshenv` →
  `~/.zshenv`. No symlinks, no stow, structure preserved, banner copied
  byte-identically and existence-verified after install. Wi-Fi files are not
  recreated (they are not in the source tree).
- **Idempotency:** re-run backs up the previous install and replaces it;
  installed tree diff-identical to source (modulo runtime `.zcompdump`),
  `~/.zshenv` byte-identical each time, no appended/duplicated lines.
- **Syntax validation:** `zsh -n` on every source file *before* touching user
  config, and again on every installed file afterwards.
- **Startup validation:** `env -u ZDOTDIR timeout 30 zsh -lic 'exit'
  </dev/null` must exit 0 with empty stderr. The `/dev/null` stdin was added
  after a real installer-exposed problem: an interactive `zsh -lic` started
  under a non-job-controlling parent stops itself on tty access (SIGTTIN/
  SIGTTOU, `STAT=T`, pgrp ≠ TPGID) and a plain `timeout` cannot kill a stopped
  process — verified via `/proc/<pid>` state and fixed without touching core
  files.
- **Unsupported OS:** prints the required message
  (`Unsupported distribution. / Supported: …`) and exits 1 with the user's
  HOME untouched.
- **Failed-install safety:** dependency-install and source-validation failures
  stop before any backup or modification of the user's configuration.

Test results (isolated fake-`HOME`s under `/tmp/inst/`, live `~/.zshenv` and
`~/.config/zsh/` never touched):

| Test | Result |
|---|---|
| Arch: fresh install (no existing config) | PASS (RC=0) |
| Arch: existing config → backup + replace | PASS (old `.zshenv`/`.zshrc`/extra file all preserved in backup) |
| Arch: repeated install (idempotency) | PASS (tree ≡ source, 1 backup per re-run) |
| Arch: run from a different working directory | PASS |
| Unsupported OS (fake fedora `os-release`) | PASS (message + RC=1 + HOME untouched) |
| Missing zsh, no sudo (fake arch) | PASS (RC=1, config untouched, no backup) |
| Missing zsh, no package manager (fake debian) | PASS (RC=1, config untouched) |
| Incomplete source tree (`.zshrc` deleted) | PASS (`BuBuZsh source is incomplete`, RC=1, HOME untouched) |
| `bash -n` + static safety greps (no TERM=, no upgrade, no stow/ln -s, no wifi) | PASS |
| Banner byte-identity of installed copy | PASS |
| Root-refusal path | Not runtime-tested (host sudo requires a password) — static review only |

**Runtime-tested on this host:** Arch Linux (full installer, all flows above).

**Not runtime-tested on this host:** Debian and Ubuntu *package installation*
— no real Debian/Ubuntu environment available. Their OS/package-manager
detection and the complete install/validate/startup flow were validated by
substituting a fake `/etc/os-release` (ID=debian / ID=ubuntu) in a test copy
of the installer: detection printed the correct OS + `apt`, no package
installation was attempted (zsh already present), full flow RC=0. Static/logic
validation completed; actual `apt-get` execution was never run against this
machine by design.

## Final Recommendation

BuBuZsh is small (10 files changed vs baseline, no new dependencies or
frameworks), passes the full runtime matrix, has a validated copy-based
installer (`./install`), has no known startup errors or hangs, and all
protected components are intact. It is ready to be treated as the final
project version. Commit/push intentionally not done pending the user's
instruction.
