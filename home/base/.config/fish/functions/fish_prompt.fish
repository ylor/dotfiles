set -g fish_transient_prompt 1
set -g prompt_duration_threshold 1000

set -g __fish_git_prompt_showdirtystate true
set -g __fish_git_prompt_showuntrackedfiles true
set -g __fish_git_prompt_showupstream informative
set -g __fish_git_prompt_color_branch normal --italics
set -g __fish_git_prompt_char_stateseparator ''
set -g __fish_git_prompt_char_stagedstate ' +'
set -g __fish_git_prompt_char_invalidstate ' #'
set -g __fish_git_prompt_char_dirtystate ' '
set -g __fish_git_prompt_char_untrackedfiles ' ?'
set -g __fish_git_prompt_char_stashstate ' $'
set -g __fish_git_prompt_char_upstream_ahead ' ↑'
set -g __fish_git_prompt_char_upstream_behind ' ↓'
set -g __fish_git_prompt_char_upstream_diverged ' ↑ ↓'
set -g __fish_git_prompt_char_upstream_equal ' '

function fish_prompt
    set -l last_pipestatus $pipestatus
    set -l command_duration $CMD_DURATION

    if contains -- --final-rendering $argv
        if test $command_duration -ge $prompt_duration_threshold
            set_color normal
            printf '%ss ' (math --scale=1 $command_duration / 1000)
        end

        set_color normal --bold
        printf '→ '
        set_color normal
        return
    end

    set -l failed false
    for code in $last_pipestatus
        if test $code -ne 0
            set failed true
            break
        end
    end

    if test -n "$SSH_CONNECTION"; or test -n "$SSH_CLIENT"
        set_color normal
        printf '❬%s@%s❭ ' $USER (prompt_hostname)
    end
    set_color --bold green
    printf '%s' (path basename (prompt_pwd) | string trim -l -c .)
    set_color normal
    # fish_git_prompt ' ❬%s❭'
    fish_git_prompt ' %s'

    if test $command_duration -ge $prompt_duration_threshold
        set_color normal
        printf ' %ss' (math --scale=1 $command_duration / 1000)
    end

    if test $failed = true
        set_color red
        printf ' | %s' (string join ' ' $last_pipestatus)
    end

    if test $failed = true
        set_color red --bold
    else
        set_color normal --bold
    end
    printf ' →'
    set_color normal
    printf ' '
end
