# Mise Bootstrap Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the hand-rolled `boot.sh` / `main.fish` / `src/*.fish` orchestration with mise's real, verified bootstrap components — `[tools]`, file tasks (`[task_config] includes`), `mise trust`, and `mise generate bootstrap` — while producing byte-for-byte identical end-user behavior.

**Architecture:** `boot.sh` stays the POSIX-sh curl entrypoint (nothing else exists yet on a fresh machine) but now installs `mise` itself (official `mise.run` installer) instead of `fd`/`fish`/`gum` via brew/pacman. Those three tools, plus `git`... no, `git` stays on the native package manager (see §Decisions) — move into the repo's root `mise.toml` `[tools]`. `main.fish` and the imperative `src/{darwin,linux}/*.fish` scripts become mise **file tasks**, discovered in place via `[task_config] includes = ["src"]` (no renaming/moving — just a shebang + `chmod +x` per file), namespaced automatically by directory (`darwin:brew`, `linux:setup`, `linux:cachyos:cachyos`). `dfs-link` and the other `src/dfs-*.fish` helper *functions* are untouched and keep working via fish's existing autoload path.

**Tech Stack:** mise 2026.x (file tasks, `[task_config]`, `mise trust`, `mise generate bootstrap`), fish shell scripts as mise file tasks (shebang `#!/usr/bin/env fish`), POSIX `sh` for the pre-mise entrypoint.

## Global Constraints

- **Every behavior in the table below must survive.** Where the migration structurally forces a change (see the 3 rows marked "changes"), that change is called out explicitly — nothing else changes silently.
- Do not invent mise features. Every command/config key used in this plan was run against the actually-installed `mise` (`mise --version` → `2026.7.17 linux-x64`) during planning. If an implementer needs a feature not covered here, verify it with `mise <subcommand> --help` first — do not assume.
- File tasks require the executable bit (`chmod +x`) to be discovered; mise otherwise warns and skips them (verified). Non-executable `.fish` files under an `includes` directory are never treated as tasks.
- `[task_config]` (and anything beyond bare `[tools]`/`[tasks]` with plain versions) makes the whole `mise.toml` require `mise trust` — this repo's config will need it after Task 1. `boot.sh` already calls `mise trust` before `mise install`.
- Package managers stay for what mise cannot do: GUI apps, fonts, AUR packages, macOS casks, systemd units, `defaults write`. mise only takes over `fish`, `fd`, `gum` (dev-CLI tools it can install via its tool registry) — **not** `git`, which must exist before the repo (and its `mise.toml`) can even be cloned.
- **`mise run <task> -n`/`--dry-run` does not skip execution for file tasks.** Verified directly during this plan's execution (Task 3's review caught it): mise labels the output as a dry run but actually runs the script. Never invoke `mise run bootstrap`, `mise run linux:setup`, `mise run linux:cachyos:cachyos`, `mise run darwin:defaults`, or `mise run darwin:macos` for real during implementation/verification — they perform real `sudo pacman`, `ufw`, `systemctl`, `defaults write`, sudoers-file, and interactive-prompt side effects on whatever machine runs them. `fish -n <file>` (a genuine non-executing syntax check) and `mise tasks ls -x` (discovery only) are the only safe verification tools for these tasks short of a disposable VM/container.

### Current behavior inventory (verified against the actual scripts, not assumed)

