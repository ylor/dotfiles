# function load_uv_completions --on-event fish_prompt
if command -q uv
    uv generate-shell-completion fish | source
    uvx --generate-shell-completion fish | source
end
