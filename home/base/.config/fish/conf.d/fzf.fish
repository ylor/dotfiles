if command -q fzf # https://github.com/junegunn/fzf
    fzf --fish | source

    bind super-shift-g fzf-cd-widget
    bind -M insert super-shift-g fzf-cd-widget
    bind super-shift-f fzf-file-widget
    bind -M insert super-shift-f fzf-file-widget

    set -x FZF_DEFAULT_OPTS "--bind change:first \
        --border sharp \
        --marker '›' \
        --no-color \
        --pointer '◆' \
        --popup \
        --preview-window wrap \
        --preview-window="border-sharp"
        --prompt '→ '"

    set -x FZF_CTRL_R_OPTS "--no-color --height ~50% --with-nth=3.."

    if command -q bat
        set -x FZF_CTRL_T_OPTS "--preview 'bat {}'"
    end

    if command -q eza
        set -x FZF_ALT_C_OPTS "--preview 'eza --icons=auto --tree --level 2 {}'"
    else
        set -x FZF_ALT_C_OPTS "--preview 'ls -1 {}'"
    end

    if command -q fd
        set -x FZF_DEFAULT_COMMAND "fd --type file --hidden --follow --exclude .git"
        set -x FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
    end
end
