function sudo
    set -q argv[1]; or return 1

    if set -q dfs_sudo_session
        if not set -q dfs_sudo_auth_status
            command sudo --validate
            set -g dfs_sudo_auth_status $status
            if test $dfs_sudo_auth_status -eq 0
                # Refresh only after setup first needs privileged access.
                sh -c '
                    trap '\''kill "$sleeper" 2>/dev/null; exit'\'' TERM INT
                    while kill -0 "$1" 2>/dev/null; do
                        sudo -n -v || exit
                        sleep 60 &
                        sleeper=$!
                        wait "$sleeper"
                    done
                ' sh $fish_pid >/dev/null 2>&1 &
                set -g dfs_sudo_keepalive $last_pid
            end
        end
        test $dfs_sudo_auth_status -eq 0; or return $dfs_sudo_auth_status
        command sudo $argv
        return
    end

    if not status --is-interactive
        /usr/bin/sudo $argv
        return
    end

    if /usr/bin/sudo --non-interactive true 2>/dev/null
        /usr/bin/sudo $argv
        return
    end

    for i in (seq 3)
        set -l input (gum input --password --placeholder "Password" --cursor.foreground fff --no-show-help)
        if echo "$input" | /usr/bin/sudo --validate --stdin 2>/dev/null
            /usr/bin/sudo $argv
            return
        end
    end

    gum log --level error "sudo: 3 incorrect password attempts."; and return 1
end
