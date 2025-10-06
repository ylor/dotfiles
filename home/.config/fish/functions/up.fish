function up
    if command -vq brew
        brew update && brew upgrade
    end

    if command -vq pacman
        sudo pacman -Syu
    end
end
