#!/bin/bash

BASE="/opt/EMASESA/lafuentedepias"

source "$BASE/config/gateway.conf"
source "$BASE/config/modem.conf"

STATUS_DIR="$BASE/status"
STATUS_FILE="$STATUS_DIR/gateway_status.json"

mkdir -p "$STATUS_DIR"

WWAN_IFACE=""

if [ -e /sys/class/usbmisc/cdc-wdm0/device/net ]; then
    WWAN_IFACE=$(basename "$(readlink -f /sys/class/usbmisc/cdc-wdm0/device/net/*)" 2>/dev/null)
fi

service_state() {
    systemctl is-active "$1" 2>/dev/null || echo "inactive"
}

if [ -n "$WWAN_IFACE" ]; then
    WWAN_IP=$(ip -4 addr show "$WWAN_IFACE" | awk '/inet / {print $2}' | cut -d/ -f1)
else
    WWAN_IP=""
fi

if ip -4 addr show enxb827ebc9ddf2 >/dev/null 2>&1 && ip -4 addr show enxb827ebc9ddf2 | grep -q "inet "; then
    ETHERNET=true
else
    ETHERNET=false
fi

if [ -n "$WWAN_IFACE" ] && ping -I "$WWAN_IFACE" -c 1 -W 3 "$PING_TARGET" >/dev/null 2>&1; then
    INTERNET="OK"
else
    INTERNET="FAIL"
fi

BG96_STATE="FAIL"
if [ -e "$QMI_DEVICE" ] && [ -n "$WWAN_IFACE" ] && [ -n "$WWAN_IP" ]; then
    BG96_STATE="OK"
fi

GATEWAY_STATE="HEALTHY"

if [ "$INTERNET" != "OK" ]; then
    GATEWAY_STATE="DEGRADED"
fi

if [ "$(service_state cloudflared.service)" != "active" ]; then
    GATEWAY_STATE="DEGRADED"
fi

if [ "$(service_state nodered.service)" != "active" ]; then
    GATEWAY_STATE="DEGRADED"
fi

if [ "$(service_state mosquitto.service)" != "active" ]; then
    GATEWAY_STATE="DEGRADED"
fi

cat > "$STATUS_FILE" <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "gateway": "$GATEWAY_STATE",
  "node": "$NODE_NAME",
  "platform": "$PLATFORM",
  "version": "$VERSION",
  "location": "$LOCATION",
  "bg96": "$BG96_STATE",
  "qmi_device": "$QMI_DEVICE",
  "qmi_present": $([ -e "$QMI_DEVICE" ] && echo true || echo false),
  "wwan_iface": "$WWAN_IFACE",
  "wwan_ip": "$WWAN_IP",
  "ethernet": $ETHERNET,
  "internet_bg96": "$INTERNET",
  "services": {
    "bg96": "$(service_state bg96.service)",
    "cloudflared": "$(service_state cloudflared.service)",
    "nodered": "$(service_state nodered.service)",
    "mosquitto": "$(service_state mosquitto.service)"
  }
}
EOF

cat "$STATUS_FILE"
