set -Ux DOTFILES (realpath (status dirname))
set --prepend fish_function_path "$DOTFILES/src"

argparse 'r/reset' -- $argv; or return
set -q _flag_reset && set --erase DOTFILES_HOMEBREW DOTFILES_FULL DOTFILES_MODE DOTFILES_INTERACTIVE DOTFILES_PROFILE

export GUM_CHOOSE_HEADER_FOREGROUND="#fff"
export GUM_CONFIRM_PROMPT_FOREGROUND="#FFF"
export GUM_CONFIRM_SELECTED_BACKGROUND=""
export GUM_CONFIRM_SELECTED_FOREGROUND="#FFF"
export GUM_CONFIRM_UNSELECTED_BACKGROUND=""
export GUM_CONFIRM_UNSELECTED_FOREGROUND="#666"

clear
cat $DOTFILES/art.txt

if test -z $DOTFILES_PROFILE
    if gum confirm "interactive?" --timeout=10s --affirmative=yes --negative=no --default=false
        set -Ux DOTFILES_PROFILE full
    else
        set -Ux DOTFILES_PROFILE default
    end
end

set KERNEL (uname | string lower)
if test "$DOTFILES_PROFILE" = full
    for script in $DOTFILES/$KERNEL/scripts/*.fish
        source $script
    end
end

dfs-spin --title="linking…" -- fish --interactive --command "dfs-link --minimal"
