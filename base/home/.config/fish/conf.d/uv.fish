# function load_uv_completions --on-event fish_prompt
if command -q uv
    for pair in "uv generate-shell-completion" "uvx --generate-shell-completion"
        set -l cmd (string split ' ' -- $pair)
        set -l completion_file $__fish_config_dir/completions/$cmd[1].fish
        test -f $completion_file; or $cmd fish >$completion_file
    end
end
