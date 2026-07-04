#!/bin/bash

source /opt/EMASESA/lafuentedepias/config/modem.conf

LOG="/opt/EMASESA/lafuentedepias/logs/modem.log"

echo "========== MODEM STATUS =========="
echo "Node: $NODE_NAME"
echo "QMI device: $QMI_DEVICE"
echo

if lsusb | grep -qi "2c7c:0296"; then
    echo "USB BG96: OK"
else
    echo "USB BG96: NOT DETECTED"
fi

if [ -e "$QMI_DEVICE" ]; then
    echo "QMI device: OK"
else
    echo "QMI device: NOT FOUND"
fi

if [ -e /sys/class/usbmisc/cdc-wdm0/device/net ]; then
    WWAN_IFACE=$(basename "$(readlink -f /sys/class/usbmisc/cdc-wdm0/device/net/*)" 2>/dev/null)
else
    WWAN_IFACE=""
fi

if [ -n "$WWAN_IFACE" ]; then
    echo "WWAN interface: $WWAN_IFACE"
    ip addr show "$WWAN_IFACE" 2>/dev/null
else
    echo "WWAN interface: NOT FOUND"
fi

echo
echo "Routes:"
ip route

echo
echo "Connectivity test:"
if ping -I "$WWAN_IFACE" -c 3 "$PING_TARGET" >/dev/null 2>&1; then
    echo "Internet via modem: OK"
else
    echo "Internet via modem: FAILED"
fi

echo "=================================="
