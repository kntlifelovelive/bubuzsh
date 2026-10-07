# Phase 1 — Step 1

## Baseline Lock

Establish and lock the BuBuZsh source baseline safely before any refactoring.

## Objective

Copy and verify the canonical Zsh source inside the BuBuZsh repository,
prove byte-identity against `hyprbuti/config/zsh/`, protect
`TerminZsh_Banner/`, and leave both `hyprbuti/` and the live user Zsh
configuration untouched. Repository preparation only — no refactoring.

## Canonical Source

`/home/archibubu/hyprbuti/config/zsh/` — chosen per instruction; the live
`~/.config/zsh/` was explicitly rejected as baseline (Phase 0 documented its
divergence).

## BuBuZsh Source

`/home/archibubu/bubuzsh/zsh/` — independent copy of regular files.
Verified: 0 symlinks, 0 devices, 0 sockets, 0 FIFOs, 0 bind mounts, no
`/home/...` path introduced by this step. GNU Stow not used (not installed
for this purpose; no stow invocation made).

## Live Configuration Policy

No writes to `~/.zshrc`, `~/.zshenv`, `~/.config/zsh/`.
No installation into `$HOME`, no symlinks into the live configuration.

Facts recorded during validation:

- `~/.zshrc` does **not exist** as a file (the live rc lives at
  `~/.config/zsh/.zshrc`) — nothing to protect at that path.
- `~/.zshenv`: mtime `2026-03-26`, unchanged.
- `~/.config/zsh/.zshrc`: mtime `2026-08-11 23:09`, unchanged.
- `~/.config/zsh/.zshenv`: mtime `2026-08-11 23:13`, unchanged.
- `find ~/.config/zsh -type f -newermt '2026-10-06 18:00'` lists exactly one
  file: `.zhistory` — the interactive shells' normal history append
  (runtime data, written by the running user sessions, not by this step).
  All configuration files are untouched.
- Content-level cross-check: `diff -rq zsh/ ~/.config/zsh/` reproduces
  exactly the divergence set documented in `docs/PHASE-00-AUDIT.md` §1
  (aliases/exports/plugins/prompt/main/fzf/textbanners differ; live-only and
  baseline-only files unchanged) — no new divergence was introduced.

## Git State Before

`git status --short` (bubuzsh):

```text
?? docs/
?? zsh/
```

`git branch --show-current`: `main`
`git log -1 --oneline`: `fatal: your current branch 'main' does not have any commits yet`
(empty repository, no commits)

hyprbuti (read-only reference): branch `main`, HEAD
`c4d0058 waybar workspaces: hl.dsp.focus dispatch syntax for lua-hyprland`,
working tree **clean**.

No destructive commands (`git reset --hard`, `git clean`) were run; no
unrelated files deleted or cleaned.

## Baseline Comparison

Command:

```bash
diff -rq /home/archibubu/hyprbuti/config/zsh/ /home/archibubu/bubuzsh/zsh/
```

Initial result (2 differences):

```text
Only in /home/archibubu/bubuzsh/zsh/: agents.md
Only in /home/archibubu/hyprbuti/config/zsh/: .zshrcback
```

Investigation:

1. `agents.md` — BuBuZsh-only metadata (AI agent project rules), created
   outside the copied source. Intentional → documented, kept.
2. `.zshrcback` — part of the canonical source (historical OMZ `.zshrc`
   backup), missing from the copy. Not intentional → **copied** from the
   canonical source into `zsh/.zshrcback` (copy only; hyprbuti untouched).
   `cmp` → identical.

Final result:

```text
Only in /home/archibubu/bubuzsh/zsh/: agents.md
```

Stronger checksum manifest (`find . -type f | sort | xargs md5sum`, both
trees):

```text
source: 60 files | bubuzsh: 61 files
only difference: "+ ./agents.md" (extra in bubuzsh)
all 60 shared files: identical checksums
```

Conclusion: **byte-identical baseline** (plus one documented metadata file).

## TerminZsh_Banner Verification

