set -q DOTFILES; or return

# Run in a separate fish so setup cannot change this shell, e.g. by replacing sudo.
function dfs --description "Configure the system and manage linked files"
    fish $DOTFILES/main.fish $argv
end
