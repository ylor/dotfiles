function up
    set kernel (uname -s | string lower)
    if test $kernel = darwin
        brew update && brew upgrade
    end
end
