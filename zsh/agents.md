
# AGENTS.md — Standalone Cross-Platform Zsh Project

## 1. Project Mission

This project is a standalone, lightweight, modular Zsh configuration originally derived from the Zsh configuration used in the `hyprbuti` project.

The goal is to make the Zsh environment:

* lightweight
* stable
* modular
* maintainable
* cross-platform
* safe to install
* safe to upgrade
* compatible with multiple terminal sessions
* compatible with Arch Linux, Debian, and Ubuntu
* compatible with Kitty and GNOME Terminal
* easy to debug
* easy to uninstall

The existing visual identity and intentional terminal experience must be preserved.

Do NOT redesign the project blindly.

First audit the existing implementation, identify real problems, then refactor only where necessary.

---

# 2. CORE DEVELOPMENT RULE

Before modifying code:

1. Inspect the entire repository.
2. Understand the current architecture.
3. Identify dependencies.
4. Identify platform-specific assumptions.
5. Identify terminal-specific assumptions.
6. Identify startup hooks.
7. Identify prompt hooks.
8. Identify banner execution flow.
9. Identify installer behavior.
10. Identify existing bugs.

Do not make speculative changes.

Do not remove existing functionality simply because another implementation is considered cleaner.

Preserve intentional behavior.

---

# 3. STRICT PROTECTED FEATURE — TerminZsh_Banner

`TerminZsh_Banner/` is a PROTECTED AREA.

The banner and animation system is an intentional core feature.

DO NOT:

* delete files
* rename files
* move files
* remove animations
* rewrite animations
* refactor animations
* optimize animations
* change animation timing
* change animation effects
* change animation selection
* change animation content
* replace animations
* simplify animation code
* remove text effects
* change the visual behavior

Do not modify files inside `TerminZsh_Banner/` unless the user explicitly requests it.

If compatibility work is required, modify the surrounding integration code instead.

The banner implementation itself must remain intact.

---

# 4. BANNER ARCHITECTURE — TWO DIFFERENT SYSTEMS

There are two separate banner behaviors.

They MUST NOT be merged.

## 4.1 New Terminal Startup Banner

When a new interactive Zsh terminal session starts:

1. Select one random startup animation/banner.
2. Display it once.
3. Finish the animation.
4. Continue to the prompt.

The startup animated banner must execute only once per new interactive terminal session.

It must NOT execute:

* after every command
* from `precmd`
* from `preexec`
* when the prompt is redrawn
* when the terminal is resized
* when `clear` is executed

## 4.2 `clear` Text Banner

The existing custom `clear` behavior MUST remain.

When the user executes:

```bash
clear
```

the expected behavior is:

```text
clear screen
     ↓
existing text-banner system
     ↓
prompt
```

The large startup animated banner/title must NOT be executed by `clear`.

The `clear` command must NOT trigger the startup animation.

The text-banner behavior and startup-animation behavior are independent.

Do not remove this feature.

---

# 5. PROMPT ARROW — STRICT REQUIREMENT

The prompt arrow head MUST ALWAYS exist.

Expected structure:

```text
┌(bubu)-[~/Projects]
└─>
```

NEVER remove the `>`.

NEVER hide it.

NEVER replace it with another symbol.

NEVER make it disappear because of Git status.

NEVER make it disappear because of an error.

The arrow is a permanent part of the prompt design.

---

# 6. PROMPT ERROR COLOR

The arrow color is controlled ONLY by the previous command's exit status.

## Success

If:

```text
exit status == 0
```

the arrow must use the normal prompt color.

Example:

```text
└─>
```

## Error

If:

```text
exit status != 0
```

the arrow must become RED.

Example:

```text
└─>
```

The arrow itself remains present.

Only its color changes.

The actual exit code may be displayed according to the existing prompt design, but do not remove the arrow.

---

# 7. GIT STATUS MUST BE INDEPENDENT

Git status MUST NOT control the prompt arrow.

These are independent systems.

## Git clean

Git icon:

```text
normal color
```

Arrow:

```text
normal color if the previous command succeeded
```

## Git dirty

Git icon:

```text
RED
```

Arrow:

```text
normal color if the previous command succeeded
```

If a command fails inside a Git repository:

```text
Git icon → determined by Git state
Arrow → determined by command exit status
```

Never mix these conditions.

