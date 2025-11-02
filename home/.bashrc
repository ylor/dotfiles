# if [[ -d /opt/homebrew ]]; then
#     eval $(/opt/homebrew/bin/brew shellenv)
#     export HOMEBREW_NO_AUTO_UPDATE=1
#     export HOMEBREW_NO_ANALYTICS=1
#     export HOMEBREW_NO_ENV_HINTS=1
# fi

export PATH="$HOME/.local/bin:$PATH"

if [[ $(uname) = Linux ]]; then
	if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ${BASH_EXECUTION_STRING} && ${SHLVL} == 1 ]];then
    	shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
    	exec fish $LOGIN_OPTION
    fi
fi

# if [[ $(uname ) = Darwin ]]; then
# # drop into fish for interactive shells
# # adapted from https://wiki.archlinux.org/title/Fish
#     if [[ $(command -v fish) && $(ps -p "$PPID" -o comm=) != "fish" && -z ${BASH_EXECUTION_STRING} && ${SHLVL} == 1 && $(shopt -q login_shell) ]]; then
#     	exec fish --login
#     fi
# fi
