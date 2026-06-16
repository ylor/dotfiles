#!/usr/bin/env fish
# SPDX-License-Identified: BSD-3-Clause
#
# TR-102 Machine Report
# Copyright © 2024, U.S. Graphics, LLC. BSD-3-Clause License.
# Copyright © 2025, Dmitry Achkasov <achkasov.dmitry@live.com>.

function usgc

    # ─── Config ──────────────────────────────────────────────────────────────────

    set -g MIN_NAME_LEN 5
    set -g MAX_NAME_LEN 8
    set -g MIN_DATA_LEN 5
    set -g MAX_DATA_LEN 32
    set -g CURRENT_LEN 28
    set -g BORDERS_AND_PADDING 7

    # Basic configuration, change as needed
    set -g report_title "TR-100"
    set -g app_name "MACHINE REPORT"
    set -g last_login_ip_present 0
    set -g zfs_present 0
    # set -g zfs_filesystem "zroot/ROOT/os"
    if command -v zpool >/dev/null 2>&1
        set -g zfs_filesystem (zpool list -H -o name | tail -n 1)
    end

    # ─── Utilities ───────────────────────────────────────────────────────────────

    function debug
        # Uncomment for debug logging
        # printf "DEBUG: %s\n" $argv
        printf ""
    end

    function max_length
        set max_len $MIN_DATA_LEN
        set len 0

        for str in $argv
            set len (string length -- $str)
            if test $len -gt $max_len
                set max_len $len
            end
        end

        if test $max_len -lt $MAX_DATA_LEN
            printf '%s' $max_len
        else
            printf '%s' $MAX_DATA_LEN
        end
    end

    function bar_graph
        set used $argv[1]
        set total $argv[2]
        set width $CURRENT_LEN
        set graph ""

        set percent 0
        if test $total -eq 0
            set percent 0
        else
            set percent (awk -v used=$used -v total=$total 'BEGIN { printf "%.0f", (used / total) * 100 }')
        end

        set num_blocks (awk -v percent=$percent -v width=$width 'BEGIN { printf "%d", (percent / 100) * width }')

        set i 0
        while test $i -lt $num_blocks
            set graph $graph"█"
            set i (math $i + 1)
        end

        while test $i -lt $width
            set graph $graph"▒"
            set i (math $i + 1)
        end

        printf "%s" $graph
    end

    function get_ip_addr
        # Initialize variables
        set ipv4_address ""
        set ipv6_address ""

        # Check if ifconfig command exists
        if command -v ifconfig >/dev/null 2>&1
            # Try to get IPv4 address using ifconfig
            set ipv4_address (ifconfig | awk '
            /^[a-z]/ {iface=$1}
            iface != "lo:" && iface !="lo0:" && iface !~ /^docker/ && /inet / && !found_ipv4 {found_ipv4=1; print $2}')

            # If IPv4 address not available, try IPv6 using ifconfig
            if test -z "$ipv4_address"
                set ipv6_address (ifconfig | awk '
                /^[a-z]/ {iface=$1}
                iface != "lo:" && iface != "lo0:" && iface !~ /^docker/ && /inet6 / && !found_ipv6 {found_ipv6=1; print $2}')
            end
        else if command -v ip >/dev/null 2>&1
            # Try to get IPv4 address using ip addr
            set ipv4_address (ip -o -4 addr show | awk '
            $2 != "lo" && $2 !~ /^docker/ {split($4, a, "/"); if (!found_ipv4++) print a[1]}')

            # If IPv4 address not available, try IPv6 using ip addr
            if test -z "$ipv4_address"
                set ipv6_address (ip -o -6 addr show | awk '
                $2 != "lo" && $2 !~ /^docker/ {split($4, a, "/"); if (!found_ipv6++) print a[1]}')
            end
        end

        # If neither IPv4 nor IPv6 address is available, assign "No IP found"
        set ip_address ""
        if test -z "$ipv4_address"; and test -z "$ipv6_address"
            set ip_address "No IP found"
        else if test -n "$ipv4_address"
            # Prioritize IPv4 if available, otherwise use IPv6
            set ip_address $ipv4_address
        else
            set ip_address $ipv6_address
        end

        printf '%s' $ip_address
    end

    # ─── Display helpers ─────────────────────────────────────────────────────────

    # Build a horizontal border line spanning the full report width.
    # Args: left-corner fill-char right-corner
    function border_line
        set left $argv[1]
        set fill $argv[2]
        set right $argv[3]
        set length (math $CURRENT_LEN + $MAX_NAME_LEN + $BORDERS_AND_PADDING)
        set line $left
        set i 0
        while test $i -lt (math $length - 2)
            set line $line$fill
            set i (math $i + 1)
        end
        printf '%s%s\n' $line $right
    end

    # Pad/truncate a row name to the name column width.
    function pad_name
        set name $argv[1]
        set name_len (string length -- $name)
        if test $name_len -lt $MIN_NAME_LEN
            set name (printf "%-"$MIN_NAME_LEN"s" $name)
        else if test $name_len -gt $MAX_NAME_LEN
            set cut_end (math $MAX_NAME_LEN - 1)
            set name (echo $name | cut -c 1-$cut_end)…
        else
            set name (printf "%-"$MAX_NAME_LEN"s" $name)
        end
        printf '%s' $name
    end


    function PRINT_DECORATED_HEADER
        border_line "┌" "┬" "┐"
        border_line "├" "┴" "┤"
    end

    function PRINT_HEADER
        border_line "┌" "─" "┐"
    end

    function PRINT_CENTERED_DATA
        set max_len (math $CURRENT_LEN + $MAX_NAME_LEN - $BORDERS_AND_PADDING)
        set text $argv[1]
        set total_width (math $max_len + 12)

        set text_len (string length -- $text)
        set padding_left (math -s 0 "($total_width - $text_len) / 2")
        set padding_right (math $total_width - $text_len - $padding_left)

        printf "│%"$padding_left"s%s%"$padding_right"s│\n" "" $text ""
    end

    function PRINT_DIVIDER
        # either "top" or "bottom", no argument means middle divider
        # Initialize with middle-divider defaults
        set left_symbol "├"
        set middle_symbol "┼"
        set right_symbol "┤"

        switch $argv[1]
            case top
                set middle_symbol "┬"
            case bottom
                set middle_symbol "┴"
            case end
                set left_symbol "└"
                set middle_symbol "┴"
                set right_symbol "┘"
        end

        set length (math $CURRENT_LEN + $MAX_NAME_LEN + $BORDERS_AND_PADDING)
        set divider $left_symbol
        set i 0
        while test $i -lt (math $length - 3)
            set divider $divider"─"
            if test $i -eq (math $MAX_NAME_LEN + 1)
                set divider $divider$middle_symbol
            end
            set i (math $i + 1)
        end
        set divider $divider$right_symbol
        printf '%s\n' $divider
    end

    function PRINT_DATA
        set name (pad_name $argv[1])
        set data $argv[2]
        set max_data_len $CURRENT_LEN

        # Truncate or pad data
        set data_len (string length -- $data)
        if test $data_len -gt $MAX_DATA_LEN; or test $data_len -eq (math $MAX_DATA_LEN - 1)
            set cut_end (math $MAX_DATA_LEN - 1)
            set data (echo $data | cut -c 1-$cut_end)…
        else
            # TODO: stupid Debian `dash` cannot into UTF-8 and might trim strings earlier
            set data (printf "%-"$max_data_len"s" $data)
        end

        printf "│ %-"$MAX_NAME_LEN"s │ %s │\n" $name $data
    end

    function PRINT_BAR
        set name (pad_name $argv[1])
        set data $argv[2]

        printf "│ %-"$MAX_NAME_LEN"s │ %s │\n" $name $data
    end

    function PRINT_FOOTER
        border_line "└" "─" "┘"
    end

    # ─── Data collection ─────────────────────────────────────────────────────────

    debug "COLLECTING OS INFO"
    # Operating System Information
    set -g os_name "???"
    if test -f /etc/os-release
        set NAME (grep "^NAME=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
        debug "OS: $NAME"
        set VERSION (grep "^VERSION=" /etc/os-release | cut -d'=' -f2)
        set VERSION_CODENAME (grep "^VERSION_CODENAME=" /etc/os-release | cut -d'=' -f2)
        set -g os_name "$NAME $VERSION $VERSION_CODENAME"
    else
        set -g os_name (uname -s)
        switch $os_name
            case Darwin
                set -g os_name "$(sw_vers --productName) $(sw_vers -productVersion)"
        end
    end

    set -g os_kernel "$(uname) $(uname -r)-$(uname -m)"
    if test (uname) = Darwin
        set -g os_kernel "$(uname) $(uname -r)"
    end

    debug "COLLECTING NET INFO"
    # Network Information
    set -g net_current_user (whoami)
    if not command -v hostname >/dev/null 2>&1
        set -g net_hostname (grep -w (uname -n) /etc/hosts | awk '{print $2}' | head -n 1)
    else
        set -g net_hostname (hostname)
    end

    if test -z "$net_hostname"
        set -g net_hostname "Not Defined"
    end

    set -g net_machine_ip (get_ip_addr)
    set -g net_client_ip (who am i | awk '{print $NF}')
    if test -z "$net_client_ip"
        set -g net_client_ip "Not connected"
    end

    switch $net_client_ip
        case '(*'
            # keep as-is
        case '*'
            set -g net_client_ip "Not connected"
    end
    set -g net_client_ip (echo $net_client_ip | tr -d '()')

    # Store as a Fish list - each nameserver becomes one element
    set -g net_dns_ip (grep '^nameserver [0-9.]' /etc/resolv.conf | cut -d' ' -f2)

    debug "COLLECTING CPU INFO"
    # CPU Information

    switch (uname)
        case Darwin
            set -g cpu_model (sysctl -n machdep.cpu.brand_string)
            set -g cpu_cores_per_socket (sysctl -n machdep.cpu.core_count)
            set -g cpu_sockets (sysctl -n hw.physicalcpu)
            set -g cpu_cores (sysctl -n hw.ncpu)
        case '*'
            if not command -v lscpu >/dev/null 2>&1
                printf "ERROR: `lscpu` utility is not found"
                exit 1
            end
            if not command -v nproc >/dev/null 2>&1
                printf "ERROR: `nproc` utility is not found"
                exit 1
            end

            set -g cpu_cores_per_socket (lscpu | grep 'Core(s) per socket' | cut -f 2 -d ':' | awk '{$1=$1}1')
            set -g cpu_model (lscpu | grep 'Model name' | grep -v 'BIOS' | cut -f 2 -d ':' | awk '{print $1 " " $2 " " $3 " " $4}')
            set -g cpu_sockets (lscpu | grep 'Socket(s)' | cut -f 2 -d ':' | awk '{$1=$1}1')
            set -g cpu_hypervisor (lscpu | grep 'Hypervisor vendor' | cut -f 2 -d ':' | awk '{$1=$1}1')
            set -g cpu_cores (nproc --all)
    end

    if test -z "$cpu_hypervisor"
        set -g cpu_hypervisor "Bare Metal"
    end

    switch (uname)
        case Linux
            set -g cpu_freq (grep 'cpu MHz' /proc/cpuinfo | cut -f 2 -d ':' | awk 'NR==1 { printf "%.0f", $1 / 1000 }') # Convert from M to G units
        case Darwin
            set -g cpu_freq (sysctl -n hw.cpufrequency | awk 'NR==1 { printf "%.0f", $1 / 1000000000 }') # Convert from Hz to GHz units
            # case FreeBSD
            #     set -g cpu_freq (sysctl -n dev.cpu.0.freq | awk 'NR==1 { printf "%.0f", $1 / 1000 }') # Convert from M to G units
        case '*'
            set -g cpu_freq "???"
    end

    # Linux, FreeBSD use "load average:" / "load averages:"
    # MacOS/FreeBSD: "load averages:"
    set -g _load_avgs (uptime | awk -F'load averages?: ' '{split($2, a, /[, ]+/); print a[1]; print a[2]; print a[3]}')
    set -g load_avg_1min $_load_avgs[1]
    set -g load_avg_5min $_load_avgs[2]
    set -g load_avg_15min $_load_avgs[3]

    debug "COLLECTING MEMORY INFO"
    # Memory Information
    switch (uname)
        case Darwin
            set physmem (sysctl -n hw.memsize)
            set -g mem_total (math -s 0 "$physmem / 1024")
            set pagesize (sysctl -n hw.pagesize)
            set pages_free (vm_stat | grep "Pages free:" | tr -d " ." | cut -d ":" -f 2)
            set pages_inactive (vm_stat | grep "Pages inactive:" | tr -d " ." | cut -d ":" -f 2)
            set pages_speculative (vm_stat | grep "Pages speculative:" | tr -d " ." | cut -d ":" -f 2)
            set pages_purgeable (vm_stat | grep "File-backed pages:" | tr -d " ." | cut -d ":" -f 2)
            set -g mem_available (math -s 0 "$pagesize * ($pages_free + $pages_inactive + $pages_speculative + $pages_purgeable) / 1024")
        case Linux
            set -g mem_total (grep 'MemTotal' /proc/meminfo | awk '{print $2}')
            set -g mem_available (grep 'MemAvailable' /proc/meminfo | awk '{print $2}')
        case '*'
            set -g mem_total "???"
            set -g mem_available "???"
    end

    set -g mem_used (math $mem_total - $mem_available)

    set -g mem_percent (awk -v used=$mem_used -v total=$mem_total 'BEGIN { printf "%.0f", (used / total) * 100 }')
    set -g mem_percent (printf "%.0f" $mem_percent)
    set -g mem_total_gb (echo $mem_total | awk '{ printf "%.0f", $1 / (1024 * 1024) }') # (From Ki to Gi units)
    # set -g mem_available_gb (echo $mem_available | awk '{ printf "%.0f", $1 / (1024 * 1024) }') # (From Ki to Gi units) Not used currently
    set -g mem_used_gb (echo $mem_used | awk '{ printf "%.0f", $1 / (1024 * 1024) }')

    debug "COLLECTING DISK INFO"
    # Disk Information
    if command -v zfs >/dev/null 2>&1; and test (zpool list -H | wc -l | string trim) -gt 0
        set -g zfs_present 1
        if zpool status -x $zfs_filesystem | grep -q "is healthy"
            set -g zfs_health "HEALTH O.K."
        else
            set -g zfs_health ""
        end
        set -g zfs_available (zfs get -o value -Hp available $zfs_filesystem)
        set -g zfs_used (zfs get -o value -Hp used $zfs_filesystem)
        set -g zfs_available_gb (echo $zfs_available | awk '{ printf "%.0f", $1 / (1024 * 1024 * 1024) }') # (To G units)
        set -g zfs_used_gb (echo $zfs_used | awk '{ printf "%.0f", $1 / (1024 * 1024 * 1024) }') # (To G units)
        set -g disk_percent (awk -v used=$zfs_used -v available=$zfs_available 'BEGIN { printf "%.0f", (used / available) * 100 }')
    else if test (uname) = Darwin
        set root_partition /System/Volumes/Data
        set -g df_output (df -Pm $root_partition | awk 'NR==2')
        set -g root_used (echo $df_output | awk '{print $3}')
        set -g root_total (echo $df_output | awk '{print $2}')
        set -g root_total_gb (awk -v total=$root_total 'BEGIN { printf "%.0f", total / 1024 }')
        set -g root_used_gb (awk -v used=$root_used   'BEGIN { printf "%.0f", used  / 1024 }')
        set -g disk_percent (awk -v used=$root_used -v total=$root_total 'BEGIN { printf "%.0f", (used / total) * 100 }')
    else
        # Thanks https://github.com/AnarchistHoneybun
        set root_partition /
        set -g df_output (df -Pm $root_partition | awk 'NR==2')
        set -g root_used (echo $df_output | awk '{print $3}')
        set -g root_total (echo $df_output | awk '{print $2}')
        set -g root_total_gb (awk -v total=$root_total 'BEGIN { printf "%.0f", total / 1024 }')
        set -g root_used_gb (awk -v used=$root_used   'BEGIN { printf "%.0f", used  / 1024 }')
        set -g disk_percent (awk -v used=$root_used -v total=$root_total 'BEGIN { printf "%.0f", (used / total) * 100 }')
    end

    debug "COLLECTING LOGIN INFO"
    # Last login and Uptime
    set -g last_login_time "Never logged in"
    if command -v lastlog >/dev/null 2>&1
        # string collect preserves newlines so awk NR== works correctly
        set last_login (lastlog -u $USER | string collect)
        set -g last_login_ip (printf '%s' $last_login | awk 'NR==2 {print $3}')
        set -g last_login_ip (printf '%s' $last_login_ip | sed -n '/^[0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}$/p')

        if test -z "$last_login_ip"
            set -g last_login_ip_present 0
            debug "COLLECTING LOGIN IP: NOT PRESENT: $last_login_ip_present"
        else
            if printf '%s' $last_login_ip | awk -F. 'NF==4 && $1<=255 && $2<=255 && $3<=255 && $4<=255' >/dev/null 2>&1
                set -g last_login_ip_present 1
                set -g last_login_time (printf '%s' $last_login | awk 'NR==2 {print $6, $7, $10, $8}')
                debug "COLLECTING LOGIN IP: IDENTIFIED: $last_login_ip_present, $last_login_time"
            else
                set -g last_login_time (printf '%s' $last_login | awk 'NR==2 {print $4, $5, $8, $6}')
                debug "COLLECTING LOGIN IP: IDENTIFIED: $last_login_ip_present, $last_login_time"
            end
        end
    else
        debug "COLLECTING LOGIN INFO - NO LASTLOG"
        # switch (uname)
        #     case FreeBSD
        #         set -g last_login_ip (lastlogin --libxo json,pretty $USER | awk -F'"' '/"from"/ {print $4}')
        #         if test -n "$last_login_ip"
        #             set -g last_login_ip_present 1
        #         end
        #         set -g last_login_time (lastlogin --libxo json,pretty $USER | awk -F '"' '/"login-time"/ {print $4}')
        #         debug "COLLECTING LOGIN INFO - LASTLOGIN: $last_login_time"
        #     case '*'
        set fields (last $USER | head -n 1 | awk '{for(i=1;i<=NF;i++) print $i}')
        set f3 $fields[3]

        debug "COLLECTING LOGIN INFO - LAST: $fields, $f3"

        if string match -qr '^\d+\.\d+\.\d+\.\d+$' -- $f3
            set -g last_login_ip $f3
            set -g last_login_ip_present 1
            set -g last_login_time "$fields[4] $fields[5] $fields[6] $fields[7]"
        else
            set -g last_login_time "$fields[3] $fields[4] $fields[5] $fields[6]"
        end

        debug "COLLECTING LOGIN IP: IDENTIFIED: $last_login_ip_present, $last_login_time"
        # end
    end

    # sys_uptime=$(uptime | cut -d',' -f1 | sed 's/^[^ ]* //; s/up\s*//; s/\s*day\(s*\)/d/; s/\s*hour\(s*\)/h/; s/\s*minute\(s*\)/m/')
    # set -g sys_uptime (uptime | cut -d',' -f1 \
    #     | sed 's/^[^ ]* //' \
    #     | sed 's/^[^ ]* //' \
    #     | sed 's/^[ ]* //' \
    #     | sed "s/up[ ][[:space:]]*//" \
    #     # | sed 's/[[:space:]]*day\(s*\)/d/' \
    #     # | sed 's/[[:space:]]*hour\(s*\)/h/' \
    #     # | sed 's/[[:space:]]*minute\(s*\)/m/'
    # )
    set -g sys_uptime (uptime | awk '{print $3, $4}' | tr -d ',')

    # ─── Graphs + width ──────────────────────────────────────────────────────────

    debug "PREPARING GRAPHS"
    # Set current length before graphs get calculated

    debug "PREPARING GRAPHS - CPU"
    # Create graphs
    debug "PREPARING GRAPHS - CPU 1 MIN LOAD: $load_avg_1min, $cpu_cores"
    set -g cpu_1min_bar_graph (bar_graph $load_avg_1min $cpu_cores)
    debug "PREPARING GRAPHS - CPU 5 MIN LOAD"
    set -g cpu_5min_bar_graph (bar_graph $load_avg_5min $cpu_cores)
    debug "PREPARING GRAPHS - CPU 15 MIN LOAD"
    set -g cpu_15min_bar_graph (bar_graph $load_avg_15min $cpu_cores)

    debug "PREPARING GRAPHS - MEMORY"
    set -g mem_bar_graph (bar_graph $mem_used $mem_total)

    debug "PREPARING GRAPHS - DISK"
    if test $zfs_present -eq 1
        debug "PREPARING GRAPHS - DISK ZFS: $zfs_used"
        set -g disk_bar_graph (bar_graph $zfs_used $zfs_available)
    else
        debug "PREPARING GRAPHS - DISK REGULAR"
        set -g disk_bar_graph (bar_graph $root_used $root_total)
    end

    # ─── Report ──────────────────────────────────────────────────────────────────

    # Machine Report
    # PRINT_HEADER
    PRINT_DECORATED_HEADER
    # PRINT_HEADER
    # PRINT_CENTERED_DATA $barcode_header
    # PRINT_CENTERED_DATA $report_title
    PRINT_CENTERED_DATA "MACHINE REPORT"
    # PRINT_CENTERED_DATA $net_current_user
    # PRINT_CENTERED_DATA $net_hostname
    PRINT_CENTERED_DATA $(echo "$net_current_user @ $net_hostname" | string upper)
    PRINT_DIVIDER top
    # PRINT_DATA USER $net_current_user
    test (uname -s) = Darwin && PRINT_DATA OS $os_name || PRINT_DATA DISTRO $os_name
    PRINT_DATA KERNEL $os_kernel
    # PRINT_DIVIDER
    # PRINT_DATA MACHINE $net_hostname
    PRINT_DIVIDER
    PRINT_DATA HOST "MacBook Pro"
    PRINT_DATA CPU $cpu_model
    PRINT_DATA CORES "$cpu_cores_per_socket"
    # PRINT_DATA "SESSION" (set -q SSH_TTY && $net_client_ip || echo "Local")
    PRINT_DATA "IP" $net_machine_ip
    PRINT_DATA "DNS" (string join ", " $net_dns_ip)
    PRINT_DIVIDER
    PRINT_DATA UPTIME $sys_uptime
    PRINT_BAR "LOAD  1m" $cpu_1min_bar_graph
    PRINT_BAR "LOAD  5m" $cpu_5min_bar_graph
    PRINT_BAR "LOAD 15m" $cpu_15min_bar_graph
    set -q SSH_TTY && PRINT_DATA "LAST LOGIN" $last_login_time

    PRINT_DIVIDER
    if test $zfs_present -eq 1
        PRINT_DATA VOLUME "$zfs_used_gb / $zfs_available_gb GB [$disk_percent%]"
        PRINT_BAR "DISK USAGE" $disk_bar_graph
        PRINT_DATA "ZFS HEALTH" $zfs_health
    else
        PRINT_DATA "DISK" "$root_used_gb/$root_total_gb GB [$disk_percent%]"
        PRINT_BAR "USAGE" $disk_bar_graph
    end
    PRINT_DIVIDER
    PRINT_DATA MEMORY "$mem_used_gb/$mem_total_gb GB [$mem_percent%]"
    PRINT_BAR USAGE $mem_bar_graph
    PRINT_DIVIDER end

    if test $last_login_ip_present -eq 1
        set -q SSH_TTY && PRINT_DATA "" $last_login_ip
    end

end
