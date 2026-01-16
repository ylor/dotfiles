# https://github.com/ublue-os/toolboxes/tree/main/toolboxes/bluefin-cli/files
if command -vq pacman paru # Arch
    if command -vq mise
        mise activate fish | source
        mise completion fish >$HOME/.config/fish/completions/mise.fish
    end
end
