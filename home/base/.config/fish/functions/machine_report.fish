#!/usr/bin/env fish
# SPDX-License-Identifier: BSD-3-Clause
#
# TR-101 Machine Report
# Copyright © 2024, U.S. Graphics, LLC. BSD-3-Clause License.
# Copyright © 2025, Dmitry Achkasov <achkasov.dmitry@live.com>.

set -g MIN_NAME_LEN 5
set -g MAX_NAME_LEN 10
set -g MIN_DATA_LEN 5
set -g BORDERS_AND_PADDING 7

set -g report_title "UNITED STATES GRAPHICS COMPANY"
set -g app_name "TR-101 MACHINE REPORT"
set -g last_login_ip_present 0
set -g zfs_present 0

if command -q zpool
    set -g zfs_filesystem (zpool list -H -o name | tail -n 1)
end

function debug
    # Uncomment for debug logging:
    # printf 'DEBUG: %s\n' "$argv"
end

function max_length
    set -l max_len $MIN_DATA_LEN
    for value in $argv
        set -l value_len (string length -- "$value")
        if test $value_len -gt $max_len
            set max_len $value_len
        end
    end

    printf '%s' $max_len
end

function set_current_len
    set -g CURRENT_LEN (max_length \
        "$os_name" \
        "$os_kernel" \
        "$net_hostname" \
        "$net_machine_ip" \
        "$net_client_ip" \
        "$cpu_model" \
        "$cpu_cores_per_socket vCPU(s) / $cpu_sockets Socket(s)" \
        "$cpu_hypervisor" \
        "$cpu_freq GHz" \
        "$cpu_1min_bar_graph" \
        "$cpu_5min_bar_graph" \
        "$cpu_15min_bar_graph" \
        "$zfs_used_gb/$zfs_available_gb GiB [$disk_percent%]" \
        "$disk_bar_graph" \
        "$zfs_health" \
        "$root_used_gb/$root_total_gb GiB [$disk_percent%]" \
        "$mem_used_gb/$mem_total_gb GiB [$mem_percent%]" \
        "$mem_bar_graph" \
        "$last_login_time" \
        "$last_login_ip" \
        "$sys_uptime")
end

function print_decorated_header
    set -l length (math "$CURRENT_LEN + $MAX_NAME_LEN + $BORDERS_AND_PADDING")
    set -l fill (string repeat -n (math "$length - 2") '┬')
    printf '┌%s┐\n' "$fill"
    printf '├%s┤\n' (string replace -a '┬' '┴' -- "$fill")
end

function print_header
    set -l length (math "$CURRENT_LEN + $MAX_NAME_LEN + $BORDERS_AND_PADDING")
    printf '┌%s┐\n' (string repeat -n (math "$length - 2") '─')
end

function print_centered_data
    set -l max_len (math "$CURRENT_LEN + $MAX_NAME_LEN - $BORDERS_AND_PADDING")
    set -l total_width (math "$max_len + 12")
    set -l text "$argv[1]"
    set -l text_len (string length -- "$text")
    set -l padding_left (math -s0 "($total_width - $text_len) / 2")
    set -l padding_right (math "$total_width - $text_len - $padding_left")
    printf '│%*s%s%*s│\n' $padding_left '' "$text" $padding_right ''
end

function print_divider
    set -l left_symbol '├'
    set -l middle_symbol '┼'
    set -l right_symbol '┤'

    switch "$argv[1]"
        case top
            set middle_symbol '┬'
        case bottom
            set middle_symbol '┴'
        case end
            set left_symbol '└'
            set middle_symbol '┴'
            set right_symbol '┘'
    end

    set -l length (math "$CURRENT_LEN + $MAX_NAME_LEN + $BORDERS_AND_PADDING")
    set -l name_width (math "$MAX_NAME_LEN + 2")
    # The POSIX implementation loops length - 3 times and inserts the middle
    # symbol in addition to those dashes.
    set -l data_width (math "$length - $name_width - 3")
    printf '%s%s%s%s%s\n' "$left_symbol" \
        (string repeat -n $name_width '─') "$middle_symbol" \
        (string repeat -n $data_width '─') "$right_symbol"
end

function format_name
    set -l name "$argv[1]"
    if test (string length -- "$name") -gt $MAX_NAME_LEN
        printf '%s…' (string sub -s 1 -l (math "$MAX_NAME_LEN - 1") -- "$name")
    else
        printf '%-*s' $MAX_NAME_LEN "$name"
    end
end

function print_data
    set -l name (format_name "$argv[1]")
    set -l data "$argv[2]"
    set data (printf '%-*s' $CURRENT_LEN "$data")
    printf '│ %s │ %s │\n' "$name" "$data"
end

function print_bar
    printf '│ %s │ %s │\n' (format_name "$argv[1]") "$argv[2]"
