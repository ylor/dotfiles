function sudo
    test (count $argv) -eq 0; and return 1

    if /usr/bin/sudo --non-interactive true 2>/dev/null
        /usr/bin/sudo $argv
        return
    end

    for i in (seq 3)
        set -l password (gum input --password --placeholder "Enter sudo password" --cursor.foreground fff --no-show-help)
        or return 1

        if echo "$password" | /usr/bin/sudo --validate --stdin 2>/dev/null
            /usr/bin/sudo $argv
            return
        end

        test $i -lt 3; and gum log --level error "Sorry, try again."
    end

    gum log --level error "Authentication failed after 3 attempts."
    return 1
end
