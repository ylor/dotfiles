# General
set fish_greeting
set fish_title
set -x EDITOR 'vim'
set -x VISUAL 'vim'
set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8

# Prompt
function fish_title; echo; end
set SPACEFISH_DIR_TRUNC 0
set SPACEFISH_GIT_SYMBOL '•'

# Colors, Syntax Highlighting
set fish_color_command green
set fish_color_quote yellow
set fish_color_redirection purple
set fish_color_end green
set fish_color_error red
set fish_color_param normal
set fish_color_comment blue
set fish_color_match cyan
set fish_color_search_match purple
set fish_color_operator cyan
set fish_color_escape cyan
set fish_color_cwd green
set fish_color_cwd_root red
#set fish_pager_color_prefix cyan
#set fish_pager_color_completion blue
#set fish_pager_color_description yellow
#set fish_pager_color_progress cyan

#set -x LSCOLORS "GxFxCxDxBxegedabagaced"

# Add directory to PATH if it exists
test -d ~/.bin ; and set PATH ~/.bin $PATH

# Abbreviations
if status --is-interactive
  set -g fish_user_abbr --addeviations
  abbr --add g 'git'
  abbr --add gp 'git pull'
  abbr --add dot 'dotpull'
  abbr --add h 'home'
  abbr --add o 'open'
  abbr --add u 'update'
  abbr --add uf 'update-full'
  abbr --add v 'vim'
end

# Aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
alias cdf="cd (pfd)"
alias dotpull="git -C ~/Documents/dotfiles pull; exec fish"
alias dscleanup="sudo find / -name '*.DS_Store' -type f -ls -delete"
alias etrash="sudo rm -rfv /Volumes/*/.Trashes; and sudo rm -rfv ~/.Trash; and sudo rm -rfv /private/var/log/asl/*.asl"
alias find="fd"
alias flush="dscacheutil -flushcache; and sudo killall -HUP mDNSResponder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false; and killall Finder"
alias home="cd $HOME"
alias http="python -m SimpleHTTPServer"
alias j="z"
alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user; and killall Finder"
alias md="mkdir -p"
alias mkdir="mkdir -p"
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"
alias reboot="sudo shutdown -r now"
alias reload="exec fish"
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true; and killall Finder"
alias shutdown="sudo shutdown -s now"
alias vnc="open vnc://Server.local"
alias rd="rmdir"

# Functions

## Quality of Life
function gc
  git clone --recurse-submodules "$argv"; and cd (basename $argv)
end

alias nixi="nix-env -i"
alias nixu="nix-env -u"
alias nixun="nix-env --uninstall"
alias nixup="nix-env --upgrade"

function mdcd
  mkdir $argv; and cd $argv
end

function update -d "Update important software"
  echo (set_color white --bold)"// Homebrew"(set_color normal); and brew update; and brew upgrade; brew cleanup; brew cask cleanup
  echo (set_color white --bold)"// dotfiles"(set_color normal); and git -C ~/Documents/dotfiles/ pull
end

function update-full -d "Update all software"
  echo (set_color white --bold)"// Homebrew"(set_color normal); and brew update; and brew upgrade; brew cleanup; brew cask cleanup
  echo (set_color white --bold)"// dotfiles"(set_color normal); and git -C ~/Documents/dotfiles pull
  echo (set_color white --bold)"// Node"(set_color normal); and npm update -g;
  echo (set_color white --bold)"// mpv"(set_color normal); and brew reinstall mpv --with-bundle
  echo (set_color white --bold)"// Ruby"(set_color normal); and gem update
  echo (set_color white --bold)"// Python"(set_color normal); and python -m pip list --outdated | cut -d ' ' -f1 | xargs -n1 python -m pip install -U; and python3 -m pip list --outdated | cut -d ' ' -f1 | xargs -n1 python3 -m pip install -U
end

## Utility Replacements if available

 
if command -vq exa
  alias la="exa -la"
  alias ll="exa -l"
  alias ls="exa"
end

if command -vq htop
  alias top="htop"
end

if command -vq nvim
  alias vi="nvim"
  alias vim="nvim"
end

## Mac Specific
function cdf
  cd (osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)')
end
