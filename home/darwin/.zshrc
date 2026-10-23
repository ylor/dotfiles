if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [[ -x ~/.local/bin/mise ]]; then
  eval "$(~/.local/bin/mise activate zsh)"
fi
