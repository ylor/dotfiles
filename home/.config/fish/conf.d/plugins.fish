## Plugins
if test -d "$HOME/.local/bin"
    fish_add_path "$HOME/.local/bin"
end

if test -d '/Applications/1Password.app' #1Password SSH Agent
    set SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
end

if command -q bat # https://github.com/sharkdp/bat - modern cat
    alias cat="bat --pager=never"
end

if command -q code # https://code.visualstudio.com/ - vscode shorthand
    function c
        # test (count $argv) -eq 0 && code . || code $argv
        test (count $argv) -eq 0 && code . || code $argv
    end
end

if command -q eza # https://github.com/eza-community/eza - modern ls
    alias ls="eza --hyperlink --icons"
    alias ll="ls -l"
    alias la="ls -la"
end

# if command -q fzf # https://github.com/junegunn/fzf - fuzzy finder
#     if command -q fd
#         alias cdi="cd (fd $PWD --type d | fzf)"
#     else
#         alias cdi="cd (find $PWD -type d | fzf)"
#     end
# end

if command -q ollama # https://github.com/BurntSushi/ripgrep - modern grep
    alias llm="ollama run gemma3:4b-it-qat"
end

if command -q rg # https://github.com/BurntSushi/ripgrep - modern grep
    alias grep="rg"
end

if command -q zed; or command -q zed-preview # http://zed.dev - zed shorthand
    function z
        set --local zed (which zed-preview || which zed)
        test (count $argv) -eq 0 && $zed . || $zed $argv
    end
end

if command -q zoxide # https://github.com/ajeetdsouza/zoxide - smarter cd
    zoxide init fish --cmd j | source
    # alias cd="j"
    # alias cdi="ji"
end
