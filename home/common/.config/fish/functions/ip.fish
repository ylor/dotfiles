function ip --description 'Show local IP, and optionally WAN IP'
    set -l addr
    if test (uname) = Darwin
        set -l iface (route get default | string match -r 'interface: (\S+)' -g)
        set addr (ipconfig getifaddr $iface)
    else
        set -l iface (ip route get 1.1.1.1 | string match -r 'dev (\S+)' -g)
        set addr (ip -4 addr show $iface | string match -r 'inet (\S+)/' -g)
    end
    if test (count $argv) -gt 0
        echo "LAN: $addr"
        echo "WAN: "(curl -s ifconfig.me)
    else
        echo $addr
    end
end
