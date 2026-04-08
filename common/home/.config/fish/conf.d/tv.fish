if command -vq tv
    tv init fish | source
else
    bind -M insert \cr history-pager
end
