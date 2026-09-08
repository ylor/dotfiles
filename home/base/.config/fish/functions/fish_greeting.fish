function fish_greeting
#     if test -n "$SSH_CONNECTION"; or test -n "$SSH_CLIENT"
#         machine_report
#         return
#     end
#
#     set -l state_dir "$HOME/.local/state/fish"
#     set -q XDG_STATE_HOME[1]; and set state_dir "$XDG_STATE_HOME/fish"
#     set -l marker "$state_dir/machine_report_date"
#     set -l today (date +%F)
#     test -f "$marker"; and test (date -r "$marker" +%F) = "$today"; and return
#
#     machine_report; and mkdir -p "$state_dir"; and touch "$marker"
    machine_report
end
