# TODO

- Explore bloom/glow for Omarchy window borders: prototype with colored Hyprland shadows, then consider a Hyprland rendering plugin for true bloom, with Omarchy theme/settings integration.

- Revisit browser extension installation for Helium and Chromium (1Password and Dark Reader).

- Review setup ordering: shared Linux configuration runs before distro package installation. Ensure services installed by distro layers are configured on the first run.

- Make package lists easier to maintain: read Omarchy's install list from the currently unused `setup/omarchy/pkgs.txt`, and move its hardcoded package removals into a separate list. Keep each platform's native package manager.
- Clarify configuration naming: `DOTFILES_PROFILE` currently selects macOS package scope, separately from platform layers. Consider renaming the tracked Fish configuration `.env` to `config.fish`.
