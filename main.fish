argparse r/reset h/help -- $argv; or exit 2
if set -q _flag_help
    printf '%s\n' \
        'DFS / SYSTEM CONFIGURATION EXECUTIVE' \
        '' \
        'USAGE / fish main.fish [--reset]' \
        '' \
        'OPTIONS' \
        '  -r, --reset    Clear operator selections.' \
        '  -h, --help     Display command reference.'
    exit 0
end

if set -q _flag_reset
    set --erase DOTFILES_PROFILE
end

set -Ux DOTFILES (path resolve (status dirname))
set --prepend fish_function_path "$DOTFILES/home/.config/fish/functions" "$DOTFILES/functions"

source $DOTFILES/.env
clear && command cat $DOTFILES/art.txt

if test -z "$DOTFILES_PROFILE"
    if gum confirm "SELECT FULL CONFIGURATION PROFILE?" --timeout=10s --affirmative=yes --negative=no --default=false
        set -Ux DOTFILES_PROFILE full
    else
        set -Ux DOTFILES_PROFILE default
    end
end

set os (uname -s | string lower)
set host (hostname -s | string lower)
set layers $DOTFILES $DOTFILES/$os $DOTFILES/$os/hosts/$host

for layer in $layers
    test -d $layer; or continue

    set scripts $layer/setup/*.fish
    if test -f $layer/setup/setup.fish
        set scripts $layer/setup/setup.fish (string match -v $layer/setup/setup.fish $scripts)
    end

    for script in $scripts
        if not source $script
            dfs-failure "system / setup failed"
            exit 1
        end
    end
end

if not dfs-link
    dfs-failure "dotfiles / link failed"
    exit 1
end

printf '█ %sSEE YOU SPACE COWBOY%s\n\n' (set_color --bold --italics) (set_color normal)
exec fish --command 'function fish_greeting; end'
