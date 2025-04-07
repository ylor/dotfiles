function pass
    set consonants b c d f g h j k l m n p q r s t v w x z
    set vowels a e i o y u
    set phrase

    for x in seq 3
       set --append phrase $(random choice $consonants)
       set --append phrase $(random choice $vowels)
       set --append phrase $(random choice $consonants)
    end
    set --append phrase "-"
    for x in seq 3
       set --append phrase $(random choice $consonants)
       set --append phrase $(random choice $vowels)
       set --append phrase $(random choice $consonants)
    end

    set digit (random choice (seq 1 9))
    set hyphen_target $(random choice 7 9 14)

   set upper_target $(random choice 1 8)
   set phrase[$upper_target] (string upper $phrase[$upper_target])
   set --append phrase $digit
  string join '' $phrase
end
