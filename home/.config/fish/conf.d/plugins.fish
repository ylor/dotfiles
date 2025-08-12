## Plugins
if test -d "$HOME/.local/bin"
    fish_add_path "$HOME/.local/bin"
end

if test -d '/Applications/1Password.app' #1Password SSH Agent
    set SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
end

# if command -vq atuin
#     atuin init fish | source
# end

if command -vq bat # https://github.com/sharkdp/bat - modern cat
    alias cat="bat"

    if command -vq batman
        batman --export-env | source
        alias man="batman"
    end
end

if command -vq code # https://code.visualstudio.com/ - vscode shorthand
    function c
        # test (count $argv) -eq 0 && code . || code $argv
        test (count $argv) -eq 0 && code . || code $argv
    end
end

if command -vq eza # https://github.com/eza-community/eza - modern ls
    alias ls="eza --long --header --hyperlink --icons"
    alias ll="ls -l"
    alias la="ls -la"
    alias lt='eza --tree --level=2 --long --icons --git'
    alias lta='lt -a'
end

if command -vq fzf # https://github.com/junegunn/fzf - fuzzy finder
    alias fcd="fzf --preview 'bat --style=numbers --color=always {}'"
    alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
    alias formula="brew formulae | fzf --multi --layout reverse-list --preview 'brew info {1}' | xargs -ro brew install"
    alias casks="brew casks | fzf --multi --layout reverse-list --preview 'brew info {1}' | xargs -ro brew install"
end

if command -vq ollama # https://github.com/BurntSushi/ripgrep - modern grep
    set -q llm_model || set llm_model deepseek-r1
    alias ai="ollama run $llm_model"
    alias llm="ollama run $llm_model"
end

if command -vq rg # https://github.com/BurntSushi/ripgrep - modern grep
    alias grep="rg"
end

if command -vq hx # https://helix-editor.com
    if hx --version | grep -q evil # https://github.com/usagi-flow/evil-helix
        alias vi="hx"
        alias vim="hx"
    end
end

if command -vq zed || command -vq zeditor # http://zed.dev - zed shorthand
    function z
        set --local zed (which zed-preview || which zed)
        test (count $argv) -eq 0 && $zed . || $zed $argv
    end
end

if command -vq zoxide # https://github.com/ajeetdsouza/zoxide - smarter cd
    zoxide init fish --cmd j | source
    alias cd="j"
    alias cdi="ji"
end