| # | Behavior | Where today |
|---|----------|-------------|
| B1 | Password prompt + sudo keepalive loop (60s) | `boot.sh` |
| B2 | Install Homebrew on macOS if missing | `boot.sh` |
| B3 | `pacman -Syu --noconfirm --needed fd fish git gum` on Arch/CachyOS | `boot.sh` |
| B4 | Verify `fd fish git gum` present; friendly red error + `exit 67` | `boot.sh` |
| B5 | `rm -rf` + `git clone` dotfiles into `~/.local/share/dotfiles` | `boot.sh` |
| B6 | `set -Ux DOTFILES ...`; prepend `$DOTFILES/src` to `fish_function_path` | `main.fish` |
| B7 | Source `.env` (gum theme colors); clear + print `art.txt` banner | `main.fish` |
| B8 | `DOTFILES_PROFILE` prompt: `gum confirm "interactive?"` 10s timeout → `full`/`default`, skipped if already set (universal var, so idempotent across re-runs) | `main.fish` |
| B9 | `--reset` flag erases `DOTFILES_HOMEBREW DOTFILES_FULL DOTFILES_MODE DOTFILES_INTERACTIVE DOTFILES_PROFILE` | `main.fish` |
| B10 | On `full`: source every `src/$KERNEL/*.fish` (darwin: `brew`,`defaults`,`macos` in alpha order; linux: only `setup.fish` — `cachyos.fish` is one dir deeper, not matched by this glob) | `main.fish` |
| B11 | `dfs-link` (symlink `home/{common,$kernel}` → `~`, prune stale, manifest) | `main.fish` → `dfs-link.fish` |
| B12 | `exec fish` at the end (drop into fresh login shell) | `main.fish` |
| B13 | `dfs` function re-runs `fish main.fish $argv` (used for `dfs --reset` etc.) | `dfs.fish` |
| D1 | `brew bundle` from Brewfile; needs `dfs-success` | `darwin/brew.fish` |
| D2 | `defaults write` — Dock/Finder/Spotlight/Keyboard/Trackpad/Mission Control/TextEdit/Hot Corners/Window Mgmt/Hammerspoon/loginwindow | `darwin/defaults.fish` |
| D3 | dockutil dock rearrange; hostname/FileVault/Firewall `gum confirm` prompts (all `sudo`-gated) | `darwin/macos.fish` |
| L1 | `shelly sync` / `shelly install --no-confirm $(awk '{print $1}' "pkgs.txt")` / `shelly cache-clean` — **`"pkgs.txt"` is a relative path** | `linux/cachyos/cachyos.fish` |
| L2 | Getty autologin for tty1 if hyprland/niri present; `lactd` enable+start if `lact` present | `linux/cachyos/cachyos.fish` |
| L3 | `source $distro/*.fish` where `$distro` comes from `/etc/os-release` — **relative path, cwd-dependent, does not reliably resolve to `cachyos/cachyos.fish` today** | `linux/setup.fish` |
| L4 | Power profile (balance if on battery, else performance); sshd enable+start; ufw default-deny-in/allow-out + ssh/sunshine rules; Gigabyte suspend workaround unit; efibootmgr sudoers; 1Password allowed-browsers file | `linux/setup.fish` |

### Decisions made during planning (so the "why" isn't re-litigated mid-implementation)

