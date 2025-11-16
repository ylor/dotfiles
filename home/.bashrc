# environment variable for nvidia use
if [[ $(lspci | grep -i 'nvidia') ]]; then
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export LIBVA_DRIVER_NAME=nvidia
    export NVD_BACKEND=direct
fi

# drop into fish for interactive shells
# adapted from https://wiki.archlinux.org/title/Fish
if [[ $(command -v fish) && "$(ps -p "$PPID" -o comm=)" != "fish" && -z ${BASH_EXECUTION_STRING} ]]; then
   	exec fish
fi
