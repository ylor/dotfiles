if command -vq uv
    uv generate-shell-completion fish | source
    uvx --generate-shell-completion fish | source
end
