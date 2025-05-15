if command -vq gum
    function pls
        if not /usr/bin/sudo -n true 2>/dev/null
            gum input --password --placeholder="password" --no-show-help | sudo --validate --stdin
        end
        command /usr/bin/sudo $argv
    end
end
