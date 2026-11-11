#!/usr/bin/env fish
# Configure the system and manage linked files.
# Layer scripts in setup/<layer>/*.fish run in this process and can use the functions below.

# Use this checkout, not whatever DOTFILES the shell inherited.
set -gx DOTFILES (path resolve (status dirname))

function dfs-success
    printf '[OK] %s\n' (string lower -- "$argv")
end

function dfs-failure
    printf '[ERR] %s\n' (string lower -- "$argv") >&2
end

function dfs-help
    command cat $DOTFILES/art.txt
    printf '\n%s\n' 'Usage: dfs [options] [command]'
    printf '%s\n' \
        '' \
        'Options:' \
        '  -h, --help     Show help' \
        '  -v, --verbose  Print script paths during setup' \
        '' \
        'Commands:' \
        '  apply   Configure system (default)' \
        '  reset   Clear saved profile and reconfigure' \
        '  link    Update managed symlinks' \
        '  layers  List layers in application order' \
        '  help    Show help'
end

function dfs-layers
    set -l platform (string lower (uname -s))
    set -l layers base $platform

    if test $platform = linux; and test -r /etc/os-release
        set --append layers (string match --groups-only --regex '^ID="?([^"]+)' </etc/os-release)
    end

    printf '%s\n' $layers
end

function dfs-link
    argparse q/quiet -- $argv; or return 2
    set links
    set fixed 0
    for layer in (dfs-layers)
        set home $DOTFILES/home/$layer
        test -d $home; or continue

        for file in (fd --hidden --absolute-path --type file --type symlink . $home)
            set link $HOME/(string replace -- "$home/" '' $file)
            if test "$(readlink $link 2>/dev/null)" != $file
                mkdir -p (path dirname $link)
                ln -sf $file $link
                set fixed (math $fixed + 1)
            end
            set --append links $link
        end
    end

    set manifest $HOME/.local/state/dotfiles/manifest
    mkdir -p (path dirname $manifest)

    set removed 0
    for link in (cat $manifest 2>/dev/null)
        contains -- $link $links; and continue
        test -L $link; or continue
        string match -q "$DOTFILES/*" (readlink $link); or continue
        rm $link
        set removed (math $removed + 1)

        # rmdir refuses folders that are not empty, so the walk up stops at the first one still in use.
        set dir (path dirname $link)
        while test $dir != $HOME; and rmdir $dir 2>/dev/null
            set dir (path dirname $dir)
        end
    end

    string join \n $links | sort -u >$manifest

    # The repair pass after the layers stays silent unless something had to be relinked.
    if set -q _flag_quiet; and test $fixed -eq 0; and test $removed -eq 0
        return 0
    end

    set -l summary (count $links)
    test $removed -gt 0; and set summary "$summary, −$removed"
    set -q _flag_quiet; and set summary "relinked $fixed, $summary"
    dfs-success "Dotfiles ($summary)"
end

# Ask for the password only when a layer first needs root, then keep it fresh until exit.
function sudo
    set -q argv[1]; or return 1

    if not set -q dfs_sudo_keepalive
        command sudo --validate; or return
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

    command sudo $argv
end

function dfs-stop-sudo-keepalive --on-event fish_exit
    set -q dfs_sudo_keepalive; and kill $dfs_sudo_keepalive 2>/dev/null
end

# A `return` in a sourced script leaves the calling function, so source layer scripts here to keep dfs-apply running its failure check.
function dfs-source
    source $argv[1]
end

function dfs-apply
    test -f $DOTFILES/.env; and source $DOTFILES/.env
    clear
    command cat $DOTFILES/art.txt

    if test -z "$DOTFILES_PROFILE"
        if gum confirm "use full profile? default: standard (10s timeout)." --timeout=10s --affirmative=yes --negative=no --default=false
            set -Ux DOTFILES_PROFILE full
        else
            set -Ux DOTFILES_PROFILE default
        end
    end

    # Layer scripts need the linked files, e.g. the hypr plugin build.
    dfs-link; or return $status

    set -l failed_scripts
    for name in (dfs-layers)
        set layer $DOTFILES/setup/$name
        test -d $layer; or continue

        for script in $layer/*.fish
            set -q dfs_verbose; and echo "[RUN] "(string lower -- (string replace -- $HOME '~' $script))
            dfs-source $script
            set -l script_status $status
            if test $script_status -ne 0
                dfs-failure "Script failed: $script (exit $script_status)"
                set -a failed_scripts $script
            end
        end
    end

    # Relink because some omarchy commands edit configs in place and replace symlinks.
    dfs-link --quiet
    set -l link_status $status
    if test $link_status -ne 0
        dfs-failure "Managed symlink update failed"
        return $link_status
    end

    printf '\n%sSEE YOU SPACE COWBOY%s\n\n' (set_color --bold) (set_color normal)

    if test (count $failed_scripts) -gt 0
        dfs-failure "Finished with "(count $failed_scripts)" failed script(s):"
        for script in $failed_scripts
            echo "  $script"
        end
        return 1
    end
end

argparse h/help v/verbose -- $argv; or exit 2
if test (count $argv) -gt 1
    dfs-failure "Expected one command"
    dfs-help
    exit 2
end

set operation "$argv"
set -q _flag_help; and set operation help
set -q _flag_verbose; and set -g dfs_verbose

switch "$operation"
    case '' apply
        dfs-apply
    case reset
        set --erase DOTFILES_PROFILE
        dfs-apply
    case layers
        dfs-layers
    case link
        dfs-link
    case help
        dfs-help
    case '*'
        dfs-failure "Unknown command: $operation"
        dfs-help
        exit 2
end
