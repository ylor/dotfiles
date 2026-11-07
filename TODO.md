# TODO

- Explore bloom/glow for Omarchy window borders: prototype with colored Hyprland shadows, then consider a Hyprland rendering plugin for true bloom, with Omarchy theme/settings integration.

- Fix 1Password's auth modal: it tiles instead of floating. The window rules in `home/omarchy/.config/hypr/hyprland.lua` are commented out until then.

- Review setup ordering: shared Linux configuration runs before distro package installation. Ensure services installed by distro layers are configured on the first run.

- Make package lists easier to maintain: read Omarchy's install list from the currently unused `setup/omarchy/pkgs.txt`, and move its hardcoded package removals into a separate list. Keep each platform's native package manager.
- Clarify configuration naming: `DOTFILES_PROFILE` currently selects macOS package scope, separately from platform layers. Consider renaming the tracked Fish configuration `.env` to `config.fish`.

- Move the papa SSH key selection from SSH to git: set `core.sshCommand` (papa key, `IdentitiesOnly`, separate `ControlPath`) in `home/base/.config/git/papa`, then remove the `pwd | grep -i papa` match block and the github.com `ControlMaster no` block from `home/base/.ssh/config`.

- Choose a cross-platform Wake-on-LAN CLI. `github:trugamr/wol` is in `home/base/.config/mise/config.toml` but not installed yet: it adds named machines, status checks, and a web UI, but downloads a binary. The alternative is a small Python script at `home/base/.local/bin/wol`, which needs only `python3` and can be read at a glance. Bash `/dev/udp` and `nc` can't reliably send broadcast packets. If the script wins, remove the mise entry.
