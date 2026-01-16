if ! command -vq /opt/homebrew/bin/brew
    NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
end

dfs-spin --title "brewing..." brew update
dfs-success "brew updated!"

set --export HOMEBREW_BUNDLE_FILE "$DOTFILES_HOME/.config/homebrew/Brewfile"
dfs-spin --title "brewing..." brew bundle
dfs-success "brew bundled!"

# TODO find a way to erase these lines
if [ $DOTFILES_MODE = full ]
    set --export HOMEBREW_BUNDLE_FILE "$DOTFILES_HOME/.config/homebrew/Caskfile"
    dfs-spin --title "casking..." brew bundle
    dfs-success "casks bundled!"
end
