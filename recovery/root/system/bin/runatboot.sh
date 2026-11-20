#!/system/bin/sh

DEBUG=0
[ "$DEBUG" = "1" ] && set -o xtrace

LOGMSG() {
    echo "I:$@" >> /tmp/recovery.log
}

reset_touch() {
    if [ -d /sys/devices/platform/goodix_ts.0 ]; then
        LOGMSG "Resetting Goodix touchscreen post screen blank..."
        echo 1 > /sys/devices/platform/goodix_ts.0/irq_info
        echo 1 > /sys/devices/platform/goodix_ts.0/reset
    else
        LOGMSG "Goodix touchscreen sysfs not present; skipping reset..."
    fi
}

optimize_io_and_cpu() {
    LOGMSG "Applying I/O optimizations to block devices..."

    for disk in /sys/block/sd*; do
        if [ -d "$disk/queue" ]; then
            dev=$(basename "$disk")
            if grep -q "none" "$disk/queue/scheduler" 2>/dev/null; then
                echo none > "$disk/queue/scheduler" 2>/dev/null
            fi
            echo 2048 > "$disk/queue/read_ahead_kb" 2>/dev/null
            echo 512 > "$disk/queue/nr_requests" 2>/dev/null
            echo 0 > "$disk/queue/iostats" 2>/dev/null
            echo 0 > "$disk/queue/rotational" 2>/dev/null
            echo 0 > "$disk/queue/add_random" 2>/dev/null
            LOGMSG "Optimized physical device: $dev"
        fi
    done

    for dev in /sys/block/dm-* /sys/block/loop*; do
        if [ -d "$dev/queue" ]; then
            [ -w "$dev/queue/read_ahead_kb" ] && echo 2048 > "$dev/queue/read_ahead_kb" 2>/dev/null
            [ -w "$dev/queue/nr_requests" ] && echo 512 > "$dev/queue/nr_requests" 2>/dev/null
            [ -w "$dev/queue/iostats" ] && echo 0 > "$dev/queue/iostats" 2>/dev/null
        fi
    done

    LOGMSG "Setting CPU scaling governors to walt..."
    for gov in /sys/devices/system/cpu/cpufreq/policy*/scaling_governor; do
        [ -w "$gov" ] && echo walt > "$gov" 2>/dev/null
    done

    LOGMSG "I/O optimization complete."
}

SCRIPT_NAME="$(basename "$0")"

LOGMSG "---$SCRIPT_NAME start---"

reset_touch
optimize_io_and_cpu

/sbin/prune_historic_logs.sh 10

LOGMSG "---$SCRIPT_NAME end---"
exit 0
