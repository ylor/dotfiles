if command -vq fzf # https://github.com/junegunn/fzf - fuzzy finder
    fzf --fish | source

    alias fcd="fzf --preview 'bat --style=numbers --color=always {}'"
    alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
end
