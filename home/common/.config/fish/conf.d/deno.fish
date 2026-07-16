function _dx_alias --on-event fish_prompt
    if command -q deno
        function dx --wraps='deno x'
            deno x $argv
        end
    else
        functions --erase dx
    end
end
