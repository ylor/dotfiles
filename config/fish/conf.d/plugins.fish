# Bootstrap fisher if not installed
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fisher add matchai/spacefish
end

# Source Functions
[ -d ~/.config/fish/functions ]; and for function in ~/.config/fish/functions/*.fish; source $function; end

# Source Autojump
[ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish

