# Disabled for now: font install step.
# switch (uname -s)
#     case Darwin
#         set font_directory $HOME/Library/Fonts
#     case Linux
#         set font_directory $HOME/.local/share/fonts
#     case '*'
#         dfs-failure "Font installation unsupported on "(uname -s)
#         return 1
# end

# mkdir -p $font_directory; or return

# set fonts_added false
# for font in $DOTFILES/home/base/.local/assets/*.age
#     set filename (path basename $font | string sub --end -4 | base64 -d)
#     set destination $font_directory/$filename
#     test -f $destination; and continue

#     age -d -o $destination $font; or return
#     set fonts_added true
# end

# if test (uname -s) = Linux; and $fonts_added; and command -vq fc-cache
#     fc-cache -f $font_directory; or return
# end

# dfs-success "Fonts"
