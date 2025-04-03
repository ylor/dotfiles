# /opt/homebrew/bin/brew shellenv

for path in \
"$HOME/bin" \
"$HOME/.local/bin" \
"/opt/homebrew/bin" \
"/opt/homebrew/opt/mise/bin"
    [ -d $path ] && fish_add_path $path
end

# [ -e /opt/homebrew/bin/ ] && fish_add_path "/opt/homebrew/bin"
# [ -e /opt/homebrew/opt/mise/bin ] && fish_add_path

if command -q brew # https://github.com/Homebrew/brew
    function brew
        if [ $argv[1] = up ]
            # command brew update && command brew upgrade
            command brew update && brew upgrade
            return
        end
        command brew $argv
    end
    abbr b brew
end
