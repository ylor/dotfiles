function pass
    set -l consonants b c d f g h j k l m n p q r s t v w x z
    set -l vowels a e i o y u
    set -l phrase
    for _ in (seq 4)
        set -a phrase \
            (random choice $consonants) \
            (random choice $vowels) \
            (random choice $consonants)
    end
    set -i phrase[7] -

    set -l upper_pos (random choice 1 8)
    set phrase[$upper_pos] (string upper $phrase[$upper_pos])

    set -l password (string join '' $phrase)
    set -l digit_pos (random choice 6 7 14)
    set password (string sub -e $digit_pos $password)(random 1 9)(string sub -s (math $digit_pos + 1) $password)

    command -q pbcopy; and printf %s $password | pbcopy
    command -q wl-copy; and printf %s $password | wl-copy
    echo $password
end
