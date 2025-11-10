if command -vq bat # https://github.com/sharkdp/bat - modern cat
    if command -vq batman
        batman --export-env | source
        alias man="batman"
    end
end
