#!/bin/bash
set -e

source /opt/EMASESA/lafuentedepias/config/gateway.conf
source /opt/EMASESA/lafuentedepias/config/modem.conf

LOG="/opt/EMASESA/lafuentedepias/logs/modem.log"

echo "[$(date)] Disconnecting modem..." | tee -a "$LOG"

if [ -e /sys/class/usbmisc/cdc-wdm0/device/net ]; then
    WWAN_IFACE=$(basename "$(readlink -f /sys/class/usbmisc/cdc-wdm0/device/net/*)" 2>/dev/null)
else
    WWAN_IFACE=""
fi

sudo qmi-network "$QMI_DEVICE" stop || true

if [ -n "$WWAN_IFACE" ]; then
    sudo ip link set "$WWAN_IFACE" down || true
    echo "[$(date)] WWAN interface down: $WWAN_IFACE" | tee -a "$LOG"
else
    echo "[$(date)] WWAN interface not found during disconnect." | tee -a "$LOG"
fi

echo "[$(date)] Modem disconnected." | tee -a "$LOG"
