# BuBuZsh Baseline

## Canonical Source

```text
hyprbuti/config/zsh/
(absolute: /home/archibubu/hyprbuti/config/zsh/)
```

## BuBuZsh Working Source

```text
zsh/
(absolute: /home/archibubu/bubuzsh/zsh/)
```

## Live User Configuration

```text
~/.config/zsh/
(absolute: /home/archibubu/.config/zsh/)
```

The live configuration is NOT the canonical source.
The Phase 0 audit confirmed it diverges from the repository baseline
(see `docs/PHASE-00-AUDIT.md`, section 1 — divergence table).

## Baseline Rule

All Phase 1 refactoring must happen inside the BuBuZsh repository.

The original hyprbuti source must remain untouched
(verified: `git -C hyprbuti status --short` is clean, HEAD `c4d0058`).

## Protected Components

```text
TerminZsh_Banner/
```

Byte-identical to the canonical source; no file inside may be modified.

## Copy Policy

BuBuZsh uses copied configuration files.

No symlink or GNU Stow based deployment is used for the source repository.

Verified: `find zsh/ ( -type l -o -type b -o -type c -o -type p -o -type s )`
returns **0** entries — the working source contains only regular files and
directories.

## Baseline Verification

Commands run on 2026-10-06:

```bash
diff -rq hyprbuti/config/zsh/ zsh/
```

Result after Step 1:

```text
Only in zsh/: agents.md
```

(exactly one line — see interpretation below)

Stronger checksum verification (all files, relative paths, md5):

```text
hyprbuti/config/zsh : 60 files
bubuzsh/zsh         : 61 files
manifest diff       : only "extra in bubuzsh": ./agents.md
                      (md5 697f0032d51737adb5783e9fa0744be2)
all 60 shared files : identical md5 checksums
```

Interpretation of the two differences found during Step 1:

1. `zsh/agents.md` — **intentional BuBuZsh-only metadata** (project rules
   document for AI agents). Not part of the canonical Zsh source; kept.
2. `zsh/.zshrcback` — was **missing** from the initial copy (historical
   Oh-My-Zsh `.zshrc` backup inside the canonical source). Investigated,
   judged non-identical-to-metadata, and **copied from the canonical source**
   during Step 1 so the baseline is complete. `cmp` confirms identical.

Runtime artifacts (`.zhistory`, `.zcompdump`, `.zcompdump-love-5.9`,
`.zcompdump-love-5.9.zwc`) are part of the canonical source itself and are
therefore present in the baseline to preserve byte-identity. They are flagged
for a later repository-hygiene step and were NOT removed here.

## Banner Verification

```bash
diff -rq hyprbuti/config/zsh/TerminZsh_Banner/ zsh/TerminZsh_Banner/
```

Result:

```text
no differences (exit code 0)
```

## Git Status

Repository: `/home/archibubu/bubuzsh` (branch `main`, **no commits yet**)

Before Step 1:

```text
?? docs/
?? zsh/
```

After Step 1:

```text
?? docs/
?? zsh/
```

Changes are contained in: `docs/PHASE-00-AUDIT.md` (Phase 0),
`docs/BASELINE.md`, `docs/PHASE-01-STEP-01.md` (this step),
`zsh/` (baseline copy, now including `zsh/.zshrcback`).

Reference repository `hyprbuti`: branch `main`, HEAD `c4d0058`,
working tree clean before and after Step 1.
