export HOMEBREW_BUNDLE_FILE="$DOTFILES/darwin/home/.config/homebrew/Brewfile"
export HOMEBREW_DOTFILES_PROFILE="$DOTFILES_PROFILE"
dfs-spin --title="brewing…" -- brew bundle --quiet --no-upgrade
dfs-success "brew bundled"
