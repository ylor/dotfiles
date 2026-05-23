function _dx_alias --on-event fish_prompt
    if mise which deno &>/dev/null
        function dx --wraps='deno x'
            deno x $argv
        end
    else
        functions --erase dx
    end
end
