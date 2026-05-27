if status --is-interactive
    fish_add_path --prepend --move "$HOME/.local/bin"
    fish_vi_key_bindings # i'm trying to grow a neckbeard

    set fish_color_command green
    set fish_color_param green
    set fish_cursor_default block
    set fish_cursor_insert line
    set fish_cursor_replace_one underscore
    set fish_cursor_visual block
    set fish_greeting
    set fish_prompt_pwd_dir_length 0

    set -p fish_function_path "$DOTFILES/src"

    set -x KERNEL (string lower (uname))
    set -x EDITOR vim
    set -x VISUAL vim
    set -x XDG_CACHE_HOME "$HOME/.cache"
    set -x XDG_CONFIG_HOME "$HOME/.config"
    set -x XDG_DATA_HOME "$HOME/.local/share"
    set -x XDG_STATE_HOME "$HOME/.local/state"

    # abbreviations
    abbr d docker
    abbr g git

    # aliases
    alias mac="test (uname) = Darwin"
    alias linux="test (uname) = Linux"
    alias re="exec fish"

    # for module in $__fish_config_dir/conf.d/{$KERNEL}/*.fish
    for module in $__fish_config_dir/conf.d/{$KERNEL,prompt}/*.fish
        source $module
    end
end
