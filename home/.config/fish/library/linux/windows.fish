function windows
    # if not test -f "/etc/sudoers.d/90-efibootmgr"
    #     echo "$(whoami) ALL=(root) NOPASSWD: /usr/bin/efibootmgr -n *" | sudo tee "/etc/sudoers.d/efibootmgr"
    # end
    
    set entry (efibootmgr | grep -i windows | string sub --start 5 --end 8)
    sudo efibootmgr -n $entry || exit 1
    systemctl reboot
end