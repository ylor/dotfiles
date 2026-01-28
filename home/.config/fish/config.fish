if status --is-interactive
    set -x KERNEL (uname | string lower)
    set -x DARWIN (test $KERNEL = "darwin" && echo true || echo false)
    set -x LINUX (test $KERNEL = "linux"  && echo true || echo false)

    set -x EDITOR vim
    set -x VISUAL vim

    set -x XDG_CACHE_HOME "$HOME/.cache"
    set -x XDG_CONFIG_HOME "$HOME/.config"
    set -x XDG_DATA_HOME "$HOME/.local/share"
    set -x XDG_STATE_HOME "$HOME/.local/state"
    set -x XDG_RUNTIME_DIR "/run/user/$EUID"

    # Syntax highlighting
    set fish_color_command green
    set fish_color_normal brblack
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
    abbr --add o open

    # Aliases
    alias h="cd $HOME"
    alias mcd="mkdir -p"
    alias md="mkdir -p"
    alias rd="rmdir"
    alias re="source $__fish_config_dir/config.fish"

    for module in $__fish_config_dir/conf.d/{$KERNEL,prompt}/*.fish
        source $module
    end

    fish_add_path "$DOTFILES/bin" \
        "$HOME/.local/bin" \
        "$HOME/.local/bin/$KERNEL"
    fish_add_path --prepend --move "$HOME/.local/bin"
end
