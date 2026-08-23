argparse r/reset -- $argv; or return
if set -q _flag_reset
    set --erase DOTFILES_HOMEBREW DOTFILES_FULL DOTFILES_MODE DOTFILES_INTERACTIVE DOTFILES_PROFILE
end

set -Ux DOTFILES (path resolve (status dirname))
set --prepend fish_function_path "$DOTFILES/home/.config/fish/functions" "$DOTFILES/functions"

source $DOTFILES/.env
clear && command cat $DOTFILES/art.txt

if test -z "$DOTFILES_PROFILE"
    if gum confirm "interactive?" --timeout=10s --affirmative=yes --negative=no --default=false
        set -Ux DOTFILES_PROFILE full
    else
        set -Ux DOTFILES_PROFILE default
    end
end

dfs-link

set os (uname -s | string lower)
set host (hostname -s | string lower)
set layers $DOTFILES $DOTFILES/$os $DOTFILES/$os/hosts/$host

for layer in $layers
    test -d $layer; or continue

    set setup $layer/setup
    if test -d $setup
        for script in $setup/*.fish
            source $script
        end
    end
end

echo "SEE YOU SPACE COWBOY"
exec fish --command 'function fish_greeting; end'
