if command -vq ollama # https://github.com/BurntSushi/ripgrep - modern grep
    set -q llm_model || set llm_model deepseek-r1
    alias ai="ollama run $llm_model"
    alias llm="ollama run $llm_model"
end
