function fish_mode_prompt
	# Overriden by Spacefish fishshell theme
	# To see vi mode in prompt add 'vi_mode' to SPACEFISH_PROMPT_ORDER
end
function fish_prompt
	# Store the exit code of the last command
	set -g sf_exit_code $status
	set -g SPACEFISH_VERSION 1.10.4

	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_PROMPT_ADD_NEWLINE true
	__sf_util_set_default SPACEFISH_PROMPT_FIRST_PREFIX_SHOW false
	__sf_util_set_default SPACEFISH_PROMPT_PREFIXES_SHOW true
	__sf_util_set_default SPACEFISH_PROMPT_SUFFIXES_SHOW true
	__sf_util_set_default SPACEFISH_PROMPT_DEFAULT_PREFIX "via "
	__sf_util_set_default SPACEFISH_PROMPT_DEFAULT_SUFFIX " "
	__sf_util_set_default SPACEFISH_PROMPT_ORDER time user dir host git package node ruby golang php rust haskell julia docker aws conda pyenv kubecontext exec_time line_sep battery vi_mode jobs exit_code char

	# ------------------------------------------------------------------------------
	# Sections
	# ------------------------------------------------------------------------------

	# Keep track of whether the prompt has already been opened
	set -g sf_prompt_opened $SPACEFISH_PROMPT_FIRST_PREFIX_SHOW

	if test "$SPACEFISH_PROMPT_ADD_NEWLINE" = "true"
		echo
	end

	for i in $SPACEFISH_PROMPT_ORDER
		eval __sf_section_$i
	end
	set_color normal
end
function fish_right_prompt

	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_RPROMPT_ORDER ""

	# ------------------------------------------------------------------------------
	# Sections
	# ------------------------------------------------------------------------------

	[ -n "$SPACEFISH_RPROMPT_ORDER" ]; or return

	for i in $SPACEFISH_RPROMPT_ORDER
		eval __sf_section_$i
	end
	set_color normal
end
function __sf_lib_section -a color prefix content suffix
	# If there are only 2 args, they're content and prefix
	if test (count $argv) -eq 2
		set content $argv[2]
		set prefix
	end

	if test "$sf_prompt_opened" = "true" -a "$SPACEFISH_PROMPT_PREFIXES_SHOW" = "true"
		# Echo prefixes in bold white
		set_color --bold fff
		echo -e -n -s $prefix
		set_color normal
	end

	# Set the prompt as having been opened
	set -g sf_prompt_opened true

	set_color --bold $color
	echo -e -n $content
	set_color normal

	if test "$SPACEFISH_PROMPT_SUFFIXES_SHOW" = "true"
		# Echo suffixes in bold white
		set_color --bold fff
		echo -e -n -s $suffix
		set_color normal
	end
end
#
# Amazon Web Services (AWS)
#
# The AWS Command Line Interface (CLI) is a unified tool to manage AWS services.
# Link: https://aws.amazon.com/cli/

function __sf_section_aws -d "Display the selected aws profile"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_AWS_SHOW true
	__sf_util_set_default SPACEFISH_AWS_PREFIX "using "
	__sf_util_set_default SPACEFISH_AWS_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	__sf_util_set_default SPACEFISH_AWS_SYMBOL "☁️ "
	__sf_util_set_default SPACEFISH_AWS_COLOR ff8700

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	# Show the selected AWS-cli profile
	[ $SPACEFISH_AWS_SHOW = false ]; and return

	# Ensure the aws command is available
	type -q aws; or return

	# Early return if there's no AWS_PROFILE, or it's set to default
	if test -z "$AWS_PROFILE" \
		-o "$AWS_PROFILE" = "default"
		return
	end

	__sf_lib_section \
		$SPACEFISH_AWS_COLOR \
		$SPACEFISH_AWS_PREFIX \
		"$SPACEFISH_AWS_SYMBOL""$AWS_PROFILE" \
		$SPACEFISH_AWS_SUFFIX
end
#
# Battery
#