end

function print_footer
    set -l length (math "$CURRENT_LEN + $MAX_NAME_LEN + $BORDERS_AND_PADDING")
    printf '└%s┘\n' (string repeat -n (math "$length - 2") '─')
end

function bar_graph
    set -l used $argv[1]
    set -l total $argv[2]
    set -l percent 0
    if test "$total" != 0
        set percent (awk -v "used=$used" -v "total=$total" 'BEGIN { printf "%.2f", (used / total) * 100 }')
    end
    set -l blocks (awk -v "percent=$percent" -v "width=$CURRENT_LEN" 'BEGIN { printf "%d", (percent / 100) * width }')
    printf '%s' (string repeat -n $blocks '█')
    if test $blocks -lt $CURRENT_LEN
        printf '%s' (string repeat -n (math "$CURRENT_LEN - $blocks") '░')
    end
end

function get_ip_addr
    set -l ipv4_address
    set -l ipv6_address
    if command -q ifconfig
        set ipv4_address (ifconfig | awk '/^[a-z]/ {iface=$1} iface != "lo:" && iface != "lo0:" && iface !~ /^docker/ && /inet / && !found_ipv4 {found_ipv4=1; print $2}')
        if test -z "$ipv4_address"
            set ipv6_address (ifconfig | awk '/^[a-z]/ {iface=$1} iface != "lo:" && iface != "lo0:" && iface !~ /^docker/ && /inet6 / && !found_ipv6 {found_ipv6=1; print $2}')
        end
    else if command -q ip
        set ipv4_address (ip -o -4 addr show | awk '$2 != "lo" && $2 !~ /^docker/ {split($4, a, "/"); if (!found_ipv4++) print a[1]}')
        if test -z "$ipv4_address"
            set ipv6_address (ip -o -6 addr show | awk '$2 != "lo" && $2 !~ /^docker/ {split($4, a, "/"); if (!found_ipv6++) print a[1]}')
        end
    end

    if test -n "$ipv4_address"
        printf '%s' "$ipv4_address"
    else if test -n "$ipv6_address"
        printf '%s' "$ipv6_address"
    else
        printf 'No IP found'
    end
end

