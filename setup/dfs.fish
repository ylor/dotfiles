function dfs --description "Configure the system and manage linked files"
    argparse h/help v/verbose -- $argv; or return 2
    if test (count $argv) -gt 1
        dfs-failure "Expected one command"
        dfs-help
        return 2
    end

    set -l operation "$argv"
    set -q _flag_help; and set operation help
    set -lx dfs_verbose
    set -q _flag_verbose; and set dfs_verbose 1
    set -fx DOTFILES (path resolve (status dirname)/..)

    switch "$operation"
        case '' apply reset
            functions -q sudo; and functions -c sudo dfs-original-sudo
            functions -e sudo
            functions -c dfs-sudo sudo
            function dfs-stop-sudo-keepalive --on-event fish_exit
                if set -q dfs_sudo_keepalive
                    kill $dfs_sudo_keepalive 2>/dev/null
                    set -e dfs_sudo_keepalive
                end
                set -e dfs_sudo_auth_status
            end

            if test "$operation" = reset
                dfs-reset
            else
                dfs-apply
            end
            set -l result $status
            dfs-stop-sudo-keepalive
            functions -e dfs-stop-sudo-keepalive sudo
            if functions -q dfs-original-sudo
                functions -c dfs-original-sudo sudo
                functions -e dfs-original-sudo
            end
            return $result
        case layers link
            dfs-$operation
        case help
            dfs-help
        case '*'
            dfs-failure "Unknown command: $operation"
            dfs-help
            return 2
    end
end
