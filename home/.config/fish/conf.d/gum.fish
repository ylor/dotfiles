if command -vq gum
    function pls
        gum input --password --placeholder="password" --no-show-help | sudo --validate --stdin
        and sudo $argv
    end
end
