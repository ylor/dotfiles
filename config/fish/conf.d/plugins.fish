# Source Functions
[ -d ~/.config/fish/functions ]; and for function in ~/.config/fish/functions/*.fish; source $function; end

# Bootstrap fisher if not installed
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

# Source thefuck
if command -v thefuck
    thefuck --alias | source
end

# Source linuxbrew if installed
[ -d ~/.linuxbrew ]; and eval (~/.linuxbrew/bin/brew shellenv)

# Source Nix
[ -d ~.nix-profile ]; and bass source ~/.nix-profile/etc/profile.d/nix.sh