function __sf_section_battery -d "Displays battery symbol and charge"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	# ------------------------------------------------------------------------------
	# | SPACEFISH_BATTERY_SHOW | below threshold | above threshold | fully charged |
	# |------------------------+-----------------+-----------------+---------------|
	# | false                  | hidden          | hidden          | hidden        |
	# | always                 | shown           | shown           | shown         |
	# | true                   | shown           | hidden          | hidden        |
	# | charged                | shown           | hidden          | shown         |
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_BATTERY_SHOW true
	__sf_util_set_default SPACEFISH_BATTERY_PREFIX ""
	__sf_util_set_default SPACEFISH_BATTERY_SUFFIX " "
	__sf_util_set_default SPACEFISH_BATTERY_SYMBOL_CHARGING ⇡
	__sf_util_set_default SPACEFISH_BATTERY_SYMBOL_DISCHARGING ⇣
	__sf_util_set_default SPACEFISH_BATTERY_SYMBOL_FULL •
	__sf_util_set_default SPACEFISH_BATTERY_THRESHOLD 10

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	# Show section only if any of the following is true
	# - SPACEFISH_BATTERY_SHOW = "always"
	# - SPACEFISH_BATTERY_SHOW = "true" and
	#	- battery percentage is below the given limit (default: 10%)
	# - SPACEFISH_BATTERY_SHOW = "charged" and
	#	- Battery is fully charged

	# Check that user wants to show battery levels
	[ $SPACEFISH_BATTERY_SHOW = false ]; and return

	set -l battery_data
	set -l battery_percent
	set -l battery_status
	set -l battery_color
	set -l battery_symbol

	# Darwin and macOS machines
	if type -q pmset
		set battery_data (pmset -g batt | grep "InternalBattery")

		# Return if no internal battery
		if test -z (echo $battery_data)
			return
		end

		set battery_percent (echo $battery_data | grep -oE "[0-9]{1,3}%")
		# spaceship has echo $battery_data | awk -F '; *' 'NR==2 { print $2 }', but NR==2 did not return anything.
		set battery_status (echo $battery_data | awk -F '; *' '{ print $2 }')

	# Linux machines
	else if type -q upower
		set -l battery (upower -e | grep battery | head -1)

		[ -z $battery ]; and return

		set -l IFS # Clear IFS to allow for multi-line variables
		set battery_data (upower -i $battery)
		set battery_percent (echo $battery_data | grep percentage | awk '{print $2}')
		set battery_status (echo $battery_data | grep state | awk '{print $2}')
	# Windows machines.
	else if type -q acpi
		set -l battery_data (acpi -b ^ /dev/null) # Redirect stderr to /dev/null fixes issue #110.

		# Return if no battery
		[ -z $battery_data ]; and return

		set battery_percent ( echo $battery_data | awk '{print $4}' )
		set battery_status ( echo $battery_data | awk '{print tolower($3)}' )
	else
		return
	end

	 # Remove trailing % and symbols for comparison
	set battery_percent (echo $battery_percent | string trim --chars=%[,;])

	if test "$battery_percent" -eq 100 -o -n (echo (string match -r "(charged|full)" $battery_status))
		set battery_color green
	else if test "$battery_percent" -lt "$SPACEFISH_BATTERY_THRESHOLD"
		set battery_color red
	else
		set battery_color yellow
	end

	# Battery indicator based on current status of battery
	if test "$battery_status" = "charging"
		set battery_symbol $SPACEFISH_BATTERY_SYMBOL_CHARGING
	else if test -n (echo (string match -r "^[dD]ischarg.*" $battery_status))
		set battery_symbol $SPACEFISH_BATTERY_SYMBOL_DISCHARGING
	else
		set battery_symbol $SPACEFISH_BATTERY_SYMBOL_FULL
	end

	if test "$SPACEFISH_BATTERY_SHOW" = "always" \
	-o "$battery_percent" -lt "$SPACEFISH_BATTERY_THRESHOLD" \
	-o "$SPACEFISH_BATTERY_SHOW" = "charged" \
	-a -n (echo (string match -r "(charged|full)" $battery_status))
		__sf_lib_section \
			$battery_color \
			$SPACEFISH_BATTERY_PREFIX \
			"$battery_symbol$battery_percent%" \
			$SPACEFISH_BATTERY_SUFFIX
	end
end
#
# Prompt character
#

function __sf_section_char -d "Display the prompt character"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_CHAR_PREFIX ""
	__sf_util_set_default SPACEFISH_CHAR_SUFFIX " "
	__sf_util_set_default SPACEFISH_CHAR_SYMBOL ➜
	__sf_util_set_default SPACEFISH_CHAR_COLOR_SUCCESS green
	__sf_util_set_default SPACEFISH_CHAR_COLOR_FAILURE red

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	# Color $SPACEFISH_CHAR_SYMBOL red if previous command failed and
	# color it in green if the command succeeded.
	set -l color

	if test $sf_exit_code -eq 0
		set color $SPACEFISH_CHAR_COLOR_SUCCESS
	else
		set color $SPACEFISH_CHAR_COLOR_FAILURE
	end

	__sf_lib_section \
		$color \
		$SPACEFISH_CHAR_PREFIX \
		$SPACEFISH_CHAR_SYMBOL \
		$SPACEFISH_CHAR_SUFFIX
end
#
# Conda
#
# Current Conda version.

function __sf_section_conda -d "Display current Conda version"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_CONDA_SHOW true
	__sf_util_set_default SPACEFISH_CONDA_PREFIX $SPACEFISH_PROMPT_DEFAULT_PREFIX
	__sf_util_set_default SPACEFISH_CONDA_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	__sf_util_set_default SPACEFISH_CONDA_SYMBOL "🅒 "
	__sf_util_set_default SPACEFISH_CONDA_COLOR blue

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	[ $SPACEFISH_CONDA_SHOW = false ]; and return

	# Show Conda version only if conda is installed and CONDA_DEFAULT_ENV is set
	if not type -q conda; \
		or test -z "$CONDA_DEFAULT_ENV";
		return
	end

	set -l conda_version (conda -V | string split ' ')[2]

	__sf_lib_section \
		$SPACEFISH_CONDA_COLOR \
		$SPACEFISH_CONDA_PREFIX \
		"$SPACEFISH_CONDA_SYMBOL"v"$conda_version" \
		$SPACEFISH_CONDA_SUFFIX
end
#
# Working directory
#

