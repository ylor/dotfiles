if command -q eza # https://github.com/eza-community/eza - modern ls
    # Shared base flags for consistency
    set -l _eza_flags --header --hyperlink --icons

    alias ls="eza $_eza_flags"
    alias ll="eza --long $_eza_flags"
    alias la="eza --almost-all --long $_eza_flags"
    alias lt="eza --tree $_eza_flags"
    alias lta="eza --almost-all --tree $_eza_flags"
end
