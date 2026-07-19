if command -q mise
    mise activate fish | source
    mise settings ruby.compile=true
end
# https://github.com/ublue-os/toolboxes/tree/main/toolboxes/bluefin-cli/files
# if command -q pacman paru # Arch
#     if command -q mise
#         mise activate fish | source
#         test -f $HOME/.config/fish/completions/mise.fish; or mise completion fish >$HOME/.config/fish/completions/mise.fish
#     end
# end
# 
# 
