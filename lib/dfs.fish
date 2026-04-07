function dfs
    argparse r/reset -- $argv

    if set --query _flag_reset
        set --erase DOTFILES DOTFILES_MODE
    end

    fish (status dirname)/../main.fish
end
