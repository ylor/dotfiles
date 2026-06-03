# function load_uv_completions --on-event fish_prompt
if command -q uv
    test -f $HOME/.config/fish/completions/uv.fish; or uv generate-shell-completion fish >$HOME/.config/fish/completions/uv.fish
    test -f $HOME/.config/fish/completions/uvx.fish; or uvx --generate-shell-completion fish >$HOME/.config/fish/completions/uvx.fish
end
