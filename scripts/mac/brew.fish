dfs-spin --title "brewing..." brew update
brew upgrade --quiet

set --export HOMEBREW_BUNDLE_FILE "$DOTFILES_HOME/.config/homebrew/Brewfile"
brew bundle --quiet

# TODO find a way to erase these lines
if [ $DOTFILES_MODE = full ]
    set --export HOMEBREW_BUNDLE_FILE "$DOTFILES_HOME/.config/homebrew/Caskfile"
    brew bundle --quiet
end

dfs-success "brewed!"
