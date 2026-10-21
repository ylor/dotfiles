function cdf
    set -l class (hyprctl clients -j | jq -r '
        map(select(.class == "io.github.lgse.Strata" or .class == "com.thisisgm.flea"))
        | min_by(.focusHistoryID).class')

    switch $class
        case io.github.lgse.Strata
            # strata has no location on D-Bus, but rewrites its tab session on every navigation
            set -l session ~/.config/strata/tabs.toml
            set -l active (string match -rg '^active = (\d+)' <$session)
            set -l tabs (string match -rg '^value = "(.*)"' <$session)
            cd $tabs[(math $active + 1)]
        case com.thisisgm.flea
            cd (flea --ui-state | jq -r .lastPath)
        case '*'
            echo "cdf: no file manager window" >&2
            return 1
    end
end