Example:

```text
Git dirty + successful command
    Git icon = RED
    Arrow = NORMAL

Git clean + failed command
    Git icon = NORMAL
    Arrow = RED

Git dirty + failed command
    Git icon = RED
    Arrow = RED
```

---

# 8. BATTERY

Remove the battery indicator from the shell prompt.

Battery information must NOT be rendered inside the prompt.

Do not show battery percentage or battery icons in the prompt.

If the existing battery module is useful for another purpose, preserve it as an independent module unless there is a clear reason to remove it.

Do not delete unrelated functionality.

---

# 9. MULTIPLE TERMINAL SUPPORT

The configuration must work correctly with multiple simultaneous terminals.

Example:

```text
Terminal A
Terminal B
Terminal C
Terminal D
```

Each interactive Zsh session must maintain its own state.

Do not use shared global temporary state for:

* exit status
* command start time
* prompt state
* animation state
* command duration

Avoid race conditions between terminal sessions.

A command executed in Terminal A must not affect the prompt state of Terminal B.

---

# 10. TERMINAL COMPATIBILITY

The configuration must support at minimum:

* Kitty
* GNOME Terminal

It should also avoid unnecessary assumptions about other terminal emulators.

Do NOT force:

```zsh
export TERM=kitty
```

Do not overwrite the terminal emulator's `$TERM`.

Respect the value provided by the terminal emulator.

Kitty-specific behavior must only be used when explicitly detected and required.

Do not make GNOME Terminal pretend to be Kitty.

---

# 11. CROSS-DISTRIBUTION SUPPORT

The installer must support:

* Arch Linux
* Debian
* Ubuntu

Detect the distribution and package manager.

Expected package managers:

```text
Arch    → pacman
Debian  → apt
Ubuntu  → apt
```

Do not assume that the system is Arch Linux.

Do not run `pacman` on Debian or Ubuntu.

Do not run `apt` on Arch.

---

# 12. DEPENDENCY MANAGEMENT

The installer must detect required dependencies before installing the configuration.

Dependencies should be divided into:

## Core dependencies

Only install packages absolutely required for the basic Zsh configuration.

Example:

```text
zsh
git
```

## Recommended dependencies

Used for enhanced shell functionality.

Example:

```text
fzf
zoxide
```

## Optional dependencies

Only install when needed by enabled modules.

Examples:

```text
eza
fd
bat
neovim
```

Do not make optional applications mandatory.

The Zsh shell must still start if an optional package is unavailable.

---

# 13. DEPENDENCY CHECKING

Before installation:

1. Detect OS.
2. Detect package manager.
3. Check whether Zsh exists.
4. Check required commands.
5. Check optional commands.
6. Install missing required dependencies.
7. Ask or clearly report optional dependencies.
8. Continue safely if optional dependencies are unavailable.

The configuration must degrade gracefully.

For example:

If `eza` is missing:

```text
Zsh must still start.
```

Do not produce startup errors.

If `zoxide` is missing:

```text
The zoxide integration must be skipped safely.
```

If `fzf` is missing:

```text
The fzf integration must be skipped safely.
```

---

# 14. COMMAND EXISTENCE CHECKS

Optional integrations must use command detection.

Example:

```zsh
if command -v zoxide >/dev/null 2>&1; then
    ...
fi
```

Do not execute optional commands blindly during shell startup.

Missing optional packages must not break `.zshrc`.

---

# 15. INSTALLER DESIGN

The main installer should be:

```bash
./install.sh
```

The installer should:

1. Detect operating system.
2. Detect package manager.
3. Check dependencies.
4. Install missing dependencies.
5. Back up existing configuration.
6. Install Zsh configuration.
7. Install optional integrations safely.
8. Validate the configuration.
9. Report what was installed.
10. Report skipped optional components.
11. Provide a clear success/failure summary.

Never overwrite an existing Zsh configuration without a backup.

---

# 16. BACKUP

Before modifying:

```text
~/.zshenv
~/.zshrc
~/.config/zsh
```

create a timestamped backup when applicable.

Example:

```text
~/.config/zsh.backup-YYYYMMDD-HHMMSS
```

Never silently destroy the user's existing configuration.

---

# 17. CONFIGURATION LOCATION

The project should support:

```text
$ZDOTDIR
```

Do not hard-code a username.

