#!/usr/bin/env fish
function sudo
    if test (count $argv) -eq 0
        return 1
    end

    # Already authenticated — skip prompting
    if command /usr/bin/sudo --non-interactive true 2>/dev/null
        exec command /usr/bin/sudo $argv
    end

    set -l max_attempts 3

    for i in (seq $max_attempts)
        set -l password (gum input --password --placeholder "Enter sudo password" --cursor.foreground fff --no-show-help)
        or break # Ctrl+C / ESC in gum

        test -n "$password"
        and echo "$password" | command /usr/bin/sudo --validate --stdin 2>/dev/null
        and exec command /usr/bin/sudo $argv

        test $i -lt $max_attempts
        and gum log --level error "Sorry, try again."
    end

    gum log --level error "Authentication failed after $max_attempts attempts."
    return 1
end
