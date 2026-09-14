function dfs-sudo --wraps sudo
    set -q argv[1]; or return 1

    if not set -q dfs_sudo_auth_status
        command sudo --validate
        set -g dfs_sudo_auth_status $status
        if test $dfs_sudo_auth_status -eq 0
            # Authenticate only when setup first needs privileged access.
            fish --no-config -c '
                function stop --on-signal TERM --on-signal INT
                    if set -q sleeper
                        kill $sleeper 2>/dev/null
                    end
                    exit
                end
                while kill -0 $argv[1] 2>/dev/null
                    command sudo -n -v; or exit
                    sleep 60 &
                    set -g sleeper $last_pid
                    wait $sleeper
                end
            ' $fish_pid >/dev/null 2>&1 &
            set -g dfs_sudo_keepalive $last_pid
        end
    end
    test $dfs_sudo_auth_status -eq 0; or return $dfs_sudo_auth_status
    command sudo $argv
end