function __sf_section_dir -d "Display the current truncated directory"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_DIR_SHOW true
	__sf_util_set_default SPACEFISH_DIR_PREFIX "in "
	__sf_util_set_default SPACEFISH_DIR_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	__sf_util_set_default SPACEFISH_DIR_TRUNC 3
	__sf_util_set_default SPACEFISH_DIR_TRUNC_REPO true
	__sf_util_set_default SPACEFISH_DIR_COLOR cyan

	# Write Permissions lock symbol
	__sf_util_set_default SPACEFISH_DIR_LOCK_SHOW true
	__sf_util_set_default SPACEFISH_DIR_LOCK_SYMBOL ""
	__sf_util_set_default SPACEFISH_DIR_LOCK_COLOR red

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	[ $SPACEFISH_DIR_SHOW = false ]; and return

	set -l dir
	set -l tmp
	set -l git_root (command git rev-parse --show-toplevel ^/dev/null)

	if test "$SPACEFISH_DIR_TRUNC_REPO" = "true" -a "$git_root"
		# Treat repo root as top level directory
		set tmp (string replace $git_root (basename $git_root) $PWD)
	else
	set -l realhome ~
		set tmp (string replace -r '^'"$realhome"'($|/)' '~$1' $PWD)
	end

	# Truncate the path to have a limited number of dirs
	set dir (__sf_util_truncate_dir $tmp $SPACEFISH_DIR_TRUNC)

	if [ $SPACEFISH_DIR_LOCK_SHOW = true -a ! -w . ]
		set DIR_LOCK_SYMBOL (set_color $SPACEFISH_DIR_LOCK_COLOR)" $SPACEFISH_DIR_LOCK_SYMBOL"(set_color --bold fff)
	end

	__sf_lib_section \
		$SPACEFISH_DIR_COLOR \
		$SPACEFISH_DIR_PREFIX \
		$dir \
		"$DIR_LOCK_SYMBOL""$SPACEFISH_DIR_SUFFIX"
end
#
# Docker
#
# Current Docker version and Machine name.

function __sf_section_docker -d "Display docker version and machine name"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_DOCKER_SHOW true
	__sf_util_set_default SPACEFISH_DOCKER_PREFIX "is "
	__sf_util_set_default SPACEFISH_DOCKER_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	__sf_util_set_default SPACEFISH_DOCKER_SYMBOL "🐳 "
	__sf_util_set_default SPACEFISH_DOCKER_COLOR cyan
	__sf_util_set_default SPACEFISH_DOCKER_VERBOSE_VERSION false

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	[ $SPACEFISH_DOCKER_SHOW = false ]; and return

	# Show Docker version only if docker is installed
	type -q docker; or return

	# Show docker version only when pwd has dockerfile or docker-compose.yml or COMPOSE_FILE
if not test -f Dockerfile \
	-o -f docker-compose.yml \
	-o -f "$COMPOSE_FILE"
	return
end

	set -l docker_version (docker version -f "{{.Server.Version}}" ^/dev/null)
	# if docker daemon isn't running you'll get an error like 'Bad response from Docker engine'
	[ -z $docker_version ]; and return

	if test "$SPACEFISH_DOCKER_VERBOSE_VERSION" = "false"
			set docker_version (string split - $docker_version)[1]
	end

	if test -n "$DOCKER_MACHINE_NAME"
			set docker_version $docker_version via $DOCKER_MACHINE_NAME
	end

	__sf_lib_section \
	$SPACEFISH_DOCKER_COLOR \
	$SPACEFISH_DOCKER_PREFIX \
	"$SPACEFISH_DOCKER_SYMBOL"v"$docker_version" \
	$SPACEFISH_DOCKER_SUFFIX
end
#
# Execution time
#

function __sf_section_exec_time -d "Display the execution time of the last command"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_EXEC_TIME_SHOW true
	__sf_util_set_default SPACEFISH_EXEC_TIME_PREFIX "took "
	__sf_util_set_default SPACEFISH_EXEC_TIME_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	__sf_util_set_default SPACEFISH_EXEC_TIME_COLOR yellow
	__sf_util_set_default SPACEFISH_EXEC_TIME_ELAPSED 5

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	[ $SPACEFISH_EXEC_TIME_SHOW = false ]; and return

	# Allow for compatibility between fish 2.7 and 3.0
	set -l command_duration "$CMD_DURATION$cmd_duration"

	if test -n "$command_duration" -a "$command_duration" -gt (math "$SPACEFISH_EXEC_TIME_ELAPSED * 1000")
		set -l human_command_duration (echo $command_duration | __sf_util_human_time)
		__sf_lib_section \
			$SPACEFISH_EXEC_TIME_COLOR \
			$SPACEFISH_EXEC_TIME_PREFIX \
			$human_command_duration \
			$SPACEFISH_EXEC_TIME_SUFFIX
	end
end
# Exit-code
#

function __sf_section_exit_code -d "Shows the exit code from the previous command."
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_EXIT_CODE_SHOW false
	__sf_util_set_default SPACEFISH_EXIT_CODE_PREFIX ""
	__sf_util_set_default SPACEFISH_EXIT_CODE_SUFFIX " "
	__sf_util_set_default SPACEFISH_EXIT_CODE_SYMBOL ✘
	__sf_util_set_default SPACEFISH_EXIT_CODE_COLOR red

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	[ $SPACEFISH_EXIT_CODE_SHOW = false ]; or test $sf_exit_code -eq 0; and return

	__sf_lib_section \
		$SPACEFISH_EXIT_CODE_COLOR \
		$SPACEFISH_EXIT_CODE_PREFIX \
		"$SPACEFISH_EXIT_CODE_SYMBOL$sf_exit_code" \
		$SPACEFISH_EXIT_CODE_SUFFIX
end
#
# Git
#

function __sf_section_git -d "Display the git branch and status"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_GIT_SHOW true
	__sf_util_set_default SPACEFISH_GIT_PREFIX "on "
	__sf_util_set_default SPACEFISH_GIT_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	__sf_util_set_default SPACEFISH_GIT_SYMBOL " "

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	# Show both git branch and git status:
	#   spacefish_git_branch
	#   spacefish_git_status

	[ $SPACEFISH_GIT_SHOW = false ]; and return

	set -l git_branch (__sf_section_git_branch)
	set -l git_status (__sf_section_git_status)

	[ -z $git_branch ]; and return

	__sf_lib_section \
		fff \
		$SPACEFISH_GIT_PREFIX \
		"$git_branch$git_status" \
		$SPACEFISH_GIT_SUFFIX
