if [ -d /opt/homebrew ]; then
    eval $(/opt/homebrew/bin/brew shellenv)
    exec fish --login --interactive
fi
