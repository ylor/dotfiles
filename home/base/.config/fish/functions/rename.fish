function rename --description "Interactively rename a file with gum"
    set -l src $argv[1]
    test -n "$src"; or set src (gum file --all .); or __rename_abort; or return 1
    test -e "$src"; or begin
        echo "rename: $src: no such file" >&2
        return 1
    end

    set -l old (path basename -- $src)
    set -l new (gum input --value "$old" --header "Rename $src"); or __rename_abort; or return 1
    test -n "$new" -a "$new" != "$old"; or return 0

    set -l dest (path dirname -- $src)/$new
    if test -e "$dest"
        # answering "No" exits 1 and prints nothing, so there is no line to erase
        gum confirm "$new already exists. Overwrite?"; or begin
            test $status -eq 1; and echo "Rename canceled"; or __rename_abort
            return 1
        end
    end

    command mv -f -- $src $dest; and echo "Renamed $old → $new"
end

function __rename_abort
    # gum prints its own one-line cancel message ("not submitted", "no file selected"); erase it
    printf '\e[1A\e[2K' >&2
    echo "Rename canceled"
    return 1
end
