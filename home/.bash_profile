if [[ $(uname) == "Linux" ]]; then
    if [[ $(lspci | grep 'NVIDIA') ]]; then
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export LIBVA_DRIVER_NAME=nvidia
        export NVD_BACKEND=direct
    fi

    if [[ -z "$WAYLAND_DISPLAY" ]] && [[ "$(tty)" == "/dev/tty1" ]]; then
        pidof hyprland || start-hyprland #>/dev/null
    fi
fi
