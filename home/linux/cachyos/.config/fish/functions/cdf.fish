function cdf
    set -l locations (gdbus call \
        --session \
        --dest org.gnome.Nautilus \
        --object-path /org/freedesktop/FileManager1 \
        --method org.freedesktop.DBus.Properties.Get \
        org.freedesktop.FileManager1 OpenWindowsWithLocations 2>/dev/null)

    set -l uri (string match -r "file://[^']+" -- $locations | head -n 1)
    if test -z "$uri"
        echo "cdf: no open Nautilus window" >&2
        return 1
    end

    set -l path (string unescape --style=url (string replace 'file://' '' -- $uri))
    if not test -d "$path"
        echo "cdf: Nautilus location is not a directory" >&2
        return 1
    end

    cd "$path"
end
