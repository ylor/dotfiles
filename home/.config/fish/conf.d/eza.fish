if command -vq eza # https://github.com/eza-community/eza - modern ls
    alias ls="eza --header --hyperlink --icons"
    alias la="eza --almost-all --long --header --hyperlink --icons"
    alias ll="eza --long --header --hyperlink --icons"
    alias lt='eza --almost-all --tree --hyperlink --icons'
end
