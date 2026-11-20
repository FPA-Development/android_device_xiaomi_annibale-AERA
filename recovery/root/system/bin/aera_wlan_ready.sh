#!/system/bin/sh
# Bring up SM8750 CNSS2 (kiwi_v2 / peach_v2) WLAN interface for AERA Recovery.

PATH=/system/bin:/sbin:/vendor/bin
export PATH
LOG=/tmp/aera_wlan_ready.log

log() {
    echo "[aera-wlan] uptime=$(cut -d ' ' -f 1 /proc/uptime) $*" >> "$LOG"
    echo "[aera-wlan] $*" > /dev/kmsg 2>/dev/null || true
}

prop() { getprop "$1" 2>/dev/null; }

loaded() {
    if [ "$1" = "qca_cld3_kiwi_v2" ] || [ "$1" = "qca_cld3_peach_v2" ]; then
        grep -Eq "^($1|wlan) " /proc/modules 2>/dev/null || [ -d "/sys/module/$1" ]
    else
        grep -q "^$1 " /proc/modules 2>/dev/null || [ -d "/sys/module/$1" ]
    fi
}

try_insmod() {
    mod="$1"
    loaded "$mod" && return 0
    for dir in \
        /tmp/vendor_dlkm/lib/modules \
        /vendor_dlkm/lib/modules \
        /tmp/vendor/lib/modules \
        /vendor/lib/modules \
        /lib/modules; do
        if [ -f "$dir/$mod.ko" ]; then
            if insmod "$dir/$mod.ko" 2>> "$LOG"; then
                log "Loaded module $mod from $dir"
                return 0
            else
                log "insmod failed for $dir/$mod.ko"
            fi
        fi
    done
    return 1
}

if [ -e /sys/class/net/wlan0 ]; then
    log "wlan0 already present"
    [ "$(prop wifi.driver.ready)" = "true" ] || setprop wifi.driver.ready true
    exit 0
fi

if [ "$(prop ro.aera.fastbootd)" = "1" ] || [ "$(prop ro.aera.fastbootd)" = "true" ] || \
   [ "$(prop sys.usb.config.aera_fastbootd)" = "1" ]; then
    log "fastbootd active; skipping WLAN bring-up"
    exit 0
fi

log "Starting SM8750 WLAN bring-up (post.decrypt.modules=$(prop post.decrypt.modules))"

# Ensure modem firmware subdirectories (e.g. kiwi_v2/) are linked into /vendor/firmware_mnt/image
if [ -d /firmware/image ]; then
    mkdir -p /vendor/firmware_mnt/image
    for entry in /firmware/image/*; do
        [ -e "$entry" ] || continue
        target="/vendor/firmware_mnt/image/${entry##*/}"
        [ -e "$target" ] || ln -s "$entry" "$target" 2>/dev/null || true
    done
fi

# Ensure rfkill is loaded (may live in system_dlkm on GKI 6.6)
/system/bin/aera_load_rfkill.sh >> "$LOG" 2>&1 || log "rfkill helper returned non-zero (may be built-in)"

# Ensure CNSS2 + WLAN modules are loaded in dependency order
for mod in \
    smem-mailbox \
    cnss_prealloc \
    cnss_utils \
    cnss_nl \
    wlan_firmware_service \
    cnss_plat_ipc_qmi_svc \
    cnss2 \
    gsim \
    rmnet_mem \
    ipam \
    cfg80211 \
    qca_cld3_kiwi_v2 \
    qca_cld3_peach_v2; do
    try_insmod "$mod" || true
done

# Signal fs_ready to CNSS2 platform driver (kiwi on annibale, peach fallback)
for node in \
    /sys/devices/platform/soc/b0000000.qcom,cnss-kiwi/fs_ready \
    /sys/bus/platform/drivers/cnss2/b0000000.qcom,cnss-kiwi/fs_ready \
    /sys/devices/platform/soc/b0000000.qcom,cnss-peach/fs_ready \
    /sys/bus/platform/drivers/cnss2/b0000000.qcom,cnss-peach/fs_ready; do
    if [ -e "$node" ]; then
        chmod 0222 "$node" 2>/dev/null || true
        echo 1 > "$node" 2>> "$LOG" && log "Signaled fs_ready on $node"
    fi
done

# Wait up to 60 seconds for wlan0
n=0
while [ "$n" -lt 60 ] && [ ! -e /sys/class/net/wlan0 ]; do
    sleep 1
    n=$((n + 1))
done

if [ -e /sys/class/net/wlan0 ]; then
    log "wlan0 ready after ${n}s"
    setprop wifi.driver.ready true
    exit 0
fi

log "wlan0 did not appear after 60s"
exit 1
