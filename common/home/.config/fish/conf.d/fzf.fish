if command -q fzf # https://github.com/junegunn/fzf - fuzzy finder
    set -x FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS
      --color=fg:-1,fg+:#d0d0d0,bg:-1,bg+:#262626
      --color=hl:#5f87af,hl+:#5fd7ff,info:#d0d0d0,marker:#d0d0d0
      --color=prompt:#d0d0d0,spinner:#d0d0d0,pointer:#d0d0d0,header:#d0d0d0
      --color=border:#262626,label:#aeaeae,query:#d9d9d9
      --border=\"rounded\" --border-label=\"\" --preview-window=\"border-rounded\" --prompt=\"→ \"
      --marker=\"›\" --pointer=\"◆\" --separator=\"─\" --scrollbar=\"│\""
#     fzf --fish | source

#     alias fcd="fzf --preview 'bat --style=numbers --color=always {}'"
#     alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
end
