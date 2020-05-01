#!/usr/bin/env sh

# Get the command line tools and accept the license, if not installed/accepted
if ! xcode-select -p &>/dev/null; then
	xcode-select --install &>/dev/null
	sudo xcodebuild -license accept &>/dev/null
fi

# Install Homebrew if it's not already installed and install packages
if ! command -v brew; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" && brew update && brew upgrade && brew bundle && brew cleanup

	# Brew taps
	taps=(
		beeftornado/rmtree
		homebrew/cask-fonts
	)
	for tap in "${taps[@]}"; do
		brew tap $tap
	done

	# Brew packages
	pkgs=(
		bash
		bat
		exa
		fd
		ffmpeg
		fish
		git
		lua
		mas
		media-info
		mkvtoolnix
		neovim
		node
		rename
		ripgrep
		starship
		tmux
		trash
		tree
		yarn
	)
	for pkg in "${pkgs[@]}"; do
		brew install $pkg
	done

	# Brew casks
	casks=(
		appcleaner
		hazel
		hwsensors
		keyboardcleantools
		mkvtools
		mp4tools
		mpv
		omnidisksweeper
		superduper
		the-unarchiver
		visual-studio-code
		xld
	)
	for cask in "${casks[@]}"; do
		brew cask install $cask
	done

	# mas
	# apps=(John Harry Jake Scott Philis)
	# for app in "${apps[@]}"; do
	# 	echo mas $app
	# done
fi

echo "Done. Note that some of these changes require a logout/restart to take effect."
