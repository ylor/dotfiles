# https://github.com/ublue-os/toolboxes/tree/main/toolboxes/bluefin-cli/files
if test (uname) = Linux
    alias open="xdg-open"
    if command -vq pacman # Arch
        if command -vq mise
            mise activate fish | source
            mise completion fish >$HOME/.config/fish/completions/mise.fish
        end
    end
end
