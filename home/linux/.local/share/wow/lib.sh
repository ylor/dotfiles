# shellcheck disable=SC2034
# Shared helpers for the wow commands. Sourced, not run.
# A command sets allow_check=1 before parse_args if it accepts --check.

check=0
forever=
allow_check=0

usage() {
    printf '%s\n' \
        'Usage: wow [play] [--forever-dir PATH]             Update addons, then launch through Battle.net' \
        '       wow addons [--check] [--forever-dir PATH]  Install or update addons' \
        '       wow toons [--forever-dir PATH]             List characters, copy to clipboard' \
        'After addons, run /reload in game to load updates. Addon settings are preserved.'
}

fail() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

# Parses the flags every command shares. Sets $check and $forever.
parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --check)
                [ "$allow_check" -eq 1 ] || fail '--check only applies to wow addons'
                check=1
                ;;
            --forever-dir)
                [ "$#" -ge 2 ] || fail '--forever-dir needs a path'
                forever=$2
                shift
                ;;
            -h | --help)
                usage
                exit 0
                ;;
            *)
                usage >&2
                exit 2
                ;;
        esac
        shift
    done
}

# Sets $forever to the game's _forever_ folder unless --forever-dir gave it.
find_forever() {
    [ -z "$forever" ] || return 0
    found=
    for game in "$HOME"/Games/*/drive_c/Program\ Files*/World\ of\ Warcraft/_forever_ \
        "$HOME"/.wine/drive_c/Program\ Files*/World\ of\ Warcraft/_forever_; do
        [ -d "$game" ] || continue
        found="$found$game
"
        forever=$game
    done
    [ -n "$forever" ] || fail 'No Forever install found; use --forever-dir'
    if [ "$(printf '%s' "$found" | wc -l)" -gt 1 ]; then
        printf '%s' "$found" >&2
        fail 'Multiple Forever installs found; use --forever-dir with one of the above'
    fi
}
