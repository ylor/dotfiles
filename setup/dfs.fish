function dfs --description "Configure the system and manage linked files"
    argparse h/help -- $argv; or return 2
    set -l operation "$argv"
    set -q _flag_help; and set operation help

    set -Ux DOTFILES (path resolve (status dirname)/..)
    set --prepend fish_function_path "$DOTFILES/setup"

    switch "$operation"
        case ''
            dfs-apply
            exec fish
        case apply reset
            dfs-$operation
            exec fish
        case layers
          dfs-$operation
        case link
            dfs-link
        case '*'
            dfs-help
    end
end
