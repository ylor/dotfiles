set --universal --export HOMEBREW_NO_ANALYTICS 1
set --universal --export HOMEBREW_NO_AUTO_UPDATE 1
set --universal --export HOMEBREW_NO_ENV_HINTS 1
# set --universal --export HOMEBREW_USE_INTERNAL_API 1

set --export HOMEBREW_BUNDLE_FILE "$DOTFILES_HOME/.config/homebrew/Brewfile"
brew bundle --quiet

# TODO find a way to erase these lines
if [ $DOTFILES_MODE = full ]
    set --export HOMEBREW_BUNDLE_FILE "$DOTFILES_HOME/.config/homebrew/Caskfile"
    brew bundle --quiet
end
