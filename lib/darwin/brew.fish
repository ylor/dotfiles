set --universal --export HOMEBREW_NO_ANALYTICS 1
set --universal --export HOMEBREW_NO_AUTO_UPDATE 1
set --universal --export HOMEBREW_NO_ENV_HINTS 1

brew bundle install --quiet --file="$DOTFILES/lib/darwin/Brewfile"

if [ $DOTFILES_MODE = full ]
    brew bundle install --quiet --file="$DOTFILES/lib/darwin/Caskfile"
end
