# environment variable for nvidia use
if [[ $(uname) = Linux ]]; then
    export COLOR_PRIMARY=$(cat "$HOME/.config/noctalia/colors.json" | jq -r '.mPrimary' | cut -c2- | sed 's/$/ee/')
    export COLOR_SECONDARY=$(cat "$HOME/.config/noctalia/colors.json" | jq -r '.mOnPrimary' | cut -c2- )
    
    
    if [[ $(lspci | grep -i 'nvidia') ]]; then
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export LIBVA_DRIVER_NAME=nvidia
        export NVD_BACKEND=direct
    fi

    if uwsm check may-start && uwsm select; then
    	exec uwsm start default
    fi

    # if uwsm check may-start; then
    #     exec uwsm start hyprland-uwsm.desktop
    # fi
fi

# drop into fish for interactive shells
# adapted from https://wiki.archlinux.org/title/Fish
if [[ $(command -v fish) && "$(ps -p "$PPID" -o comm=)" != "fish" && -z ${BASH_EXECUTION_STRING} ]]; then
   	exec fish
fi
