#!/bin/bash

source /opt/EMASESA/lafuentedepias/config/gateway.conf
source /opt/EMASESA/lafuentedepias/config/modem.conf

WWAN_IFACE=""

if [ -e /sys/class/usbmisc/cdc-wdm0/device/net ]; then
    WWAN_IFACE=$(basename "$(readlink -f /sys/class/usbmisc/cdc-wdm0/device/net/*)" 2>/dev/null)
fi

TEMP_RAW=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0)
TEMP_C=$(awk "BEGIN {printf \"%.1f\", $TEMP_RAW/1000}")

CPU_LOAD=$(awk '{print $1}' /proc/loadavg)

RAM_USED=$(free | awk '/Mem:/ {printf "%.1f", $3/$2*100}')

DISK_USED=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')

UPTIME=$(uptime -p | sed 's/up //')

IP_LOCAL=$(hostname -I | awk '{print $1}')

if [ -n "$WWAN_IFACE" ]; then
    IP_WWAN=$(ip -4 addr show "$WWAN_IFACE" | awk '/inet / {print $2}' | cut -d/ -f1)
else
    IP_WWAN=""
fi

check_service() {
    systemctl is-active "$1" 2>/dev/null || echo "inactive"
}

if [ -n "$WWAN_IFACE" ] && ping -I "$WWAN_IFACE" -c 1 -W 3 "$PING_TARGET" >/dev/null 2>&1; then
    INTERNET_BG96="ok"
else
    INTERNET_BG96="fail"
fi

cat <<EOF
{
  "node": "$NODE_NAME",
  "platform": "$PLATFORM",
  "version": "$VERSION",
  "location": "$LOCATION",
  "uptime": "$UPTIME",
  "cpu_temp_c": $TEMP_C,
  "cpu_load": "$CPU_LOAD",
  "ram_used_pct": $RAM_USED,
  "disk_used_pct": $DISK_USED,
  "ip_local": "$IP_LOCAL",
  "wwan_iface": "$WWAN_IFACE",
  "ip_wwan": "$IP_WWAN",
  "qmi_device": "$QMI_DEVICE",
  "qmi_present": "$([ -e "$QMI_DEVICE" ] && echo true || echo false)",
  "internet_bg96": "$INTERNET_BG96",
  "services": {
    "bg96": "$(check_service bg96.service)",
    "cloudflared": "$(check_service cloudflared.service)",
    "mosquitto": "$(check_service mosquitto.service)",
    "nodered": "$(check_service nodered.service)"
  }
}
EOF
