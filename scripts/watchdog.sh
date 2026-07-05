#!/bin/bash

BASE="/opt/EMASESA/lafuentedepias"

source "$BASE/config/gateway.conf"
source "$BASE/config/modem.conf"

LOG="$BASE/logs/watchdog.log"

log() {
    echo "[$(date)] $1" | tee -a "$LOG"
}

get_wwan_iface() {
    if [ -e /sys/class/usbmisc/cdc-wdm0/device/net ]; then
        basename "$(readlink -f /sys/class/usbmisc/cdc-wdm0/device/net/*)" 2>/dev/null
    fi
}

restart_cloudflare() {
    log "Restarting cloudflared.service..."
    systemctl restart cloudflared.service || true
}

restart_nodered() {
    log "Restarting nodered.service..."
    systemctl restart nodered.service || true
}

recover_qmi() {
    log "Recovering QMI session..."
    "$BASE/modem/disconnect.sh" || true
    sleep 5
    "$BASE/modem/connect.sh" || true
}

recover_bg96() {
    log "Restarting BG96 service..."
    systemctl restart bg96.service || true
}

check_service() {
    local service="$1"

    if systemctl is-active --quiet "$service"; then
        log "$service OK"
    else
        log "$service FAILED. Restarting..."
        systemctl restart "$service" || true
    fi
}

log "===== WATCHDOG CHECK START ====="

WWAN_IFACE=$(get_wwan_iface)

if [ ! -e "$QMI_DEVICE" ]; then
    log "QMI device not found: $QMI_DEVICE"
    recover_bg96
    log "===== WATCHDOG CHECK END ====="
    exit 0
fi

if [ -z "$WWAN_IFACE" ]; then
    log "WWAN interface not found"
    recover_bg96
    log "===== WATCHDOG CHECK END ====="
    exit 0
fi

log "QMI device OK: $QMI_DEVICE"
log "WWAN interface OK: $WWAN_IFACE"

if ip -4 addr show "$WWAN_IFACE" | grep -q "inet "; then
    log "WWAN IP OK"
	#############################################################
	# DIAGNÓSTICO DE RED
	#############################################################

	log "----- Network diagnostics -----"

	log "Default routes:"
	ip route | while read line; do
	    log "  $line"
	done

	log "WWAN IPv4:"
	ip -4 addr show "$WWAN_IFACE" 2>/dev/null | while read line; do
	    log "  $line"
	done

	log "Ethernet IPv4:"
	ip -4 addr show enxb827ebc9ddf2 2>/dev/null | while read line; do
	    log "  $line"
	done

	log "DNS:"
	grep nameserver /etc/resolv.conf | while read line; do
	    log "  $line"
	done

	#############################################################
else
    log "WWAN has no IPv4. Recovering QMI..."
    recover_qmi
    log "===== WATCHDOG CHECK END ====="
    exit 0
fi
log "Testing Internet through interface $WWAN_IFACE..."
if ping -I "$WWAN_IFACE" -c 2 -W 3 "$PING_TARGET" >/dev/null 2>&1; then
    log "Internet via BG96 OK"
else
    log "Internet via BG96 FAILED. Recovering QMI..."
    recover_qmi

    sleep 10
    WWAN_IFACE=$(get_wwan_iface)

    if [ -n "$WWAN_IFACE" ] && ping -I "$WWAN_IFACE" -c 2 -W 3 "$PING_TARGET" >/dev/null 2>&1; then
        log "Internet recovered after QMI reconnect"
    else
        log "QMI reconnect failed. Restarting BG96 service..."
        recover_bg96
    fi
fi

check_service cloudflared.service
check_service nodered.service
check_service mosquitto.service
"$BASE/scripts/health_status.sh" >/dev/null 2>&1 || true

log "===== WATCHDOG CHECK END ====="