```bash
diff -rq /home/archibubu/hyprbuti/config/zsh/TerminZsh_Banner/ \
         /home/archibubu/bubuzsh/zsh/TerminZsh_Banner/
```

Result: **no differences** (exit 0) — re-verified as the final step.
Nothing inside the directory was edited, renamed, moved, or deleted;
animations, timing, effects, selection logic, text/ASCII banners all
byte-identical.

## Files Created

| File | Purpose |
|---|---|
| `docs/BASELINE.md` | Baseline manifest (canonical source, rules, verification results, git status) |
| `docs/PHASE-01-STEP-01.md` | This step report |
| `zsh/.zshrcback` | Missing canonical file, copied from `hyprbuti/config/zsh/.zshrcback` to complete the byte-identical baseline (`cmp` identical) |

(`docs/PHASE-00-AUDIT.md` and the rest of `zsh/` pre-existed this step.)

## Files Modified

**None.** No existing file in the BuBuZsh repository was edited. No file in
`hyprbuti/` and no live Zsh configuration file was modified.

## Files Not Modified

- `hyprbuti/` — entire repository (git status clean before and after;
  HEAD `c4d0058`; no edits, deletes, renames, moves, permission changes, or
  history changes)
- `zsh/TerminZsh_Banner/` — byte-identical (explicit verification)
- All 60 shared baseline files — identical checksums (only one file was
  *added*, not changed)
- `~/.config/zsh/` (all configuration files), `~/.zshenv`
- `~/.zshrc` — does not exist; nothing created at that path
- No Phase 1 refactoring items touched: TERM, prompt, git colors, battery,
  `ssh_indicator`, CNF handler, dependency guards, banner loader, aliases,
  locale, installer, performance — all unchanged

## Validation Results

| Success condition | Result |
|---|---|
| Phase 0 report read | PASS (`docs/PHASE-00-AUDIT.md`, 22 sections confirmed) |
| `hyprbuti/config/zsh/` identified as canonical baseline | PASS |
| BuBuZsh has an independent copied source | PASS (regular files only; 0 symlinks/special files) |
| Source matches canonical baseline | PASS (`diff -rq`: only `agents.md` extra; md5 manifest: 60/60 shared files identical) |
| `TerminZsh_Banner/` byte-identical | PASS (diff exit 0) |
| `hyprbuti/` not modified | PASS (git status clean) |
| Live Zsh configuration not modified | PASS (mtimes unchanged; only runtime `.zhistory` appended by running shells; divergence set matches Phase 0) |
| No symlinks introduced | PASS (0 found) |
| No Stow introduced | PASS (not used) |
| No Phase 1 refactoring performed | PASS |
| No unnecessary software installed | PASS (only `cp`, `diff`, `md5sum`, `find` used — all pre-existing) |
| `docs/BASELINE.md` exists | PASS |
| `docs/PHASE-01-STEP-01.md` exists | PASS |
| Git tree contains only intended Step 1 changes | PASS (`?? docs/`, `?? zsh/` only; nothing else) |

## Problems Found

1. **Initial copy was incomplete** — `zsh/.zshrcback` was missing.
   Resolved by copying the file from the canonical source (direction:
   hyprbuti → bubuzsh only). Documented in `docs/BASELINE.md`.
2. **`~/.zshrc` does not exist** — the live rc file is
   `~/.config/zsh/.zshrc`. Informational; no action taken.
3. **Runtime artifacts are inside the canonical baseline** (`.zhistory`,
   `.zcompdump*`) — kept to preserve byte-identity; flagged for the later
   repository-hygiene step (Phase 1 step 9 candidate). Not removed now.
4. **Tooling note** — two shell commands had their output swallowed by
   shell-integration capture during this step; each was re-run and the
   results above were verified from files on disk afterwards.
5. **Live `.zhistory` grows continuously** — written by the user's running
   interactive sessions; excluded from "live config modified" as runtime
   data, disclosed here for transparency.

## Step Status

PASS

## Next Step

Phase 1 — Step 2

