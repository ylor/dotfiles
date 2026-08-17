function triplet
    set consonants b c d f g h j k l m n p q r s t v w x z
    set vowels a e i o y u
    for i in (seq 2)
        echo (random choice $consonants)
        echo (random choice $vowels)
        echo (random choice $consonants)
    end
end

function pass
    set digit (random choice (seq 9))
    set digit_pos (random choice 6 7 14)
    set upper_pos (random choice 1 8)

    set phrase (triplet) - (triplet)
    set phrase[$upper_pos] (string upper $phrase[$upper_pos])

    set pass (string join '' $phrase)
    set pass (string sub -s 1 -l $digit_pos $pass)$digit(string sub -s (math $digit_pos + 1) $pass)

    if command -vq pbcopy
        echo $pass | pbcopy
    end

    if command -vq wl-copy
        echo $pass | wl-copy
    end

    echo $pass
end
