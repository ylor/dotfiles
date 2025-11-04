if status --is-interactive
    set -x EDITOR editor
    set -x VISUAL visual

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
    alias e="editor"
    alias fishfmt="fish_indent --write"
    alias h="cd $HOME"
    alias md="mkdir -p"
    alias rd="rmdir"
    alias re="source $__fish_config_dir/config.fish"
    alias v="visual"

    for module in $__fish_config_dir/{library,prompt}/*.fish
        source $module
    end

    fish_add_path "$DOTFILES/bin"
    fish_add_path -mp "$HOME/.local/bin"
end
