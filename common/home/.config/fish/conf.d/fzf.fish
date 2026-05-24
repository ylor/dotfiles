if command -q fzf # https://github.com/junegunn/fzf
    fzf --fish | source

    set -x FZF_DEFAULT_OPTS "
        --bind change:first
        --border rounded
        --color border:#262626,label:#aeaeae,query:#d9d9d9
        --color fg:-1,fg+:#d0d0d0,bg:-1,bg+:#262626
        --color hl:#5f87af,hl+:#5fd7ff,info:#d0d0d0,marker:#d0d0d0
        --color prompt:#d0d0d0,spinner:#d0d0d0,pointer:#d0d0d0,header:#d0d0d0
        --height ~100%
        --marker '›'
        --pointer '◆'
        --popup center
        --preview-window wrap,border-rounded
        --prompt '→ '
        --scrollbar '│'
        --separator '─'
    "

    set -x FZF_CTRL_R_OPTS "--no-color --height ~20% --with-nth=3.."
end
