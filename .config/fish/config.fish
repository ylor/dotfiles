# Fish
set fish_greeting #disable greeting
## Syntax highlighting
set fish_color_command green
# set fish_color_param normal

# Only run this in interactive shells
if status is-interactive
    # I'm trying to grow a neckbeard
    fish_vi_key_bindings
    # Set the cursor shapes for the different vi modes.
    # Emulates vim's cursor shape behavior
    # Set the normal and visual mode cursors to a block
    set fish_cursor_default block
    # Set the insert mode cursor to a line
    set fish_cursor_insert line
    # Set the replace mode cursors to an underscore
    set fish_cursor_replace_one underscore
    set fish_cursor_replace underscore
    # Set the external cursor to a line. The external cursor appears when a command is started.
    # The cursor shape takes the value of fish_cursor_default when fish_cursor_external is not specified.
    set fish_cursor_external line
    # The following variable can be used to configure cursor shape in
    # visual mode, but due to fish_cursor_default, is redundant here
    set fish_cursor_visual block
end

# Abbreviations
abbr --add o open
abbr --add g git

# Aliases
alias h="cd $HOME"
alias liberate="xattr -d com.apple.quarantine"
alias md="mkdir -p"
alias rd="rmdir"
alias re="exec fish"

# Functions
function gc # git clone && cd to it
    set -f slashes (echo $argv | grep -o '/' | wc -l | tr -d ' ')
    set -f repo (switch $slashes
        case 0
            echo "https://github.com/ylor/$argv"
        case 1
            echo "https://github.com/$argv"
        case '*'
             echo $argv
    end)
    git clone $repo && cd "$(basename "$repo" .git)"
end

function fopen
    command $argv[1]
end

function git-me
    git config --global user.email 2200609+ylor@users.noreply.github.comm
    git config --global user.name ylor
end

function git-papa
    git config --global user.email rreyes@papa.com
    git config --global user.name papa-rreyes
end

function mdcd ### mkdir & cd to it
    mkdir $argv && cd $argv
end

## Plugins
if command -q bat # https://github.com/sharkdp/bat - modern cat
    alias cat="bat --pager=never"
end

if command -q brew # https://github.com/Homebrew/brew
    function brew
        if [ $argv[1] = up ]
            # command brew update && command brew upgrade
            echo $argv[1]
            return
        end
        command brew $argv
    end
    abbr b brew
end

if command -q code # https://code.visualstudio.com/ - vscode shorthand
    function c
        # test (count $argv) -eq 0 && code . || code $argv
        test (count $argv) -eq 0 && code . || code $argv
    end
end

if command -q eza # https://github.com/eza-community/eza - modern ls
    alias ls="eza --hyperlink --icons"
    alias ll="ls -l"
    alias la="ls -la"
end

# if command -q fzf # https://github.com/junegunn/fzf - fuzzy finder
#     if command -q fd
#         alias cdi="cd (fd $PWD --type d | fzf)"
#     else
#         alias cdi="cd (find $PWD -type d | fzf)"
#     end
# end

if command -q ollama # https://github.com/BurntSushi/ripgrep - modern grep
    alias llm="ollama run llama3.2"
end

if command -q rg # https://github.com/BurntSushi/ripgrep - modern grep
    alias grep="rg"
end

if command -q zed; or command -q zed-preview # http://zed.dev - zed shorthand
    function z
        set --local zed (which zed-preview || which zed)
        test (count $argv) -eq 0 && $zed . || $zed $argv
    end
end

if command -q zoxide # https://github.com/ajeetdsouza/zoxide - smarter cd
    zoxide init fish --cmd j | source
    # alias cd="j"
    # alias cdi="ji"
end

function fish_prompt
    set --local last_status $status #must be first

    set --local directory $(basename $PWD)
    set --local time $(date +"%-I:%M %p")
    set --local symbol_color $([ $last_status -eq 0 ] && set_color green || set_color red)
    set --local symbol "➜"
    # set --local git_branch $(git rev-parse --abbrev-ref HEAD)
    echo "$directory $symbol_color$symbol $(set_color normal)"
end

function fish_mode_prompt
    # function fish_mode_prompt
    #   switch $fish_bind_mode
    #     case default
    #       set_color --bold red
    #       echo 'N'
    #     case insert
    #       set_color --bold green
    #       echo 'I'
    #     case replace_one
    #       set_color --bold green
    #       echo 'R'
    #     case visual
    #       set_color --bold brmagenta
    #       echo 'V'
    #     case '*'
    #       set_color --bold red
    #       echo '?'
    #   end
    #   set_color normal
    # end
    #
    fish_default_mode_prompt
end

function fish_right_prompt -d "Write out the right prompt"
    date '+%m/%d/%y'
end

# if command -q starship # starship.rs
#     starship init fish | source
#     # enable_transience
# end

# Source all .fish files found in .config/fish/plugins/
# for plugin in $__fish_config_dir/plugins/**.fish
#      source $plugin
#  end

# function spin
#      set -l symbols "⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷"
#      while sleep 0.1
#          echo -e -n "\b$symbols[1]"
#          set symbols $symbols[2..-1] $symbols[1]
#      end
#  end