# Operating system information
set -g os_name '???'
if test -f /etc/os-release
    set -l os_release_name (grep '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
    set -l os_release_version (grep '^VERSION=' /etc/os-release | cut -d= -f2)
    set -l os_release_codename (grep '^VERSION_CODENAME=' /etc/os-release | cut -d= -f2)
    set -g os_name "$os_release_name $os_release_version $os_release_codename"
else
    set -g os_name (uname -s)
    if test "$os_name" = Darwin
        set -g os_name (sw_vers | grep 'ProductName:' | tr -d '\t' | cut -d: -f2)
    end
end
set -g os_kernel (begin; uname; uname -r; end | tr '\n' ' ' | string collect)

# Network information
set -g net_current_user (whoami)
if command -q hostname
    set -g net_hostname (hostname)
else
    set -g net_hostname (grep -w (uname -n) /etc/hosts | awk '{print $2}' | head -n 1)
end
if test -z "$net_hostname"
    set -g net_hostname 'Not Defined'
end
set -g net_machine_ip (get_ip_addr)
set -g net_client_ip (who am i | awk '{print $NF}' | tr -d '()')
if test -z "$net_client_ip"; or not string match -qr '^\(' -- (who am i | awk '{print $NF}')
    set -g net_client_ip 'Not connected'
end
set -g net_dns_ip (grep '^nameserver [0-9.]' /etc/resolv.conf | cut -d' ' -f2)

# CPU information
switch (uname)
    case SunOS
        set -g cpu_model (kstat -C -m cpu_info -i 0 -s brand | cut -f5 -d:)
        set -g cpu_cores_per_socket (psrinfo -tc)
        set -g cpu_sockets (psrinfo -p)
        set -g cpu_hypervisor
        if test (smbios -t SMB_TYPE_SYSTEM | grep Product | tr -d ' ' | cut -d: -f2) = VirtualMachine
            set -g cpu_hypervisor (smbios -t SMB_TYPE_BIOS | grep 'Version String' | cut -d: -f2 | sed 's/^[[:space:]]* //')
        end
        set -g cpu_cores (nproc --all)
    case Darwin
        set -g cpu_model (sysctl -n machdep.cpu.brand_string)
        set -g cpu_cores_per_socket (sysctl -n machdep.cpu.core_count)
        set -g cpu_sockets (sysctl -n hw.physicalcpu)
        set -g cpu_cores (sysctl -n hw.ncpu)
        set -g cpu_hypervisor
    case '*'
        for utility in lscpu nproc
            if not command -q $utility
                printf 'ERROR: %s utility is not found\n' $utility >&2
                exit 1
            end
        end
        set -g cpu_cores_per_socket (lscpu | grep 'Core(s) per socket' | cut -f2 -d: | awk '{$1=$1}1')
        set -g cpu_model (lscpu | grep 'Model name' | grep -v BIOS | cut -f2 -d: | awk '{print $1 " " $2 " " $3 " " $4}')
        set -g cpu_sockets (lscpu | grep 'Socket(s)' | cut -f2 -d: | awk '{$1=$1}1')
        set -g cpu_hypervisor (lscpu | grep 'Hypervisor vendor' | cut -f2 -d: | awk '{$1=$1}1')
        set -g cpu_cores (nproc --all)
end
if test -z "$cpu_hypervisor"
    set -g cpu_hypervisor 'Bare Metal'
end

switch (uname)
    case Linux
        set -g cpu_freq (grep 'cpu MHz' /proc/cpuinfo | cut -f2 -d: | awk 'NR==1 {printf "%.2f", $1 / 1000}')
    case Darwin
        set -g cpu_freq (sysctl -n hw.cpufrequency | awk 'NR==1 {printf "%.2f", $1 / 1000000000}')
    case FreeBSD
        set -g cpu_freq (sysctl -n dev.cpu.0.freq | awk 'NR==1 {printf "%.2f", $1 / 1000}')
    case SunOS
        set -g cpu_freq (kstat -C -m cpu_info -i 0 -s clock_MHz | cut -f5 -d: | awk 'NR==1 {printf "%.2f", $1 / 1000}')
    case '*'
        set -g cpu_freq '???'
end

if string match -qr '^(FreeBSD|Darwin)$' (uname)
    set -l load_label 'load averages: '
else
    set -l load_label 'load average: '
end
set -g load_avg_1min (uptime | awk -F "$load_label" '{print $2}' | cut -d, -f1 | tr -d ' ')
set -g load_avg_5min (uptime | awk -F "$load_label" '{print $2}' | cut -d, -f2 | tr -d ' ')
set -g load_avg_15min (uptime | awk -F "$load_label" '{print $2}' | cut -d, -f3 | tr -d ' ')

# Memory information (values are KiB)
switch (uname)
    case Linux
        set -g mem_total (grep MemTotal /proc/meminfo | awk '{print $2}')
        set -g mem_available (grep MemAvailable /proc/meminfo | awk '{print $2}')
    case FreeBSD
        set -g mem_total (math (sysctl -n hw.physmem)' / 1024')
        set -g mem_available (math '('(sysctl -n vm.stats.vm.v_free_count)' + '(sysctl -n vm.stats.vm.v_inactive_count)') * '(sysctl -n hw.pagesize)' / 1024')
    case Darwin
        set -g mem_total (math (sysctl -n hw.physmem)' / 1024')
        set -l pages_free (vm_stat | grep 'Pages free:' | tr -d ' .' | cut -d: -f2)
        set -g mem_available (math (sysctl -n hw.pagesize)' * '$pages_free' / 1024')
    case SunOS
        set -g mem_total (math (kstat -C -m unix -n system_pages -s physmem | cut -d: -f5)' * 4')
        set -g mem_available (math (kstat -C -m unix -n system_pages -s freemem | cut -d: -f5)' * 4')
end
set -g mem_used (math "$mem_total - $mem_available")
set -g mem_percent (awk -v "used=$mem_used" -v "total=$mem_total" 'BEGIN {printf "%.2f", (used / total) * 100}')
set -g mem_total_gb (awk -v "value=$mem_total" 'BEGIN {printf "%.2f", value / (1024 * 1024)}')
set -g mem_used_gb (awk -v "value=$mem_used" 'BEGIN {printf "%.2f", value / (1024 * 1024)}')

# Disk information
if command -q zfs; and test (zpool list -H | count) -gt 0
    set -g zfs_present 1
    if zpool status -x "$zfs_filesystem" | grep -q 'is healthy'
        set -g zfs_health 'HEALTH O.K.'
    end
    set -g zfs_available (zfs get -o value -Hp available "$zfs_filesystem")
    set -g zfs_used (zfs get -o value -Hp used "$zfs_filesystem")
    set -g zfs_available_gb (awk -v "value=$zfs_available" 'BEGIN {printf "%.2f", value / (1024*1024*1024)}')
    set -g zfs_used_gb (awk -v "value=$zfs_used" 'BEGIN {printf "%.2f", value / (1024*1024*1024)}')
    set -g disk_percent (awk -v "used=$zfs_used" -v "available=$zfs_available" 'BEGIN {printf "%.2f", (used / available) * 100}')
else
    set -g root_used (df -m / | awk 'NR==2 {print $3}')
    set -g root_total (df -m / | awk 'NR==2 {print $2}')
    set -g root_total_gb (awk -v "total=$root_total" 'BEGIN {printf "%.2f", total / 1024}')
    set -g root_used_gb (awk -v "used=$root_used" 'BEGIN {printf "%.2f", used / 1024}')
    set -g disk_percent (awk -v "used=$root_used" -v "total=$root_total" 'BEGIN {printf "%.2f", (used / total) * 100}')
end

# Last login and uptime
set -g last_login_time 'Never logged in'
set -g last_login_ip
set -l login_user (whoami)
if command -q lastlog
    set -l last_login (lastlog -u "$login_user" | string collect)
    set -g last_login_ip (printf '%s\n' "$last_login" | awk 'NR==2 {print $3}' | sed -n '/^[0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}$/p')
    if test -n "$last_login_ip"
        set -g last_login_ip_present 1
        set -g last_login_time (printf '%s\n' "$last_login" | awk 'NR==2 {print $6, $7, $10, $8}')
    end
else if test (uname) = FreeBSD
    set -g last_login_ip (lastlogin --libxo json,pretty "$login_user" | awk -F'"' '/"from"/ {print $4}')
    set -g last_login_time (lastlogin --libxo json,pretty "$login_user" | awk -F'"' '/"login-time"/ {print $4}')
    if test -n "$last_login_ip"
        set -g last_login_ip_present 1
    end
else
    set -l last_login (last "$login_user" | head -n 1)
    set -g last_login_ip (printf '%s\n' "$last_login" | awk '{print $3}')
    if printf '%s\n' "$last_login_ip" | awk -F. 'NF==4 && $1<=255 && $2<=255 && $3<=255 && $4<=255' >/dev/null 2>&1
        set -g last_login_ip_present 1
        set -g last_login_time (printf '%s\n' "$last_login" | awk '{print $4, $5, $6, $7}')
    else
        set -g last_login_time (printf '%s\n' "$last_login" | awk '{print $3, $4, $5, $6}')
    end
end
set -g sys_uptime (uptime | cut -d, -f1 | sed 's/^[^ ]* //; s/^[^ ]* //; s/^[ ]* //; s/up[ ][[:space:]]*//; s/[[:space:]]*day\(s*\)/d/; s/[[:space:]]*hour\(s*\)/h/; s/[[:space:]]*minute\(s*\)/m/')

set_current_len
set -g cpu_1min_bar_graph (bar_graph "$load_avg_1min" "$cpu_cores")
set -g cpu_5min_bar_graph (bar_graph "$load_avg_5min" "$cpu_cores")
set -g cpu_15min_bar_graph (bar_graph "$load_avg_15min" "$cpu_cores")
set -g mem_bar_graph (bar_graph "$mem_used" "$mem_total")
if test $zfs_present -eq 1
    set -g disk_bar_graph (bar_graph "$zfs_used" "$zfs_available")
else
    set -g disk_bar_graph (bar_graph "$root_used" "$root_total")
end

print_decorated_header
print_centered_data "$report_title"
print_centered_data "$app_name"
print_divider top
print_data OS "$os_name"
print_data KERNEL "$os_kernel"
print_divider
print_data HOSTNAME "$net_hostname"
print_data 'MACHINE IP' "$net_machine_ip"
print_data 'CLIENT  IP' "$net_client_ip"
# set -l dns_num 0
# for dns_ip in $net_dns_ip
#     set dns_num (math "$dns_num + 1")
#     print_data "DNS  IP $dns_num" "$dns_ip"
# end
# print_data USER "$net_current_user"
print_divider
print_data PROCESSOR "$cpu_model"
print_data CORES "$cpu_cores_per_socket vCPU(s) / $cpu_sockets Socket(s)"
print_data HYPERVISOR "$cpu_hypervisor"
print_data 'CPU FREQ' "$cpu_freq GHz"
print_bar 'LOAD  1m' "$cpu_1min_bar_graph"
print_bar 'LOAD  5m' "$cpu_5min_bar_graph"
print_bar 'LOAD 15m' "$cpu_15min_bar_graph"
print_divider
if test $zfs_present -eq 1
    print_data VOLUME "$zfs_used_gb/$zfs_available_gb GiB [$disk_percent%]"
    print_bar 'DISK USAGE' "$disk_bar_graph"
    print_data 'ZFS HEALTH' "$zfs_health"
else
    print_data VOLUME "$root_used_gb/$root_total_gb GiB [$disk_percent%]"
    print_bar 'DISK USAGE' "$disk_bar_graph"
end
print_divider
print_data MEMORY "$mem_used_gb/$mem_total_gb GiB [$mem_percent%]"
print_bar USAGE "$mem_bar_graph"
print_divider
print_data 'LAST LOGIN' "$last_login_time"
if test $last_login_ip_present -eq 1
    print_data '' "$last_login_ip"
end
print_data UPTIME "$sys_uptime"
print_divider end
