# if command -q starship # starship.rs
#     starship init fish | source
# end

# function fish_prompt
# set --local last_status $status

# function detect_os
# switch $(uname)
#         case Linux
#             echo "🐧"
#         case Darwin
#                 echo ""
#         case '*'
#                 echo "⊙"
#     end
# end

# set --local os $(detect_os)
# set --local directory $(basename $PWD)
# set --local symbol_color $([ $last_status -eq 0 ] && set_color green || set_color red )
# set --local symbol "➜"

# echo "$os $directory $symbol_color$symbol $(set_color normal)"
# end

# function fish_right_prompt
#     set --local last_status $status
#     set --local time $(date +"%-I:%M %p")
#     echo "$time"
# end

# Source all .fish files found in .config/fish/plugins/
# for plugin in $__fish_config_dir/plugins/**.fish
#      source $plugin
# end

# function spin
#      set -l symbols "⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷"
#      while sleep 0.1
#          echo -e -n "\b$symbols[1]"
#          set symbols $symbols[2..-1] $symbols[1]
#      end
#  end
