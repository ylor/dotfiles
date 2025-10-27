function icat
    argparse 'i/image=' 't/text=' 'h/help' -- $argv ; or return 67

    set img $DOTFILES/home/.config/fish/prompt/img/$_flag_image
    set txt $_flag_text

    viu $img -h2 && printf "\033[A\033[K     $txt\n"
end

 icat -i "silksong.png" -t "Poshanka!"

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
    set symbol λ
    set greetings \
        "Gordon Freeman! You’re alive!" \
        "Great Scott! Gordon Freeman! I had a feeling you’d show up." \
        "It's me, Gordon — Barney, from Black Mesa!" \
        "The right man in the wrong place can make all the difference in the world." \
        "Wake up, Mr. Freeman. Wake up and…smell the ashes."
    echo $symbol (set_color --italics)(random choice $greetings)
end

function hollow-knight
    set symbol ◯
    set greetings \
        "Bapanada..." \
        "Poshanka!"
    echo $symbol (set_color --italics)(random choice $greetings)
end

function metal-gear-solid
    set symbol "!"
    set greetings \
        "From here on out, you're Big Boss." \
        "It's like one of my Japanese animes..." \
        "Kept you waiting, huh?" \
        "Metal Gear?!" \
        "Snake? Snake?! SNAAAAAKE!!!!" \
        "The la-li-lu-le-lo?" \
        "They played us like a damn fiddle!" \
        "Why are we still here? Just to suffer?"
    echo $symbol (set_color --italics)(random choice $greetings)
end

function zelda
    set symbol "△"
    set greetings \
        "Courage need not be remembered, for it is never forgotten." \
        "Hey! Listen!" \
        "HYAAAH!" \
        "It's dangerous to go alone! Take this." \
        "Wake up, Link."
    echo $symbol (set_color --italics)(random choice $greetings)
end

function fish_greeting
    set greeting (random choice cowboy-bebop half-life hollow-knight metal-gear-solid zelda)
    $greeting
    echo
end
