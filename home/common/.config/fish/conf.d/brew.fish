set -gx HOMEBREW_NO_ANALYTICS 1
set -gx HOMEBREW_NO_ASK 1
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx HOMEBREW_NO_ENV_HINTS 1

for path in /opt/homebrew /home/linuxbrew/.linuxbrew
    test -x $path/bin/brew; and $path/bin/brew shellenv | source; and break
end

if command -q brew; and status --is-interactive
    function brew
        set -l cmd $argv[1]
        set -l args $argv[2..]
        set -l fzf_opts --multi --preview 'HOMEBREW_COLOR=1 brew info {}' --query=(string join -- ' ' $args)

        switch $cmd
            case install i
                command brew install $args

            case reinstall re
                command brew reinstall $args

            case remove rm
                if command brew uninstall $args
                    true
                else if command -q fzf
                    set -l pkgs (begin; command brew leaves; command brew list --casks; end | fzf $fzf_opts)
                    and command brew uninstall $pkgs
                end

            case search s
                if command -q fzf
                    set -l pkgs (begin; brew formulae; brew casks; end | fzf $fzf_opts)
                    and command brew install $pkgs
                else
                    command brew search $args
                end

            case up
                command brew update; and command brew upgrade

            case '*'
                command brew $argv
        end
    end

    abbr b brew
    alias up="brew up"
    # alias bi="brew i"
    # alias bls="brew ls"
    # alias brm="brew rm"
    # alias bs="brew s"
    # alias bup="brew up"
end
