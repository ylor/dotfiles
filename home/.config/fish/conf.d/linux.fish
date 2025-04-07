# https://github.com/ublue-os/toolboxes/tree/main/toolboxes/bluefin-cli/files
if test (uname) = Linux
    if command -q pacman # Arch
        if command -q mise
            mise activate fish | source
            mise completion fish > $HOME/.config/fish/completions/mise.fish
        end
    end
end