end
#
# Git branch
#

function __sf_section_git_branch -d "Format the displayed branch name"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_GIT_BRANCH_SHOW true
	__sf_util_set_default SPACEFISH_GIT_BRANCH_PREFIX $SPACEFISH_GIT_SYMBOL
	__sf_util_set_default SPACEFISH_GIT_BRANCH_SUFFIX ""
	__sf_util_set_default SPACEFISH_GIT_BRANCH_COLOR magenta

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	[ $SPACEFISH_GIT_BRANCH_SHOW = false ]; and return

	set -l git_branch (__sf_util_git_branch)

	[ -z $git_branch ]; and return

	__sf_lib_section \
		$SPACEFISH_GIT_BRANCH_COLOR \
		$SPACEFISH_GIT_BRANCH_PREFIX$git_branch$SPACEFISH_GIT_BRANCH_SUFFIX
end
#
# Git status
#

function __sf_section_git_status -d "Display the current git status"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_GIT_STATUS_SHOW true
	__sf_util_set_default SPACEFISH_GIT_STATUS_PREFIX " ["
	__sf_util_set_default SPACEFISH_GIT_STATUS_SUFFIX ]
	__sf_util_set_default SPACEFISH_GIT_STATUS_COLOR red
	__sf_util_set_default SPACEFISH_GIT_STATUS_UNTRACKED \?
	__sf_util_set_default SPACEFISH_GIT_STATUS_ADDED +
	__sf_util_set_default SPACEFISH_GIT_STATUS_MODIFIED !
	__sf_util_set_default SPACEFISH_GIT_STATUS_RENAMED »
	__sf_util_set_default SPACEFISH_GIT_STATUS_DELETED ✘
	__sf_util_set_default SPACEFISH_GIT_STATUS_STASHED \$
	__sf_util_set_default SPACEFISH_GIT_STATUS_UNMERGED =
	__sf_util_set_default SPACEFISH_GIT_STATUS_AHEAD ⇡
	__sf_util_set_default SPACEFISH_GIT_STATUS_BEHIND ⇣
	__sf_util_set_default SPACEFISH_GIT_STATUS_DIVERGED ⇕
	__sf_util_set_default SPACEFISH_GIT_PROMPT_ORDER untracked added modified renamed deleted stashed unmerged diverged ahead behind

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	set -l git_status
	set -l is_ahead
	set -l is_behind

	set -l index (command git status --porcelain ^/dev/null -b)
	set -l trimmed_index (string split \n $index | string sub --start 1 --length 2)

	for i in $trimmed_index
		if test (string match '\?\?' $i)
			set git_status untracked $git_status
		end
		if test (string match '*A*' $i)
			set git_status added $git_status
		end
		if test (string match '*M*' $i)
			set git_status modified $git_status
		end
		if test (string match '*R*' $i)
			set git_status renamed $git_status
		end
		if test (string match '*D*' $i)
			set git_status deleted $git_status
		end
		if test (string match '*U*' $i)
			set git_status deleted $git_status
		end
	end

	# Check for stashes
	if test -n (echo (command git rev-parse --verify refs/stash ^/dev/null))
		set git_status stashed $git_status
	end

	# Check whether the branch is ahead
	if test (string match '*ahead*' $index)
		set is_ahead true
	end

	# Check whether the branch is behind
	if test (string match '*behind*' $index)
		set is_behind true
	end

	# Check whether the branch has diverged
	if test "$is_ahead" = "true" -a "$is_behind" = "true"
		set git_status diverged $git_status
	else if test "$is_ahead" = "true"
		set git_status ahead $git_status
	else if test "$is_behind" = "true"
		set git_status behind $git_status
	end

	set -l full_git_status
	for i in $SPACEFISH_GIT_PROMPT_ORDER
		set i (string upper $i)
		set git_status (string upper $git_status)
		if contains $i in $git_status
			set -l status_symbol SPACEFISH_GIT_STATUS_$i
			set full_git_status "$$status_symbol$full_git_status"
		end
	end

	# Check if git status
	if test -n "$full_git_status"
		__sf_lib_section \
			$SPACEFISH_GIT_STATUS_COLOR \
			"$SPACEFISH_GIT_STATUS_PREFIX$full_git_status$SPACEFISH_GIT_STATUS_SUFFIX"
	end
end
#
# Go
#
# Go is an open source programming language that makes it easy
# to build efficient software.
# Link: https://golang.org/

function __sf_section_golang -d "Display the current go version if you're inside GOPATH"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_GOLANG_SHOW true
	__sf_util_set_default SPACEFISH_GOLANG_PREFIX $SPACEFISH_PROMPT_DEFAULT_PREFIX
	__sf_util_set_default SPACEFISH_GOLANG_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	__sf_util_set_default SPACEFISH_GOLANG_SYMBOL "🐹 "
	__sf_util_set_default SPACEFISH_GOLANG_COLOR cyan

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	# Show the current version of Golang
	[ $SPACEFISH_GOLANG_SHOW = false ]; and return

	# Ensure the go command is available
	type -q go; or return

	if not test -f go.mod \
		-o -d Godeps \
		-o -f glide.yaml \
		-o (count *.go) -gt 0 \
		-o -f Gopkg.yml \
		-o -f Gopkg.lock \
		-o ([ -n $GOPATH ]; and string match $GOPATH $PWD)
		return
	end

	set -l go_version (go version | awk '{ print substr($3, 3) }')

	__sf_lib_section \
		$SPACEFISH_GOLANG_COLOR \
		$SPACEFISH_GOLANG_PREFIX \
		"$SPACEFISH_GOLANG_SYMBOL"v"$go_version" \
		$SPACEFISH_GOLANG_SUFFIX
