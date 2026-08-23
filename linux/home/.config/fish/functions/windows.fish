function windows
    set sudoers /etc/sudoers.d/90-efibootmgr
    if not test -f $sudoers
        printf '%s\n' "$USER ALL=(root) NOPASSWD: /usr/bin/efibootmgr -n *" | sudo install -m 0440 /dev/stdin $sudoers
        or return 1
    end

    set entry (string sub --start 5 --end 8 (efibootmgr | string match --entire -ir windows)[1])
    sudo efibootmgr -n $entry &>/dev/null
    or return 1

    hyprshutdown --post-cmd systemctl reboot || systemctl reboot
end

alias hell="windows"
