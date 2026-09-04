if command -q mise
    mise activate fish | source

    if status --is-interactive
        function _mise_packages
            set -l name $argv[1]
            set -l manager $argv[2]
            set -l command_name $argv[3]
            set -l package_names $argv[4..]

            if not contains -- $command_name install i list ls upgrade up uninstall remove rm
                set package_names $argv[3..]
                set command_name install
            end

            set -l packages

            for package_name in $package_names
                if string match -q -- '-*' $package_name
                    printf '%s: unsupported option: %s\n' $name $package_name >&2
                    return 2
                end

                set -a packages "$manager:$package_name"
            end

            switch $command_name
                case install i
                    mise bootstrap packages use --global --yes $packages
                case list ls
                    mise bootstrap packages status --cd / | string match -rg "^$manager\s+(\S+)"
                    or true
                case upgrade up
                    mise bootstrap packages upgrade --manager $manager --yes --cd /
                case uninstall remove rm
                    mise unuse --global --yes $packages
            end
        end

        function mrew
            _mise_packages mrew brew $argv
        end

        function mask
            _mise_packages mask brew-cask $argv
        end
    end
end
