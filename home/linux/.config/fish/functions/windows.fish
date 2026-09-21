function windows
    set -l entry (efibootmgr | string match -i '*windows*' | string sub -s 5 -l 4)[1]
    or return 1

    if not sudo -n -l /usr/bin/efibootmgr -n $entry &>/dev/null
        printf '%s\n' "$USER ALL=(root) NOPASSWD: /usr/bin/efibootmgr -n *" |
            sudo install -m 0440 /dev/stdin /etc/sudoers.d/90-efibootmgr
        or return 1
    end

    sudo -n /usr/bin/efibootmgr -n $entry; and omarchy system reboot
end

alias hell="windows"