end
#
# Haskell Stack
#
# An advanced, purely functional programming language.
# Link: https://www.haskell.org/

function __sf_section_haskell -d "Show current version of Haskell Tool Stack"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_HASKELL_SHOW true
	__sf_util_set_default SPACEFISH_HASKELL_PREFIX $SPACEFISH_PROMPT_DEFAULT_PREFIX
	__sf_util_set_default SPACEFISH_HASKELL_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	__sf_util_set_default SPACEFISH_HASKELL_SYMBOL "λ "
	__sf_util_set_default SPACEFISH_HASKELL_COLOR red

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	# Show current version of Haskell Tool Stack.
	[ $SPACEFISH_HASKELL_SHOW = false ]; and return

	# Ensure the stack command is available
	type -q stack; or return

	# If there are stack files in current directory
	[ -f ./stack.yaml ]; or return

	set -l haskell_version (stack ghc -- --numeric-version --no-install-ghc)

	__sf_lib_section \
		$SPACEFISH_HASKELL_COLOR \
		$SPACEFISH_HASKELL_PREFIX \
		"$SPACEFISH_HASKELL_SYMBOL"v"$haskell_version" \
		$SPACEFISH_HASKELL_SUFFIX
end
#
# Hostname
#


# If there is an ssh connections, current machine name.
function __sf_section_host -d "Display the current hostname if connected over SSH"

	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_HOST_SHOW true
	__sf_util_set_default SPACEFISH_HOST_PREFIX "at "
	__sf_util_set_default SPACEFISH_HOST_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	__sf_util_set_default SPACEFISH_HOST_COLOR blue
	__sf_util_set_default SPACEFISH_HOST_COLOR_SSH green

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	[ "$SPACEFISH_HOST_SHOW" = false ]; and return

	if test "$SPACEFISH_HOST_SHOW" = "always"; or set -q SSH_CONNECTION;

		# Determination of what color should be used
		set -l host_color
		if set -q SSH_CONNECTION;
			set host_color $SPACEFISH_HOST_COLOR_SSH
		else
			set host_color $SPACEFISH_HOST_COLOR
		end

		__sf_lib_section \
			$host_color \
			$SPACEFISH_HOST_PREFIX \
			(hostname) \
			$SPACEFISH_HOST_SUFFIX
		end
end
# Jobs
#

function __sf_section_jobs -d "Show icon, if there's a working jobs in the background."
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_JOBS_SHOW true
	__sf_util_set_default SPACEFISH_JOBS_PREFIX ""
	__sf_util_set_default SPACEFISH_JOBS_SUFFIX " "
	__sf_util_set_default SPACEFISH_JOBS_SYMBOL ✦
	__sf_util_set_default SPACEFISH_JOBS_COLOR blue
	__sf_util_set_default SPACEFISH_JOBS_AMOUNT_PREFIX ""
	__sf_util_set_default SPACEFISH_JOBS_AMOUNT_SUFFIX ""
	__sf_util_set_default SPACEFISH_JOBS_AMOUNT_THRESHOLD 1

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	[ $SPACEFISH_JOBS_SHOW = false ]; and return

	set jobs_amount (jobs | wc -l | xargs) # Zsh had a much more complicated command.

	if test $jobs_amount -eq 0
		return
	end

	if test $jobs_amount -le $SPACEFISH_JOBS_AMOUNT_THRESHOLD
		set jobs_amount ''
		set SPACEFISH_JOBS_AMOUNT_PREFIX ''
		set SPACEFISH_JOBS_AMOUNT_SUFFIX ''
	end

	set SPACEFISH_JOBS_SECTION "$SPACEFISH_JOBS_SYMBOL$SPACEFISH_JOBS_AMOUNT_PREFIX$jobs_amount$SPACEFISH_JOBS_AMOUNT_SUFFIX"

	__sf_lib_section \
		$SPACEFISH_JOBS_COLOR \
		$SPACEFISH_JOBS_PREFIX \
		$SPACEFISH_JOBS_SECTION \
		$SPACEFISH_JOBS_SUFFIX
end
#
# Julia
#
# Current Julia version.

function __sf_section_julia -d "Display julia version"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_JULIA_SHOW true
	__sf_util_set_default SPACEFISH_JULIA_PREFIX "is "
	__sf_util_set_default SPACEFISH_JULIA_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	__sf_util_set_default SPACEFISH_JULIA_SYMBOL "ஃ "
	__sf_util_set_default SPACEFISH_JULIA_COLOR green

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	[ $SPACEFISH_JULIA_SHOW = false ]; and return

	# Show Julia version only if julia is installed
	type -q julia; or return

	# Show julia version only when pwd has *.jl file(s)
	[ (count *.jl) -gt 0 ]; or return

	set -l julia_version (julia --version | grep --color=never -oE '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]')

	__sf_lib_section \
	$SPACEFISH_JULIA_COLOR \
	$SPACEFISH_JULIA_PREFIX \
	"$SPACEFISH_JULIA_SYMBOL"v"$julia_version" \
	$SPACEFISH_JULIA_SUFFIX
end
#
#  Kubernetes (kubectl)
#
# Kubernetes is an open-source system for deployment, scaling,
# and management of containerized applications.
# Link: https://kubernetes.io/

