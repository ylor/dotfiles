function noctalia-export
    set config $DOTFILES/platforms/linux/distros/cachyos/home/.config/noctalia/config.toml
    noctalia config export >$config
    # sed -i '/^\[shell\]$/a font_family = "TX-02-Variable"' $config
end
