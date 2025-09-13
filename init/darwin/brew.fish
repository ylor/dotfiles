set --universal --export HOMEBREW_NO_ANALYTICS 1
set --universal --export HOMEBREW_NO_ENV_HINTS 1

# packages
set pkgs bat evil-helix eza fd fzf mas mise ripgrep zoxide
set installed_pkgs (brew list --formula)
for pkg in $pkgs
    if not echo "$installed_pkgs" | grep -iq "$pkg"
        gum spin --spinner=(dot-spinner-random) --title="brewing $pkg..." -- brew install --quiet $pkg
    end
end

if [ $DOT_MODE = full ]
    set xtra_pkgs bat evil-helix eza fd fzf jq mas mise ripgrep zoxide
    set installed_pkgs (brew list --formula)
    for pkg in $xtra_pkgs
        if not echo "$installed_pkgs" | grep -iq "$pkg"
            gum spin --spinner=(dot-spinner-random) --title="brewing $pkg..." -- brew install --quiet $pkg
        end
    end

    # casks
    set casks 1password appcleaner betterdisplay ghostty hammerspoon hyperkey maccy zed
    set installed_casks (brew list --cask)
    for cask in $casks
        if not echo "$installed_casks" | grep -iq "$cask"
            gum spin --spinner=(dot-spinner-random) --title="brewing $cask..." -- brew install --quiet $cask
        end
    end

    # App Store
    set apps 1Password-1569813296 Noir-1592917505 Wipr-1662217862
    set installed_apps (mas list)
    for app in $apps
        set id (string split "-" -- $app)[2]
        set title (string split "-" -- $app)[1]
        if not echo "$installed_apps" | grep -iq "$id"
            gum spin --spinner=(dot-spinner-random) --title="installing $title..." -- mas install "$id" &>/dev/null
        end
    end
end