Do not hard-code:

```text
/home/username
```

Use:

```text
$HOME
```

and:

```text
$ZDOTDIR
```

where appropriate.

---

# 18. `.zshenv`

Keep `.zshenv` minimal.

Do not place terminal-specific configuration there unless absolutely necessary.

Do not force:

```zsh
TERM=kitty
```

Do not load heavy plugins from `.zshenv`.

Avoid commands that can produce output from `.zshenv`.

---

# 19. PROMPT PERFORMANCE

The prompt must remain lightweight.

Do not execute expensive commands every time the prompt is rendered.

Avoid unnecessary:

* package manager commands
* network commands
* disk scans
* process scans
* heavy Git commands
* unnecessary external utilities

Git information should only be collected when the current directory is inside a Git repository.

Battery information must not be collected for prompt rendering.

---

# 20. EXIT STATUS CAPTURE

The previous command's exit status must be captured reliably.

Do not allow:

* `precmd`
* Git commands
* battery commands
* duration calculations
* prompt helper commands

to overwrite the original exit status before it is captured.

The exit status must be captured FIRST.

Concept:

```text
command
  ↓
capture $? immediately
  ↓
other prompt calculations
  ↓
render prompt
```

The implementation may use Zsh-native hooks such as `preexec`, `precmd`, or `add-zsh-hook`, but the final architecture must preserve the real previous command exit status.

---

# 21. PROMPT HOOK ARCHITECTURE

Avoid multiple competing `precmd` implementations.

Audit existing hooks.

If multiple `precmd` functions exist, consolidate them safely.

The final implementation should have a clear execution order.

Recommended conceptual flow:

```text
preexec
    ↓
record command start time

command runs

precmd
    ↓
capture previous exit status FIRST
    ↓
calculate command duration
    ↓
calculate Git state
    ↓
build prompt
    ↓
render prompt
```

Do not modify the protected banner implementation to accomplish this.

---

# 22. GIT PERFORMANCE

Do not execute unnecessary Git commands outside Git repositories.

Handle:

* normal branch
* detached HEAD
* empty branch name
* dirty repository
* clean repository
* Git unavailable

gracefully.

The Git indicator must never crash the shell.

---

# 23. CROSS-PLATFORM PATHS

Do not assume:

```text
/home/user
```

or any hard-coded username.

Use:

```zsh
$HOME
$ZDOTDIR
```

Use portable shell/Zsh constructs where possible.

Avoid GNU-specific behavior when a portable alternative exists.

If platform-specific behavior is required, detect it explicitly.

---

# 24. ALIASES

Audit all aliases for distro-specific commands.

For example:

```zsh
alias update='sudo pacman -Syu'
```

must not be blindly installed on Debian or Ubuntu.

Create distro-aware functions where appropriate.

Do not silently change the user's intended alias behavior without documenting the change.

---

# 25. PLUGINS

Plugins should be optional wherever possible.

Do not introduce a large framework merely to provide simple functionality.

Keep the project lightweight.

Avoid making Oh My Zsh a mandatory dependency unless the existing configuration genuinely requires it.

Prefer the existing modular architecture when possible.

---

# 26. STARTUP OUTPUT

Zsh startup must not print unnecessary errors.

Optional commands must be checked before execution.

Missing dependencies must produce controlled behavior.

Startup should remain fast.

The protected banner experience must remain unchanged.

---

# 27. TESTING REQUIREMENTS

Before declaring the project complete, test:

## Syntax

```bash
zsh -n ~/.zshrc
```

and syntax-check relevant Zsh files.

## Successful command

```bash
true
```

Expected:

```text
arrow = normal
```

## Failed command

```bash
false
```

Expected:

```text
arrow = RED
```

Arrow must remain visible.

## Command not found

Test a nonexistent command.

Expected:

```text
arrow = RED
```

and no broken prompt.

## Git clean

Expected:

```text
Git icon = normal
Arrow = normal after successful command
```

## Git dirty

Expected:

```text
Git icon = RED
Arrow = normal after successful command
```

## Git dirty + failed command

Expected:

```text
Git icon = RED
Arrow = RED
```

## Clear

Run:

```bash
clear
```

Expected:

```text
screen clears
text banner appears
startup animation does NOT appear
```

## New terminal

Open a new terminal.

Expected:

