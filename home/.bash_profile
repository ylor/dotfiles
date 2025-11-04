# drop into fish for interactive shells in Linux
# yoinked from https://wiki.archlinux.org/title/Fish
if [[ $(uname) = Linux ]]; then
	if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ${BASH_EXECUTION_STRING} && ${SHLVL} == 1 && shopt -q login_shell ]];then
    	# shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
    	exec fish --login
    fi
fi
