if [[ "$(tty)" == "/dev/tty1" ]]; then
    command -v hyprland && exec start-hyprland
fi
