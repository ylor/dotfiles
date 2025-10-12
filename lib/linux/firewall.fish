if command -vq ufw
    # Allow nothing in, everything out
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    
    sudo ufw allow 22/tcp # ssh
    sudo ufw allow 27031/udp #steam remote play
    sudo ufw allow 27036/udp #steam remote play
    sudo ufw allow 27036/tcp #steam remote play
    sudo ufw allow 27037/tcp #steam remote play
    sudo ufw allow 47990/tcp # sunshine
    sudo ufw allow 47984/tcp # sunshine
    sudo ufw allow 47989/tcp # sunshine
    sudo ufw allow 48010/tcp # sunshine
    sudo ufw allow 47998/udp # sunshine
    sudo ufw allow 47999/udp # sunshine
    sudo ufw allow 48000/udp # sunshine
    sudo ufw allow 48002/udp # sunshine
    sudo ufw allow 48010/udp # sunshine
end
