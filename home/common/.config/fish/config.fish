if status is-interactive
    fish_add_path --prepend --move "$HOME/.local/bin"
    fish_vi_key_bindings

    set fish_color_command green
    set fish_color_param green
    set fish_cursor_default block
    set fish_cursor_insert line
    set fish_cursor_replace_one underscore
    # set fish_cursor_visual block

    set fish_greeting
    set -p fish_function_path "$DOTFILES/src"
    set -l os (uname)
    set -x KERNEL (uname | string lower)
    set -x EDITOR vim
    set -x VISUAL vim
    set -x XDG_CACHE_HOME "$HOME/.cache"
    set -x XDG_CONFIG_HOME "$HOME/.config"
    set -x XDG_DATA_HOME "$HOME/.local/share"
    set -x XDG_STATE_HOME "$HOME/.local/state"

    # abbreviations
    abbr d docker
    abbr g git

    abbr -a --position anywhere s sudo
    if test "$os" = Darwin
        abbr b --position anywhere brew
    else if test "$os" = Linux
        abbr pc --position anywhere pacman
    end

    if test "$os" = Darwin
        if test -d (brew --prefix)"/share/fish/completions"
            set -p fish_complete_path (brew --prefix)/share/fish/completions
        end
        if test -d (brew --prefix)"/share/fish/vendor_completions.d"
            set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
        end
    end

    # aliases
    alias mac="test (uname) = Darwin"
    alias linux="test (uname) = Linux"
    alias re="exec fish"

    # for module in $__fish_config_dir/conf.d/{$KERNEL}/*.fish
    for module in $__fish_config_dir/conf.d/{$KERNEL,prompt}/*.fish
        source $module
    end
end
