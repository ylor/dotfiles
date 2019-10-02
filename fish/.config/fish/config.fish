# General
set fish_greeting
set fish_title
set -x EDITOR 'vi'
set -x VISUAL 'code'
set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8

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
test -d ~/bin && set PATH ~/bin $PATH
test -d ~/.bin && set PATH ~/.bin $PATH
test -d ~/.npm/bin && set PATH ~/.npm/bin $PATH
test -d ~/.yarn/bin && set PATH ~/.yarn/bin $PATH
test -d ~/.cargo/bin && set PATH ~/.cargo/bin $PATH

# Abbreviations
if status --is-interactive
  set -g fish_user_abbr --abbreviations
  abbr --add dp 'dotpull'
  abbr --add g 'git'
  abbr --add ga 'git add -A;'
  abbr --add gcm 'git commit -m'
  abbr --add gp 'git pull'
  abbr --add gpsh 'git push'
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
alias dotpull="git -C ~/Documents/dotfiles pull; exec fish"
alias fucking="sudo"
alias home="cd $HOME"
alias http="python -m SimpleHTTPServer"
alias md="mkdir -p"
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"
alias reboot="sudo shutdown -r now"
alias reload="exec fish"
alias shutdown="sudo shutdown -s now"
alias rd="rmdir"

# Functions
## Quality of Life
### git clone && cd to it
function gc
  if test (echo "$argv" | awk -F "/" '{print NF-1}') >/dev/null -eq 0
  git clone --recurse-submodules "https://github.com/ylor/$argv"
  else if test (echo "$argv" | awk -F "/" '{print NF-1}') >/dev/null -eq 1
  git clone --recurse-submodules "https://github.com/$argv"
  else
  git clone --recurse-submodules "$argv"
  end
  cd (basename $argv)
end

### mkdir & cd to it
function mdcd
  mkdir $argv && cd $argv
end

## Utility Replacements if available

# Replaces find with fd - https://github.com/sharkdp/fd
if command -vq fd
  alias find="fd"
end

# Replaces ls with exa - https://github.com/ogham/exa
if command -vq exa
  alias la="exa -la"
  alias ll="exa -l"
  alias ls="exa"
end

# Replaces top with htop - https://github.com/hishamhm/htop
if command -vq htop
  alias top="htop"
end

# Replaces grep with ripgrep (lol) - https://github.com/BurntSushi/ripgrep
if command -vq rg
  alias grep="rg"
end

# Replaces vi(m) with neovim - https://github.com/neovim/neovim
if command -vq nvim
  alias vi="nvim"
  alias vim="nvim"
end

# Autojumper - https://github.com/skywind3000/z.lua
if command -vq lua ~/bin/z.lua
  source (lua ~/bin/z.lua --init fish enhanced | psub)
  alias j="z"
end

# Prompt - https://github.com/starship/starship
if command -vq starship
  source ("/usr/local/bin/starship" init fish --print-full-init | psub)
end
