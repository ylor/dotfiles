if command -vq pacman
function pacman
        set cmd $argv[1]
        set args $argv[2..-1]

        switch $cmd
            case i
                command sudo pacman -Syu --needed --noconfirm $args
            case rm
                command sudo pacman -Rs $args
            case s
                command pacman -Ss $args
            case up
                command sudo pacman -Syu
                detach fish_update_completions
            case '*'
                command pacman $argv
        end
    end
end

if command -vq paru

end