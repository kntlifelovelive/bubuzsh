# BuBuZsh

Lightweight modular Zsh configuration. Copy-based install — no frameworks,
no plugin managers, no symlinks.

## Supported distributions

- Arch Linux
- Debian
- Ubuntu

## Install

```bash
./install
```

Behavior:

- detects OS from `/etc/os-release` and the package manager (`pacman` / `apt`)
- required dependency: `zsh` only — installed if missing, never a system
  upgrade; optional tools (fzf, zoxide, git) are recommended only, BuBuZsh
  works without them
- backs up an existing `~/.zshenv` and `~/.config/zsh/` to a timestamped
  `~/.config/zsh-backup-<stamp>/` (outside this repository)
- copies `zsh/` to `~/.config/zsh/` and `zsh/.zshenv` to `~/.zshenv`
- validates installed files (`zsh -n`) and runs a non-blocking startup test

Re-running is safe: current configuration is backed up and replaced; nothing
is ever appended twice.
