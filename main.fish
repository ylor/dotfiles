argparse r/reset -- $argv; or return
if set -q _flag_reset
    set --erase DOTFILES_HOMEBREW DOTFILES_FULL DOTFILES_MODE DOTFILES_INTERACTIVE DOTFILES_PROFILE
end

set -Ux DOTFILES (path resolve (status dirname))
set --prepend fish_function_path "$DOTFILES/src"

source $DOTFILES/.env
clear && command cat $DOTFILES/art.txt
if test -z $DOTFILES_PROFILE
    if gum confirm "interactive?" --timeout=10s --affirmative=yes --negative=no --default=false
        set -Ux DOTFILES_PROFILE full
    else
        set -Ux DOTFILES_PROFILE default
    end
end

set -x KERNEL (uname | string lower)
if test "$DOTFILES_PROFILE" = full
    for script in $DOTFILES/src/$KERNEL/*.fish
        source $script
    end
end

dfs-link
echo "SEE YOU SPACE COWBOY"
exec fish