function __sf_section_kubecontext -d "Display the kubernetes context"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_KUBECONTEXT_SHOW true
	__sf_util_set_default SPACEFISH_KUBECONTEXT_PREFIX "at "
	__sf_util_set_default SPACEFISH_KUBECONTEXT_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	# Additional space is added because ☸️ is wider than other symbols
	# See: https://github.com/denysdovhan/spaceship-prompt/pull/432
	__sf_util_set_default SPACEFISH_KUBECONTEXT_SYMBOL "☸️  "
	__sf_util_set_default SPACEFISH_KUBECONTEXT_COLOR cyan

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	# Show current kubecontext
	[ $SPACEFISH_KUBECONTEXT_SHOW = false ]; and return

	# Ensure the kubectl command is available
	type -q kubectl; or return

	set -l kube_context (kubectl config current-context ^/dev/null)
	[ -z $kube_context ]; and return

	__sf_lib_section \
		$SPACEFISH_KUBECONTEXT_COLOR \
		$SPACEFISH_KUBECONTEXT_PREFIX \
		"$SPACEFISH_KUBECONTEXT_SYMBOL""$kube_context" \
		$SPACEFISH_KUBECONTEXT_SUFFIX
end
#
# Line separator
#

function __sf_section_line_sep -d "Separate the prompt into two lines"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_PROMPT_SEPARATE_LINE true

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	if test "$SPACEFISH_PROMPT_SEPARATE_LINE" = "true"
		echo -e -n \n
	end
end
#
# Node.js
#
# Node.js is a JavaScript runtime built on Chrome's V8 JavaScript engine.
# Link: https://nodejs.org/

function __sf_section_node -d "Display the local node version"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_NODE_SHOW true
	__sf_util_set_default SPACEFISH_NODE_PREFIX $SPACEFISH_PROMPT_DEFAULT_PREFIX
	__sf_util_set_default SPACEFISH_NODE_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	__sf_util_set_default SPACEFISH_NODE_SYMBOL "⬢ "
	__sf_util_set_default SPACEFISH_NODE_DEFAULT_VERSION ""
	__sf_util_set_default SPACEFISH_NODE_COLOR green

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	# Show the current version of Node
	[ $SPACEFISH_NODE_SHOW = false ]; and return

	# Show versions only for Node-specific folders
	if not test -f ./package.json \
		-o -d ./node_modules \
		-o (count *.js) -gt 0
		return
	end

	if type -q nvm
		# Only recheck the node version if the nvm bin has changed
		if test "$NVM_BIN" != "$sf_last_nvm_bin" -o -z "$sf_node_version"
			set -g sf_node_version (nvm current ^/dev/null)
			set -g sf_last_nvm_bin $NVM_BIN
		end
	else if type -q nodenv
		set -g sf_node_version (nodenv version-name ^/dev/null)
	else if type -q node
		set -g sf_node_version (node -v ^/dev/null)
	else
		return
	end

	# Don't echo section if the system verison of node is being used
	[ "$sf_node_version" = "system" -o "$sf_node_version" = "node" ]; and return

	# Don't echo section if the node version matches the default version
	[ "$sf_node_version" = "$SPACEFISH_NODE_DEFAULT_VERSION" ]; and return

	__sf_lib_section \
		$SPACEFISH_NODE_COLOR \
		$SPACEFISH_NODE_PREFIX \
		"$SPACEFISH_NODE_SYMBOL$sf_node_version" \
		$SPACEFISH_NODE_SUFFIX
end
#
# Package
#
# Current package version.
# These package managers supported:
#   * NPM