1. **`git` is not migrated to mise.** `boot.sh` needs `git` before it can clone the repo that contains `mise.toml` — a hard chicken-and-egg. It stays on brew/pacman. `fish`, `fd`, `gum` have no such circularity (they're only needed *after* the clone) and move to `mise.toml` `[tools]`.
2. **Tasks stay under `src/`, not a new `mise-tasks/` directory.** Verified live: `[task_config] includes = ["src"]` makes mise auto-discover executable files anywhere under `src/` as tasks, namespaced by subdirectory (`src/linux/cachyos/cachyos.fish` → task `linux:cachyos:cachyos`, confirmed by running it). This avoids renaming/moving any file — smallest possible diff, and just as idiomatic as the `mise-tasks/` convention (both are first-class discovery mechanisms).
3. **`src/dfs.fish`, `dfs-link.fish`, `dfs-spin.fish`, `dfs-success.fish` lose their (currently accidental) executable bit.** They're fish-autoloaded *function* files (`function X ... end`), not scripts — never meant to run standalone. They happen to already be `chmod +x` today (harmless while nothing scans `src/` for tasks). Once `includes = ["src"]` is added, mise *would* pick them up as broken tasks (no shebang) and clutter `mise tasks ls`. Removing `+x` from just these four is a zero-behavior-change fix that keeps task discovery clean. `dfs-migrations.fish` is already non-executable — left alone.
4. **`.env` stays sourced explicitly inside the bootstrap task, not promoted to mise `[env]`.** mise `[env]` would apply the `GUM_*` vars any time mise is active in this directory (e.g. a later `cd` into the repo for unrelated git work) — wider scope than today, where they're only set for the duration of the boot run. Keeping the explicit `source $DOTFILES/.env` line preserves the exact original scope.
5. **Two disclosed, intentional fixes ride along** because the relative paths they touch are being rewritten anyway and the *broken* version cannot be faithfully "preserved" as task-runnable code: L3's `source $distro/*.fish` (cwd-dependent, does not resolve to `cachyos.fish` in practice) becomes an explicit `mise run --cd $DOTFILES "linux:$distro:$distro"`; L1's `"pkgs.txt"` becomes the absolute `"$DOTFILES/src/linux/cachyos/pkgs.txt"`. Everything else in both files is untouched. These are the only two logic changes in the whole migration — every other file is a shebang + `chmod +x` + (for `brew.fish` only) one line to restore `dfs-success` availability (see Task 3).
6. **The pre-flight dependency check (B4) moves from before-clone to after-`mise install`.** `fish`/`fd`/`gum` now live in the repo's own `mise.toml`, so they can only be verified once the repo exists locally. `git` is still checked pre-clone implicitly (the clone itself fails loudly if `git` is missing). Same friendly error text and `exit 67`, just later in the sequence — documented here so it isn't mistaken for scope creep during review.
7. **`bin/mise` (via `mise generate bootstrap -w bin/mise`) is added as a committed, pinned re-entry helper**, not a replacement for `boot.sh`. `boot.sh` still has to fetch *something* over curl before the repo exists; `bin/mise` is for re-running bootstrap later from an existing checkout without depending on whatever mise version happens to be on PATH.

---

### Task 1: Root `mise.toml` — tools + task discovery

**Files:**
- Modify: `mise.toml` (repo root)

**Interfaces:**
- Produces: `[tools]` entries `fish`, `gum`, `fd` (plus the existing `pi = "latest"`, untouched) — later tasks assume these are on PATH via `mise run`/`mise exec`.
- Produces: `[task_config] includes = ["src"]` — every later task (Tasks 3, 4, 5) depends on this for discovery.

- [ ] **Step 1: Confirm current state**

Run: `cat mise.toml`
Expected: only `[tools]\npi = "latest"\n` (matches git status — untracked, single stanza).

- [ ] **Step 2: Write the new root config**

```toml
[tools]
pi = "latest"
fish = "latest"
gum = "latest"
fd = "latest"

[task_config]
includes = ["src"]
```

- [ ] **Step 3: Trust and install**

Run: `mise trust --yes . && mise install --yes`
Expected: `mise trusted <repo path>` then installs `fish`, `gum`, `fd`, `pi` with no errors (each ending `✓ installed`).

- [ ] **Step 4: Verify tools are resolvable**

Run: `mise which fish && mise which gum && mise which fd`
Expected: three absolute paths under `~/.local/share/mise/installs/...`, no errors.

- [ ] **Step 5: Commit**

```bash
git add mise.toml
git commit -m "mise: declare fish/gum/fd as project tools, enable src/ task discovery"
```

---

### Task 2: Strip the stray executable bit from fish *function* files

**Files:**
- Modify (mode only, no content change): `src/dfs.fish`, `src/dfs-link.fish`, `src/dfs-spin.fish`, `src/dfs-success.fish`

**Interfaces:**
- Produces: a `src/` tree where the only executable files are ones meant to run standalone. Task 3/4/5 rely on this being true so `mise tasks ls` doesn't show bogus entries.

- [ ] **Step 1: Confirm which files are currently (wrongly) executable**

Run: `find src -maxdepth 1 -name '*.fish' -perm -u+x`
Expected: `src/dfs.fish`, `src/dfs-link.fish`, `src/dfs-spin.fish`, `src/dfs-success.fish` (4 lines). `src/dfs-migrations.fish` must NOT appear (already non-executable).

- [ ] **Step 2: Remove the bit**

Run: `chmod -x src/dfs.fish src/dfs-link.fish src/dfs-spin.fish src/dfs-success.fish`

- [ ] **Step 3: Verify mise sees no stray tasks from `src/` yet**

Run: `mise tasks ls -x`
Expected: empty (or "no tasks found") — nothing else under `src/` is executable yet at this point in the plan.

- [ ] **Step 4: Commit**

```bash
git add src/dfs.fish src/dfs-link.fish src/dfs-spin.fish src/dfs-success.fish
git commit -m "src: remove stray +x from fish autoload functions (not standalone scripts)"
```

---

### Task 3: macOS scripts → `darwin:*` file tasks

**Files:**
- Modify: `src/darwin/brew.fish`, `src/darwin/defaults.fish`, `src/darwin/macos.fish`

**Interfaces:**
- Consumes: `fish_function_path` no longer auto-includes `$DOTFILES/src` inside a `mise run` subprocess (each task is a fresh fish process) — `brew.fish` must re-add it before calling `dfs-success`.
- Produces: tasks `darwin:brew`, `darwin:defaults`, `darwin:macos`, invoked later by `src/bootstrap.fish` (Task 5).

- [ ] **Step 1: Add shebang + restore `dfs-success` availability to `brew.fish`**

Current content:
```fish
brew bundle --quiet --no-upgrade --file "$DOTFILES/home/darwin/.config/homebrew/Brewfile"
dfs-success "brew bundled"
```

New content:
```fish
#!/usr/bin/env fish
#MISE description="Bundle Homebrew formulae/casks from the Brewfile"
set --prepend fish_function_path "$DOTFILES/src"

brew bundle --quiet --no-upgrade --file "$DOTFILES/home/darwin/.config/homebrew/Brewfile"
dfs-success "brew bundled"
```

- [ ] **Step 2: Add shebang to `defaults.fish` (content otherwise untouched)**

Prepend as the new first two lines:
```fish
#!/usr/bin/env fish
#MISE description="Apply macOS defaults write settings"
```
(everything from `# https://macos-defaults.com` onward stays exactly as-is, including the commented-out `dfs-success` line and commented-out `killall Finder Dock`.)

- [ ] **Step 3: Add shebang to `macos.fish` (content otherwise untouched)**

Prepend:
```fish
#!/usr/bin/env fish
#MISE description="Interactive macOS setup: dock layout, hostname, FileVault, Firewall"
```

- [ ] **Step 4: Make all three executable**

Run: `chmod +x src/darwin/brew.fish src/darwin/defaults.fish src/darwin/macos.fish`

- [ ] **Step 5: Verify task discovery and syntax**

Run: `mise tasks ls -x`
Expected: rows for `darwin:brew`, `darwin:defaults`, `darwin:macos` with the descriptions from Step 1-3, source column pointing at the right file.

Run: `fish -n src/darwin/brew.fish && fish -n src/darwin/defaults.fish && fish -n src/darwin/macos.fish`
Expected: no output, exit 0 (syntax-only check — these scripts have real side effects, do not execute them here).

Do not run `mise run darwin:brew`, `darwin:defaults`, or `darwin:macos` for real, even with `-n`/`--dry-run` — mise's `-n` flag does not actually skip execution for file tasks (it runs the script). `fish -n` above is the safe check; `mise tasks ls -x` confirms discovery without executing anything.

- [ ] **Step 6: Commit**

```bash
git add src/darwin/brew.fish src/darwin/defaults.fish src/darwin/macos.fish
git commit -m "darwin: convert brew/defaults/macos scripts to mise file tasks"
```

---

### Task 4: Linux scripts → `linux:*` file tasks (with the two disclosed path fixes)

**Files:**
- Modify: `src/linux/setup.fish`, `src/linux/cachyos/cachyos.fish`

**Interfaces:**
- Produces: tasks `linux:setup`, `linux:cachyos:cachyos`.
- Consumes: `linux:setup` invokes `linux:cachyos:cachyos` (or whatever distro matches `/etc/os-release`) via `mise run --cd $DOTFILES "linux:$distro:$distro"` — this is Decision 5 from Global Constraints, replacing the non-functional `source $distro/*.fish`.

- [ ] **Step 1: Rewrite `setup.fish`'s distro-dispatch line, add shebang**

Current first two lines:
```fish
# SETUP
set distro (cat /etc/os-release | grep '^ID=' | cut -d= -f2)
source $distro/*.fish
```

New:
```fish
#!/usr/bin/env fish
#MISE description="Linux full-profile setup: distro dispatch, power mgmt, services, firewall"
# SETUP
set distro (cat /etc/os-release | grep '^ID=' | cut -d= -f2)
mise run --cd $DOTFILES "linux:$distro:$distro"
```
Every line after this (`# POWER MANAGEMENT` through the `1password` block, including all the commented-out GNOME/secure-boot sections) is unchanged, verbatim.

- [ ] **Step 2: Fix the relative `pkgs.txt` path in `cachyos.fish`, add shebang**

Current top:
```fish
shelly sync

set pkgs (awk '{print $1}' "pkgs.txt")
shelly install --no-confirm $pkgs 
shelly cache-clean
```

New:
```fish
#!/usr/bin/env fish
#MISE description="CachyOS package sync/install + autologin + lactd"
shelly sync

set pkgs (awk '{print $1}' "$DOTFILES/src/linux/cachyos/pkgs.txt")
shelly install --no-confirm $pkgs
shelly cache-clean
```
Everything from `# DESKTOP` through the final `lactd` block is unchanged, verbatim (still uses `sudo`/`command -vq` exactly as today; `pkgs/aur.txt` and `pkgs/cachy.txt` are untouched data files, not referenced by this script today and not touched by this plan).

- [ ] **Step 3: Make both executable**

Run: `chmod +x src/linux/setup.fish src/linux/cachyos/cachyos.fish`

- [ ] **Step 4: Verify task discovery, namespacing, and syntax**

Run: `mise tasks ls -x`
Expected: `linux:setup` and `linux:cachyos:cachyos` now listed alongside the `darwin:*` rows from Task 3.

Run: `fish -n src/linux/setup.fish && fish -n src/linux/cachyos/cachyos.fish`
Expected: no output, exit 0.

**Do not run `mise run linux:setup` or `mise run linux:cachyos:cachyos`, with or without `-n`/`--dry-run`.** Verified independently during planning: mise's `-n` flag does not actually skip execution for file tasks — it runs the script for real and only labels the output as a dry run. These two tasks perform real `sudo pacman -Syu`, `ufw` enable/reload, `systemctl enable`, and sudoers/systemd-unit file writes on whatever machine runs them. `fish -n` (a pure fish syntax check, confirmed non-executing) is the only safe verification available for these two files short of actually running them on a disposable VM/container.

- [ ] **Step 5: Commit**

```bash
git add src/linux/setup.fish src/linux/cachyos/cachyos.fish
git commit -m "linux: convert setup/cachyos scripts to mise file tasks; fix distro dispatch and pkgs.txt path"
```

---

### Task 5: `src/bootstrap.fish` replaces `main.fish`

**Files:**
- Create: `src/bootstrap.fish`
- Delete: `main.fish`
- Modify: `src/dfs.fish`

**Interfaces:**
- Consumes: tasks `darwin:brew`, `darwin:defaults`, `darwin:macos` (Task 3), `linux:setup` (Task 4).
- Produces: task `bootstrap` — the new entrypoint `boot.sh` (Task 6) and `dfs.fish` both call `mise run --cd $DOTFILES bootstrap $argv`.

- [ ] **Step 1: Create `src/bootstrap.fish`**

```fish
#!/usr/bin/env fish
#MISE description="Full interactive dotfiles bootstrap (replaces main.fish)"

argparse r/reset -- $argv; or return
if set -q _flag_reset
    set --erase DOTFILES_HOMEBREW DOTFILES_FULL DOTFILES_MODE DOTFILES_INTERACTIVE DOTFILES_PROFILE
end

set -Ux DOTFILES (path resolve (status dirname)/..)
set --prepend fish_function_path "$DOTFILES/src"

source $DOTFILES/.env
clear && command cat $DOTFILES/art.txt

if test -z "$DOTFILES_PROFILE"
    if gum confirm "interactive?" --timeout=10s --affirmative=yes --negative=no --default=false
        set -Ux DOTFILES_PROFILE full
    else
        set -Ux DOTFILES_PROFILE default
    end
end

set -x KERNEL (uname | string lower)
if test "$DOTFILES_PROFILE" = full
    switch $KERNEL
        case darwin
            mise run --cd $DOTFILES darwin:brew
            mise run --cd $DOTFILES darwin:defaults
            mise run --cd $DOTFILES darwin:macos
        case linux
            mise run --cd $DOTFILES linux:setup
    end
end

dfs-link
echo "SEE YOU SPACE COWBOY"
exec fish
```

Note the only structural change from `main.fish`: `path resolve (status dirname)` gained a trailing `/..` because this file now lives one directory deeper (`$DOTFILES/src/bootstrap.fish` vs. `$DOTFILES/main.fish`), and the `for script in $DOTFILES/src/$KERNEL/*.fish; source $script; end` loop became an explicit `switch $KERNEL` calling the Task 3/4 tasks by name (a generic re-glob isn't possible here since the darwin/linux task sets have different shapes — 3 flat tasks vs. 1 dispatching task — see Global Constraints Decision 5).

- [ ] **Step 2: Make it executable**

Run: `chmod +x src/bootstrap.fish`

- [ ] **Step 3: Delete `main.fish`**

Run: `git rm main.fish`

- [ ] **Step 4: Update `dfs.fish` to call the task instead of `main.fish`**

Current:
```fish
function dfs
    fish (status dirname)/../main.fish $argv
end
```

New:
```fish
function dfs
    mise run --cd $DOTFILES bootstrap $argv
end
```

- [ ] **Step 5: Verify task discovery and syntax**

Run: `mise tasks ls -x`
Expected: `bootstrap` now listed (top-level, no namespace prefix, since it lives directly in `src/`, the `includes` root) alongside all tasks from Tasks 3-4.

Run: `fish -n src/bootstrap.fish && fish -n src/dfs.fish`
Expected: no output, exit 0.

**Do not run `mise run bootstrap`, with or without `-n`/`--dry-run`.** As discovered during Task 4's planning correction: mise's `-n` flag does not actually skip execution for file tasks — it runs the script for real. `bootstrap` sets a universal fish var, clears the screen, prompts interactively via `gum confirm` (which will hang with no TTY/timeout in a non-interactive subagent), dispatches to the real `darwin:*`/`linux:*` tasks on a `full` profile, and ends with `exec fish`. `fish -n` (syntax check only) is the only safe verification here.

- [ ] **Step 6: Commit**

```bash
git add src/bootstrap.fish src/dfs.fish
git commit -m "bootstrap: replace main.fish with a mise bootstrap task"
```

---

### Task 6: Rewrite `boot.sh`

**Files:**
- Modify: `boot.sh`

**Interfaces:**
- Consumes: task `bootstrap` (Task 5), `[tools]` from `mise.toml` (Task 1).
- Produces: the curl-installable entrypoint end users actually run.

- [ ] **Step 1: Write the new `boot.sh`**

```sh
#!/bin/sh
# Usage: sh -c "$(curl -fsSL boot.roly.sh)"
set -e

exist() {
    for cmd; do command -v "$cmd" >/dev/null || return 1; done
}

missing() {
    for cmd; do command -v "$cmd" >/dev/null || return 0; done
    return 1
}

npc() {
    str="$*"
    while [ -n "$str" ]; do
        printf "%s" "${str%"${str#?}"}"
        str="${str#?}"
        sleep 0.01
    done
    sleep 0.25
    printf "\n"
}

clear
curl -fsSL banner.roly.sh
npc "enter your password to continue (or abort with ctrl+c)..."
sudo true
while true; do sudo --non-interactive true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

if [ "$(uname)" = "Darwin" ]; then
	if missing /opt/homebrew/bin/brew; then
		NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	eval "$(/opt/homebrew/bin/brew shellenv)"
	brew install --yes git
fi

if [ "$(uname)" = "Linux" ] && exist pacman; then
   	sudo pacman -Syu --noconfirm --needed git # Arch
fi

if missing mise; then
    curl -fsSL https://mise.run | sh
fi
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

if missing git; then
    echo
    echo "$(tput setaf 1)ERROR$(tput sgr0) Missing dependencies"
    echo "$(tput sitm)✈ YOU'RE GONNA CARRY THAT WEIGHT.$(tput ritm)"
    exit 67
fi

export DOTFILES="$HOME/.local/share/dotfiles"
rm -rf "$DOTFILES"
git clone https://github.com/ylor/dotfiles "$DOTFILES"
cd "$DOTFILES"
mise trust --yes
mise install --yes

if missing fd fish gum; then
    echo
    echo "$(tput setaf 1)ERROR$(tput sgr0) Missing dependencies"
    echo "Retry by running: 'cd $HOME/.local/share/dotfiles && mise run bootstrap'"
    echo "$(tput sitm)✈ YOU'RE GONNA CARRY THAT WEIGHT.$(tput ritm)"
    exit 67
fi

mise run --cd "$DOTFILES" bootstrap
```

Changes from the original, all traceable to Global Constraints: `brew install`/`pacman -S` now install only `git` (B2/B3, trimmed — `fish`/`fd`/`gum` moved to `mise.toml`); a `mise` install step is inserted (via the official `https://mise.run` installer, verified to place shims at `~/.local/share/mise/shims`); the dependency check (B4) is split — an early `git`-only check before cloning, and the original `fd fish gum` check moved to after `mise install` (Decision 6); the retry hint now points at `mise run bootstrap` instead of `fish main.fish`; the final handoff is `mise run --cd "$DOTFILES" bootstrap` instead of `fish "$DOTFILES/main.fish"`. The password prompt, sudo keepalive loop, banner curl, and `rm -rf`+clone are byte-for-byte unchanged.

- [ ] **Step 2: Syntax-check**

Run: `sh -n boot.sh`
Expected: no output, exit 0.

Run: `command -v shellcheck >/dev/null && shellcheck boot.sh || echo "shellcheck not installed, skipping"`
Expected: no new warnings versus the original file's baseline (run `shellcheck` on the old version first via `git show HEAD:boot.sh | shellcheck -` to compare if shellcheck is available).

- [ ] **Step 3: Commit**

```bash
git add boot.sh
git commit -m "boot.sh: install mise instead of fd/fish/gum via brew/pacman"
```

---

### Task 7: Committed `bin/mise` re-entry helper + README update

**Files:**
- Create: `bin/mise` (generated, not hand-written)
- Modify: `README.md`

**Interfaces:**
- Produces: a pinned, dependency-free way to re-run `mise run bootstrap` from an existing checkout without relying on whatever `mise` happens to be on the operator's PATH.

- [ ] **Step 1: Generate the script**

Run: `mise generate bootstrap -w bin/mise`
Expected: creates `bin/mise`, already executable (the `-w` flag chmods it — verified via `--help`: "write to a file and make it executable").

- [ ] **Step 2: Verify it works standalone**

Run: `./bin/mise --version`
Expected: prints a mise version (downloads/caches its own pinned copy into `~/.cache/mise` on first run if needed, independent of any globally-installed `mise`).

Do not run `./bin/mise run bootstrap` (with or without `-n`) — same reason as Task 5: mise's `-n` does not skip execution for file tasks, and `bootstrap` has real interactive/system side effects. `./bin/mise --version` above and `./bin/mise tasks ls -x` (which only lists tasks, executes nothing) are sufficient to confirm the generated script works standalone.

- [ ] **Step 3: Update README usage section**

Current:
```markdown
## Usage

`sh -c $(curl -fsSL boot.roly.sh)`
```

New:
```markdown
## Usage

First run (fresh machine): `sh -c "$(curl -fsSL boot.roly.sh)"`

Re-run from an existing checkout: `cd ~/.local/share/dotfiles && ./bin/mise run bootstrap`
(or `mise run bootstrap` / `dfs` if `mise` is already on your PATH and activated)
```

- [ ] **Step 4: Commit**

```bash
git add bin/mise README.md
git commit -m "add pinned bin/mise re-entry helper, document re-run path"
```

---

### Task 8: End-to-end verification

**Files:** none (verification only)

- [ ] **Step 1: Full task inventory matches expectations**

Run: `mise tasks ls -x`
Expected exactly these task names (order may vary): `bootstrap`, `darwin:brew`, `darwin:defaults`, `darwin:macos`, `linux:setup`, `linux:cachyos:cachyos`. Nothing named `dfs`, `dfs-link`, `dfs-spin`, `dfs-success`, or `dfs-migrations`.

- [ ] **Step 2: Every task script is syntactically valid**

Run:
```bash
for f in src/bootstrap.fish src/darwin/*.fish src/linux/setup.fish src/linux/cachyos/cachyos.fish; do
  fish -n "$f" || echo "FAIL: $f"
done
```
Expected: no `FAIL` lines.

- [ ] **Step 3: `boot.sh` syntax + full config validity**

Run: `sh -n boot.sh && mise config ls`
Expected: no errors; `mise config ls` shows `mise.toml` as trusted and in use.

- [ ] **Step 4: Confirm untouched files stayed untouched**

Run: `git status home/common/.config/fish/functions/md.fish home/common/.config/fish/functions/mcd.fish home/common/.config/ghostty/themes/mfd-nerv`
Expected: same pending state as before this plan started (these are unrelated pre-existing edits — this migration must not touch or revert them).

- [ ] **Step 5: Review the full diff**

Run: `git log --oneline main..HEAD` (or equivalent for however the work was branched) and `git diff <base>..HEAD --stat`
Expected: touches only `mise.toml`, `boot.sh`, `main.fish` (deleted), `src/bootstrap.fish` (new), `src/dfs.fish`, `src/dfs-link.fish`/`dfs-spin.fish`/`dfs-success.fish` (mode only), `src/darwin/*.fish`, `src/linux/setup.fish`, `src/linux/cachyos/cachyos.fish`, `bin/mise` (new), `README.md`.