```text
one random startup animation
```

It must not repeat after every command.

## Multiple terminals

Open several terminals simultaneously.

Verify that:

* exit status is independent
* prompt state is independent
* command duration is independent
* banner state is independent
* one terminal cannot corrupt another

## Terminal compatibility

Test:

```text
Kitty
GNOME Terminal
```

---

# 28. INSTALLER TESTING

Test installation on:

```text
Arch Linux
Debian
Ubuntu
```

Test at least:

1. clean installation
2. dependencies already installed
3. dependencies missing
4. optional dependency missing
5. existing Zsh configuration
6. backup creation
7. repeated installation
8. uninstall
9. shell startup after installation

The installer must be idempotent where practical.

Running it twice should not create duplicated configuration blocks.

---

# 29. UNINSTALLATION

Provide:

```bash
./uninstall.sh
```

The uninstaller must:

* remove installed project files safely
* avoid deleting unrelated user files
* explain what will be removed
* preserve backups
* restore the previous configuration when appropriate

Never blindly delete:

```text
~/.config/zsh
```

without confirming that it belongs to this project.

---

# 30. NO SYMLINK REQUIREMENT

The standalone installer should prefer copying configuration files into the user's configuration directory rather than requiring symbolic links.

Do not require GNU Stow.

The project must work independently.

---

# 31. NO USERNAME ASSUMPTIONS

Never hard-code:

```text
bubu
love
archibubu
```

The prompt may display the current user dynamically.

Use:

```zsh
$USER
```

or the appropriate Zsh parameter.

---

# 32. DO NOT OVERENGINEER

Prefer:

```text
simple
portable
readable
fast
```

over:

```text
large framework
complex abstraction
unnecessary dependencies
```

Do not add functionality simply because it is technically possible.

Every new dependency must have a clear benefit.

---

# 33. PRESERVE THE EXISTING VISUAL DESIGN

The goal is NOT to replace the existing prompt with Starship, Powerlevel10k, Oh My Zsh themes, or another complete prompt framework.

Preserve the project's own visual identity.

The prompt is intentionally inspired by the Kali-style shell experience.

Improve implementation quality without destroying the existing appearance.

---

# 34. NO UNREQUESTED VISUAL CHANGES

Do not change:

* colors
* symbols
* banner appearance
* animation appearance
* prompt layout

unless required by the explicit requirements in this document.

Functional fixes and compatibility fixes are allowed.

Unrelated visual redesign is not allowed.

---

# 35. CHANGE SAFETY

Before modifying an existing feature:

1. Identify its current behavior.
2. Determine whether it is intentional.
3. Check whether tests depend on it.
4. Preserve it unless it conflicts with an explicit requirement.

If uncertain, do not delete it.

Document the uncertainty.

---

# 36. REQUIRED FINAL REPORT

After implementation, report:

1. Files changed.
2. Files created.
3. Files removed, if any.
4. Bugs discovered.
5. Bugs fixed.
6. Cross-platform changes.
7. Dependencies added.
8. Dependencies made optional.
9. Installer behavior.
10. Backup behavior.
11. Prompt behavior.
12. Git behavior.
13. Banner behavior.
14. Terminal compatibility.
15. Tests performed.
16. Tests that could not be performed.
17. Known limitations.

Do not claim a test passed if it was not actually run.

---

# 37. FINAL SUCCESS CRITERIA

The project is considered complete only when:

* Zsh starts without errors.
* Kitty works.
* GNOME Terminal works.
* Multiple terminals work independently.
* Arch works.
* Debian works.
* Ubuntu works.
* Missing optional dependencies do not break startup.
* Installer detects and installs required packages.
* Existing configuration is backed up.
* Installation is repeatable.
* Uninstallation is safe.
* Battery is absent from the prompt.
* The prompt arrow ALWAYS exists.
* The arrow turns RED only when the previous command failed.
* Git status does not control the arrow.
* Dirty Git state can make only the Git indicator RED.
* Startup animation runs once for a new terminal session.
* `clear` shows the text banner.
* `clear` does NOT trigger the startup animation.
* Existing banner/animation files remain untouched.
* Prompt remains lightweight.
* No unnecessary framework is introduced.
* No hard-coded username exists.
* No `TERM=kitty` override exists.
* Existing intentional functionality is preserved.
