if command -q tv
    tv init fish | source
    alias tv="tv --preview-word-wrap"
else
    bind -M insert \cr history-pager
end
