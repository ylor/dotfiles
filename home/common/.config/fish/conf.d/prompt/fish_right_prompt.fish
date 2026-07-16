# set symbol ""
# set symbol "⌘"
# █ ▓ ▒ ░ ⣿

set --query machine; or set -g machine (string split --max 1 --fields 1 '.' $hostname)
string match --quiet --regex '^PAPA' $machine; and set -g machine papa
function fish_right_prompt
    set_color brblack
    if set --query SSH_CONNECTION
        string lower "❬$USER@$machine❭"
    end
end
