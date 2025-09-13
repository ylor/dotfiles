# for path in "/opt/homebrew" "/home/linuxbrew/.linuxbrew"
#     [ -d $path ] && "$path/bin/brew" shellenv | source
# end

if command -vq brew # https://github.com/Homebrew/brew
    function brew
        if [ $argv[1] = up ]
            command brew update && brew upgrade
        else
            command brew $argv
        end
    end

    abbr --add b brew
end
