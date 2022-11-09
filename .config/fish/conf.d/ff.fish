if command -vq ffmpeg
    function ff # function that wraps ffmpeg
        if test (count $argv) -lt 2
            echo "Please specify either AAC, AC3, or FLAC and provide input(s)" && return 1
        else if string match --quiet --ignore-case --regex 'aac|ac3|flac' $argv[1]
            set argv[1] (string lower $argv[1])
    
            switch $argv[1]
                case 'aac'
                    set aencoder aac_at -aq 7
                case 'ac3'
                    set aencoder eac3 -ab 640k
                case 'flac'
                    set aencoder flac
            end
    
            set --erase argv[1]
    
            if test (count $argv) -eq 1
                set -l output (basename $argv .mkv).conv.mkv
                echo $argv
                echo $acodec
                echo $output
                ffmpeg -i $argv -map 0 -codec copy -acodec $aencoder $output
                #and trash $argv; and mv $output $argv
            else
    
                for input in $argv
                    set -l output (basename $input .mkv).conv.mkv
                    ffmpeg -i $input -map 0 -codec copy -acodec $aencoder $output
                    #and trash $input; and mv $output $input
                end
    
            end
        else
            echo "Please specify either AAC, AC3, or FLAC" && return 1
        end
    end
end