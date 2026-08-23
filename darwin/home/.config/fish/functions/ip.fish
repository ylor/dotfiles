function ip --description 'Show local IP, and optionally WAN IP'
    set addr
    set iface (route get default | string match -r 'interface: (\S+)' -g)
    set addr (ipconfig getifaddr $iface)
    if test (count $argv) -gt 0
        echo "LAN: $addr"
        echo "WAN: "(curl -s ifconfig.me)
    else
        echo $addr
    end
end
