function adf
    set -l my_string "Hello World"
    set -l index 6
    set -l new_text "beautiful"

    # Extract substrings before and after the index
    set -l before (string sub --start 1 --end $index $my_string)
    set -l after (string sub --start $index $my_string)

    # Concatenate the substrings with the new text
    set -l result "$before$new_text$after"

    echo $result
end
