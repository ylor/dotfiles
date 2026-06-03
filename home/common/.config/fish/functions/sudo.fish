function sudo
    set -q argv[1]; or return 1

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
