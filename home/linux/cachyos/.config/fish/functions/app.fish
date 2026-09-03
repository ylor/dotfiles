function app
    set action $argv[1]
    set interactive false

    if set -q action[1]
        if not contains -- $action hide rename reveal
            printf 'Usage: app hide|rename|reveal\n' >&2
            return 2
        end
    else
        set interactive true
    end

    while true
        if $interactive
            set action (printf '%s\n' Hide Rename Reveal | gum choose --header 'Action')
            test -n "$action"; or return
            set action (string lower $action)
        end

        set applications
        set application_names
        set overrides $DOTFILES/platforms/linux/distros/cachyos/home/.local/share/applications

        if test $action = reveal
            for override in $overrides/*.desktop
                grep -q '^Hidden=true' $override; or continue

                set application (path basename $override)
                set friendly_name (string replace -r '^Name=' '' (string match -r '^Name=.*' < $override)[1])
                set -q friendly_name[1]; or set friendly_name $application
                set -a applications $application
                set -a application_names $friendly_name
            end
        else
            for candidate in /usr/share/applications/*.desktop
                set application (path basename $candidate)
                set override $overrides/$application
                set desktop_file $candidate
                test -f $override; and set desktop_file $override

                if string match --quiet --regex '^(Hidden|NoDisplay)=true$' <$desktop_file
                    continue
                end

                set desktop_type (string replace -r '^Type=' '' (string match -r '^Type=.*' < $desktop_file)[1])
                if test "$desktop_type" != Application
                    continue
                end

                set name_source $desktop_file
                set friendly_name (string replace -r '^Name=' '' (string match -r '^Name=.*' < $name_source)[1])
                set -q friendly_name[1]; or set friendly_name $application
                set -a applications $application
                set -a application_names $friendly_name
            end
        end

        set selected_name (printf '%s\n' $application_names | sort --ignore-case | gum filter)
        if not test -n "$selected_name"
            $interactive; and continue
            return
        end

        set selected_index (contains -i -- $selected_name $application_names)
        set application $applications[$selected_index]
        set local_destination $HOME/.local/share/applications/$application
        set dotfiles_destination $overrides/$application

        switch $action
            case hide
                mkdir -p (path dirname $local_destination) (path dirname $dotfiles_destination)
                printf '[Desktop Entry]\nName=%s\nHidden=true\n' $selected_name >$local_destination
                printf '[Desktop Entry]\nName=%s\nHidden=true\n' $selected_name >$dotfiles_destination
            case reveal
                rm -f $local_destination
                rm -f $dotfiles_destination
            case rename
                set new_name (gum input --value "$selected_name" --prompt 'New name: ')
                if not test -n "$new_name"
                    $interactive; and continue
                    return
                end

                set source /usr/share/applications/$application
                mkdir -p (path dirname $local_destination) (path dirname $dotfiles_destination)
                set in_desktop false
                set wrote_name false

                begin
                    while read --line line
                        if test "$line" = '[Desktop Entry]'
                            set in_desktop true
                            printf '%s\n' $line
                            continue
                        end

                        if $in_desktop; and string match --quiet --regex '^\[' $line
                            if not $wrote_name
                                printf 'Name=%s\n' $new_name
                                set wrote_name true
                            end
                            set in_desktop false
                        end

                        if $in_desktop; and string match --quiet --regex '^Name(\[[^]]+\])?=' $line
                            if not $wrote_name
                                printf 'Name=%s\n' $new_name
                                set wrote_name true
                            end
                            continue
                        end

                        printf '%s\n' $line
                    end

                    if $in_desktop; and not $wrote_name
                        printf 'Name=%s\n' $new_name
                    end
                end <$source >$local_destination

                if test (path resolve $local_destination) != (path resolve $dotfiles_destination)
                    cp $local_destination $dotfiles_destination
                end
        end

        return
    end
end
