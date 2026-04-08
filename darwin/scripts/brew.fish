# if ! command -vq /opt/homebrew/bin/brew
#     NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#     eval "$(/opt/homebrew/bin/brew shellenv)"
# end

# dfs-spin --title "brewing..." brew update
# dfs-success "brew updated!"
export HOMEBREW_DOTFILES_MODE=$DOTFILES_MODE
dfs-spin --title="brewing…" -- brew bundle --file "$DOTFILES/home/darwin/.config/homebrew/Brewfile" --quiet --no-upgrade
dfs-success "brew bundled"

# if test "$DOTFILES_MODE" = full
#     set --export HOMEBREW_BUNDLE_FILE "$DOTFILES_HOME/.config/homebrew/Caskfile"
#     # dfs-spin --title "casking..." brew bundle
#     brew bundle
#     dfs-success "casks bundled!"
# end
