function up
    set kernel (uname -s | string lower)
    if test $kernel = darwin
        brew up
    end
end
