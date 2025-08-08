# set TERM xterm-256color #fix for ghostty
set fish_greeting #disable greeting

## Syntax highlighting
set fish_color_command green
set fish_color_param white

# Only run this in interactive shells
if status is-interactive
    fish_vi_key_bindings # I'm trying to grow a neckbeard

    # Set the cursor shapes for the different vi modes.
    set fish_cursor_default block
    set fish_cursor_insert line
    set fish_cursor_replace_one underscore
    set fish_cursor_visual block
end

# Abbreviations
abbr --add !! --position anywhere --function bangbang
abbr --add dotdot --regex '^\.\.+$' --function dotdot
abbr --add o open

# Aliases
alias h="cd $HOME"
alias md="mkdir -p"
alias rd="rmdir"
alias re="exec fish"
alias fishfmt="fish_indent --write"

for prompt in $__fish_config_dir/prompt/**.fish
    source $prompt
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/roly/.lmstudio/bin
# End of LM Studio CLI section

