# set fish_greeting #disable greeting

if test -d "$HOME/.local/bin"
    fish_add_path "$HOME/.local/bin"
end

if status --is-interactive
    ## Syntax highlighting
    # fish_config theme choose Lava
    set fish_color_command green
    set fish_color_param white

    # Only run this in interactive shells
    # if status is-interactive
    fish_vi_key_bindings # I'm trying to grow a neckbeard

    # Set the cursor shapes for the different vi modes.
    set fish_cursor_default block
    set fish_cursor_insert line
    set fish_cursor_replace_one underscore
    set fish_cursor_visual block
    # end

    # Abbreviations
    abbr --add b brew
    abbr --add d docker
    abbr --add g git
    abbr --add k kubectl
    abbr --add !! --position anywhere --function bangbang
    abbr --add dotdot --regex '^\.\.+$' --function dotdot

    # Aliases
    # alias b="brew"
    # alias d="docker"
    alias e="zed"
    alias fishfmt="fish_indent --write"
    # alias g="git"
    alias h="cd $HOME"
    # alias k="kubectl"
    alias md="mkdir -p"
    alias rd="rmdir"
    alias re="exec fish"
    alias v="vim"

    for module in $__fish_config_dir/library/*.fish
        source $module
    end

    for prompt in $__fish_config_dir/prompt/*.fish
        source $prompt
    end
end
