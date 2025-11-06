# function load_uv_completions --on-event fish_prompt
if command -vq uv
    uv generate-shell-completion fish | source
    uvx --generate-shell-completion fish | source
end
<<<<<<< Updated upstream

# function handler --on-event fish_postexec
#     echo generator is done
||||||| Stash base
=======
>>>>>>> Stashed changes
# end
