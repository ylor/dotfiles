# # --- config ---
# set --query machine; or set -g machine (string split --max 1 --fields 1 '.' $hostname)
# string match --quiet --regex '^PAPA' $machine; and set -g machine papa

# set prompt_symbol '→'
# set git_marker_dirty '•'
# set git_marker_untracked '?'
# set git_marker_ahead '↑'
# set git_marker_behind '↓'

# # --- events ---
# function _usgc_preexec --on-event fish_preexec
#     set --global _cmd_ran 1
# end

# # --- secments ---
# function _sec_host
#     # if set --query SSH_CONNECTION
#         echo -n "❬$USER@$machine❭"
#     # end
# end

# function _sec_cwd
#     set_color --bold
#     if test $PWD = $HOME
#         echo -n '~'
#     else
#         echo -n (path basename $PWD)
#     end
#     set_color --reset
# end

# function _sec_duration
#     if set --query _cmd_ran && test $CMD_DURATION -gt 1000
#         set_color brblack
#         set --erase _cmd_ran
#         # avoid command substitution subshell
#         set scale 1
#         test $CMD_DURATION -gt 10000; and set scale 0
#         echo -n " "(math --scale $scale $CMD_DURATION / 1000)s
#         set_color --reset
#     end
# end

# function _sec_arrow --argument-names last_status
#     set color normal
#     test $last_status -eq 0; or set color red
#     set_color $color
#     echo -n " $prompt_symbol "
# end

# function _sec_git
#     set git_info (command git --no-optional-locks status --porcelain=v2 --branch 2>/dev/null)
#     test $status -eq 0; or return

#     set branch (string match --regex --groups-only '^# branch\.head (.+)' $git_info)
#     set ab (string match --regex --groups-only '^# branch\.ab \+(\d+) -(\d+)' $git_info)

#     # test "$branch" = main; and echo -n "❬"; or echo -n "❬$branch"
#     echo -n ' ❬'
#     # set_color --italic
#     echo -n "$branch"
#     # set_color --reset brblack
#     string match --quiet --regex '^[12u]' $git_info; and echo -n "$git_marker_dirty"
#     string match --quiet --regex '^\?' $git_info; and echo -n "$git_marker_untracked"
#     if set -q ab[1]
#         test $ab[1] -gt 0; and echo -n "$git_marker_ahead$ab[1]"
#         test $ab[2] -gt 0; and echo -n "$git_marker_behind$ab[2]"
#     end
#     echo -n '❭'
# end

# # --- prompt ---
# function fish_prompt # https://github.com/usgraphics/usgc-themes/
#     set last_status $status

#     _sec_cwd
#     _sec_git
#     _sec_duration
#     _sec_arrow $last_status
# end

# function fish_right_prompt
#     set_color brblack
#     _sec_host
# end

# function fish_mode_prompt
# end

# function fish_title
#     set -q SSH_CLIENT SSH_TTY && echo "[$(prompt_hostname)] "
#     # set -q SSH_CLIENT SSH_TTY && echo "❬$(prompt_hostname)❭ "

#     if test $PWD = $HOME
#         echo 👻
#     else if set -q argv[1]
#         echo $argv
#     else
#         path basename $PWD
#     end
# end
