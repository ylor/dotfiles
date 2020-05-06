#export EDITOR='vi'
#export VISUAL 'vi'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Colorful ls
export CLICOLOR=1

if command -v starship > /dev/null; then
    eval "$(starship init zsh)"
fi

