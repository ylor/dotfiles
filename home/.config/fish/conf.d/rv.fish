# function load_rv_completions --on-event fish_prompt
if command -vq rv
    rv shell init fish | source
end
# end
