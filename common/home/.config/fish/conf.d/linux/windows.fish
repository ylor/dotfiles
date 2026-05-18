function windows
    if not test -f "/etc/sudoers.d/90-efibootmgr"
        echo "$USER ALL=(root) NOPASSWD: /usr/bin/efibootmgr -n *" | sudo tee "/etc/sudoers.d/efibootmgr"
    end

    set entry (string sub --start 5 --end 8 (efibootmgr | string match --entire -ir windows)[1])
    sudo efibootmgr -n $entry &>/dev/null || exit 1
    systemctl reboot
end

alias hell="windows"
