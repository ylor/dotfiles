# bebop end cards
# eva title cards

function cowboy-bebop
    set symbol "✈"
    set greetings \
        "ARE YOU LIVING IN THE REAL WORLD?" \
        "DO YOU HAVE A COMRADE?" \
        "EASY COME, EASY GO…" \
        "LIFE IS BUT A DREAM..." \
        "SEE YOU COWGIRL, SOMEDAY, SOMEWHERE!" \
        "SEE YOU SPACE COWBOY…" \
        "SEE YOU SPACE SAMURAI..." \
        "SLEEEPING BEAST" \
        "YOU'RE GONNA CARRY THAT WEIGHT."
    echo $symbol (set_color --italics)(random choice $greetings)
end

function half-life
    set symbol "λ"
    set greetings \
        "Gordon Freeman! You’re alive!" \
        "Great Scott! Gordon Freeman! I had a feeling you’d show up." \
        "It's me, Gordon — Barney, from Black Mesa!" \
        "The right man in the wrong place can make all the difference in the world." \
        "Wake up, Mr. Freeman. Wake up and…smell the ashes."
    echo $symbol (set_color --italics)(random choice $greetings)
end

function zelda
    set symbol "▲"
    set greetings \
        "Hey! Listen!" \
        "It's dangerous to go alone! Take this."
    echo $symbol (set_color --italics)(random choice $greetings)
end

function fish_greeting
    set greeting (random choice cowboy-bebop half-life)
    $greeting
    echo
end