function __sf_section_package -d "Display the local package version"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_PACKAGE_SHOW true
	__sf_util_set_default SPACEFISH_PACKAGE_PREFIX "is "
	__sf_util_set_default SPACEFISH_PACKAGE_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	__sf_util_set_default SPACEFISH_PACKAGE_SYMBOL "📦 "
	__sf_util_set_default SPACEFISH_PACKAGE_COLOR red

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	[ $SPACEFISH_PACKAGE_SHOW = false ]; and return

	# Show package version only when repository is a package
	[ -f ./package.json ]; or return
	# Show package version only if npm is installed
	type -q npm; or return

	set -l version_line (grep -E '"version": "v?([0-9]+\.){1,}' package.json)
	set -l package_version (string split \" $version_line)[4]

	if test -z "$package_version"
		set package_version ⚠
	else
		set package_version "v$package_version"
	end

	__sf_lib_section \
		$SPACEFISH_PACKAGE_COLOR \
		$SPACEFISH_PACKAGE_PREFIX \
		"$SPACEFISH_PACKAGE_SYMBOL$package_version" \
		$SPACEFISH_PACKAGE_SUFFIX
end
#
# PHP
#
# PHP is a server-side scripting language designed primarily for web development.
# Link: http://www.php.net/

function __sf_section_php -d "Display the current php version"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_PHP_SHOW true
	__sf_util_set_default SPACEFISH_PHP_PREFIX $SPACEFISH_PROMPT_DEFAULT_PREFIX
	__sf_util_set_default SPACEFISH_PHP_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	__sf_util_set_default SPACEFISH_PHP_SYMBOL "🐘 "
	__sf_util_set_default SPACEFISH_PHP_COLOR blue

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	# Show current version of PHP
	[ $SPACEFISH_PHP_SHOW = false ]; and return

	# Ensure the php command is available
	type -q php; or return

	if not test -f composer.json \
		-o (count *.php) -gt 0
		return
	end

	set -l php_version (php -v | string match -r 'PHP\s*[0-9.]+' | string split ' ')[2]

	__sf_lib_section \
		$SPACEFISH_PHP_COLOR \
		$SPACEFISH_PHP_PREFIX \
		"$SPACEFISH_PHP_SYMBOL"v"$php_version" \
		$SPACEFISH_PHP_SUFFIX
end
# pyenv
#

function __sf_section_pyenv -d "Show current version of pyenv Python, including system."
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_PYENV_SHOW true
	__sf_util_set_default SPACEFISH_PYENV_PREFIX $SPACEFISH_PROMPT_DEFAULT_PREFIX
	__sf_util_set_default SPACEFISH_PYENV_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	__sf_util_set_default SPACEFISH_PYENV_SYMBOL "🐍 "
	__sf_util_set_default SPACEFISH_PYENV_COLOR yellow

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	# Show pyenv python version
	[ $SPACEFISH_PYENV_SHOW = false ]; and return

	# Ensure the pyenv command is available
	type -q pyenv; or return

	# Show pyenv python version only for Python-specific folders
	if not test -f requirements.txt \
		-o (count *.py) -gt 0
		return
	end

	set -l pyenv_status (pyenv version-name ^/dev/null) # This line needs explicit testing in an enviroment that has pyenv.

	__sf_lib_section \
		$SPACEFISH_PYENV_COLOR \
		$SPACEFISH_PYENV_PREFIX \
		"$SPACEFISH_PYENV_SYMBOL""$pyenv_status" \
		$SPACEFISH_PYENV_SUFFIX
end
#
# Ruby
#
# A dynamic, reflective, object-oriented, general-purpose programming language.
# Link: https://www.ruby-lang.org/

function __sf_section_ruby -d "Show current version of Ruby"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_RUBY_SHOW true
	__sf_util_set_default SPACEFISH_RUBY_PREFIX $SPACEFISH_PROMPT_DEFAULT_PREFIX
	__sf_util_set_default SPACEFISH_RUBY_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	__sf_util_set_default SPACEFISH_RUBY_SYMBOL "💎 "
	__sf_util_set_default SPACEFISH_RUBY_COLOR red

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	# Check if that user wants to show ruby version
	[ $SPACEFISH_RUBY_SHOW = false ]; and return

	# Show versions only for Ruby-specific folders
	if not test -f Gemfile \
		-o -f Rakefile \
		-o (count *.rb) -gt 0
		return
	end

	set -l ruby_version

	if type -q rvm-prompt
		set ruby_version (rvm-prompt i v g)
	else if type -q rbenv
		set ruby_version (rbenv version-name)
	else if type -q chruby
		set ruby_version $RUBY_AUTO_VERSION
	else if type -q asdf
		set ruby_version (asdf current ruby | awk '{print $1}')
	else
		return
	end

	[ -z "$ruby_version" -o "$ruby_version" = "system" ]; and return

	# Add 'v' before ruby version that starts with a number
	if test -n (echo (string match -r "^[0-9].+\$" "$ruby_version"))
		set ruby_version "v$ruby_version"
	end

	__sf_lib_section \
		$SPACEFISH_RUBY_COLOR \
		$SPACEFISH_RUBY_PREFIX \
		"$SPACEFISH_RUBY_SYMBOL""$ruby_version" \
		$SPACEFISH_RUBY_SUFFIX
end
#
# Rust
#
# Rust is a systems programming language sponsored by Mozilla Research.
# Link: https://www.rust-lang.org

function __sf_section_rust -d "Display the current Rust version"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_RUST_SHOW true
	__sf_util_set_default SPACEFISH_RUST_PREFIX $SPACEFISH_PROMPT_DEFAULT_PREFIX
	__sf_util_set_default SPACEFISH_RUST_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	__sf_util_set_default SPACEFISH_RUST_SYMBOL "𝗥 "
	__sf_util_set_default SPACEFISH_RUST_COLOR red
	__sf_util_set_default SPACEFISH_RUST_VERBOSE_VERSION false

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	# Show current version of Rust
	[ $SPACEFISH_RUST_SHOW = false ]; and return

	# Ensure the rustc command is available
	type -q rustc; or return

	if not test -f Cargo.toml \
		-o (count *.rs) -gt 0
		return
	end

	set -l rust_version (rustc --version | string split ' ')[2]

	if test $SPACEFISH_RUST_VERBOSE_VERSION = false
        set rust_version (string split '-' $rust_version)[1] # Cut off -suffixes from version. "v1.30.0-beta" vs "v1.30.0"
	end

	__sf_lib_section \
		$SPACEFISH_RUST_COLOR \
		$SPACEFISH_RUST_PREFIX \
		"$SPACEFISH_RUST_SYMBOL"v"$rust_version" \
		$SPACEFISH_RUST_SUFFIX
end
#
# Time
#

function __sf_section_time -d "Display the current time!"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_TIME_SHOW false
	__sf_util_set_default SPACEFISH_DATE_SHOW false
	__sf_util_set_default SPACEFISH_TIME_PREFIX "at "
	__sf_util_set_default SPACEFISH_TIME_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	__sf_util_set_default SPACEFISH_TIME_FORMAT false
	__sf_util_set_default SPACEFISH_TIME_12HR false
	__sf_util_set_default SPACEFISH_TIME_COLOR "yellow"

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	[ $SPACEFISH_TIME_SHOW = false ]; and return

	if test $SPACEFISH_DATE_SHOW = true
		set time_str (date '+%Y-%m-%d')" "
	end

	if not test $SPACEFISH_TIME_FORMAT = false
		set time_str $SPACEFISH_TIME_FORMAT
	else if test $SPACEFISH_TIME_12HR = true
		set time_str "$time_str"(date '+%I:%M:%S') # Fish doesn't seem to have date/time formatting.
	else
		set time_str "$time_str"(date '+%H:%M:%S')
	end

	__sf_lib_section \
		$SPACEFISH_TIME_COLOR \
		$SPACEFISH_TIME_PREFIX \
		$time_str \
		$SPACEFISH_TIME_SUFFIX
end
#
# Username
#

function __sf_section_user -d "Display the username"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	# --------------------------------------------------------------------------
	# | SPACEFISH_USER_SHOW | show username on local | show username on remote |
	# |---------------------+------------------------+-------------------------|
	# | false               | never                  | never                   |
	# | always              | always                 | always                  |
	# | true                | if needed              | always                  |
	# | needed              | if needed              | if needed               |
	# --------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_USER_SHOW true
	__sf_util_set_default SPACEFISH_USER_PREFIX "with "
	__sf_util_set_default SPACEFISH_USER_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	__sf_util_set_default SPACEFISH_USER_COLOR yellow
	__sf_util_set_default SPACEFISH_USER_COLOR_ROOT red

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	[ $SPACEFISH_USER_SHOW = false ]; and return

	if test "$SPACEFISH_USER_SHOW" = "always" \
	-o "$LOGNAME" != "$USER" \
	-o "$UID" = "0" \
	-o \( "$SPACEFISH_USER_SHOW" = "true" -a -n "$SSH_CONNECTION" \)

		set -l user_color
		if test "$USER" = "root"
			set user_color $SPACEFISH_USER_COLOR_ROOT
		else
			set user_color $SPACEFISH_USER_COLOR
		end

		__sf_lib_section \
			$user_color \
			$SPACEFISH_USER_PREFIX \
			$USER \
			$SPACEFISH_USER_SUFFIX
	end
end
#
# Vi Mode
#

function __sf_section_vi_mode -d "Display vi mode status"
	# ------------------------------------------------------------------------------
	# Configuration
	# ------------------------------------------------------------------------------

	__sf_util_set_default SPACEFISH_VI_MODE_SHOW true
	__sf_util_set_default SPACEFISH_VI_MODE_PREFIX " "
	__sf_util_set_default SPACEFISH_VI_MODE_SUFFIX $SPACEFISH_PROMPT_DEFAULT_SUFFIX
	__sf_util_set_default SPACEFISH_VI_MODE_INSERT [I]
	__sf_util_set_default SPACEFISH_VI_MODE_NORMAL [N]
	__sf_util_set_default SPACEFISH_VI_MODE_VISUAL [V]
	__sf_util_set_default SPACEFISH_VI_MODE_REPLACE_ONE [R]
	__sf_util_set_default SPACEFISH_VI_MODE_COLOR white

	# ------------------------------------------------------------------------------
	# Section
	# ------------------------------------------------------------------------------

	[ $SPACEFISH_VI_MODE_SHOW = false ]; and return

	# Ensure fish_vi_key_bindings or fish_hybrid_key_bindings are used
	# Here we are trying to be compatible with default fish_mode_prompt implementation,
	# wich handle both "fish_vi_key_bindings" and "fish_hybrid_key_bindings"
	[ "$fish_key_bindings" = "fish_vi_key_bindings" ]; or [ "$fish_key_bindings" = "fish_hybrid_key_bindings" ]; or return

	# Use `set -l` to define local variables to avoid populating
  	# the global namespace
	set -l vi_mode_symbol

	# Check current mode and set vi_mode_symbol based on it
	switch $fish_bind_mode
		case default
			set vi_mode_symbol $SPACEFISH_VI_MODE_NORMAL
		case insert
			set vi_mode_symbol $SPACEFISH_VI_MODE_INSERT
		case replace_one
			set vi_mode_symbol $SPACEFISH_VI_MODE_REPLACE_ONE
		case visual
			set vi_mode_symbol $SPACEFISH_VI_MODE_VISUAL
	end

	__sf_lib_section \
		$SPACEFISH_VI_MODE_COLOR \
		$SPACEFISH_VI_MODE_PREFIX \
		$vi_mode_symbol \
		$SPACEFISH_VI_MODE_SUFFIX
end
#
# Git branch
#

function __sf_util_git_branch -d "Display the current branch name"
	echo (command git rev-parse --abbrev-ref HEAD ^/dev/null)
end
#
# Human time
#

function __sf_util_human_time -d "Humanize a time interval for display"
	command awk '
		function hmTime(time,   stamp) {
			split("h:m:s:ms", units, ":")
			for (i = 2; i >= -1; i--) {
				if (t = int( i < 0 ? time % 1000 : time / (60 ^ i * 1000) % 60 )) {
					stamp = stamp t units[sqrt((i - 2) ^ 2) + 1] " "
				}
			}
			if (stamp ~ /^ *$/) {
				return "0ms"
			}
			return substr(stamp, 1, length(stamp) - 1)
		}
		{
			print hmTime($0)
		}
	'
end
#
# Set default
#

function __sf_util_set_default -a var -d "Set the default value for a global variable"
	if not set -q $var
		# Multiple arguments will become a list
		set -g $var $argv[2..-1]
	end
end
#
# Truncate directory
#

function __sf_util_truncate_dir -a path truncate_to -d "Truncate a directory path"
	if test "$truncate_to" -eq 0
		echo $path
	else
		set -l folders (string split / $path)

		if test (count $folders) -le "$truncate_to"
			echo $path
		else
			echo (string join / $folders[(math 0 - $truncate_to)..-1])
		end
	end
end
