if command -vq hx # https://helix-editor.com
    if hx --version | grep -q evil # https://github.com/usagi-flow/evil-helix
        alias vi="hx"
        alias vim="hx"
    end
end
