function dfs-layers --description "List managed layers in application order"
    set -l platform (string lower (uname -s))
    set -l layers base $platform

    if test $platform = linux; and test -r /etc/os-release
        set --append layers (string match --groups-only --regex '^ID="?([^"]+)' </etc/os-release)
    end

    printf '%s\n' $layers
end
