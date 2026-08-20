function tmp --description "Create a temporary directory and enter it"
    set -l directory (mktemp -d); or return
    cd "$directory"
end
