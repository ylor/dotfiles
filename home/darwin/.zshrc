if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

parent=$(ps -o comm= -p $PPID)
if (( $+commands[fish] )) && [[ $parent != *fish* && $SHLVL -le 2 ]]; then
  [[ -o login ]] && exec fish --login || exec fish
fi

if [[ -x ~/.local/bin/mise ]]; then
  eval "$(~/.local/bin/mise activate zsh)"
fi
