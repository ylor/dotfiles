function fish_user_key_bindings
    # Use emacs bindings in insert mode, using vi bindings if there's a conflict.
    fish_default_key_bindings -M insert
    fish_vi_key_bindings --no-erase insert
    _autopair_fish_key_bindings

    # Make sure ctrl-n still works in insert mode.
    bind -M insert ctrl-n down-or-search

    # Keep ctrl-t available for Ghostty tabs.
    bind -e ctrl-t
    bind -e -M insert ctrl-t
    bind alt-t fzf-file-widget
    bind -M insert alt-t fzf-file-widget

    # Copy/paste.
    bind yy fish_clipboard_copy
    bind p fish_clipboard_paste
end
