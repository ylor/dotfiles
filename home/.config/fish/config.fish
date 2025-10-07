# set fish_greeting #disable greeting
fish_add_path "$HOME/.local/bin"

if status --is-interactive

    # Syntax highlighting
    # fish_config theme choose Lava
    set fish_color_command green
    set fish_color_param white

    fish_vi_key_bindings # I'm trying to grow a neckbeard
    set fish_cursor_default block
    set fish_cursor_insert line
    set fish_cursor_replace_one underscore
    set fish_cursor_visual block

    # Abbreviations
    abbr --add b brew
    abbr --add d docker
    abbr --add g git
    abbr --add k kubectl

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
    alias re="source $__fish_config_dir/config.fish"
    alias v="vim"

    source $DOT_PATH/bin/dot.fish
    for module in $__fish_config_dir/{library,prompt}/*.fish
        source $module
    end
end
