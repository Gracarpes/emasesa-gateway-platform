#!/bin/bash
set -e

source /opt/EMASESA/lafuentedepias/config/gateway.conf
source /opt/EMASESA/lafuentedepias/config/modem.conf

LOG="/opt/EMASESA/lafuentedepias/logs/modem.log"

WWAN_IFACE=$(basename "$(readlink -f /sys/class/usbmisc/cdc-wdm0/device/net/*)")
echo "[$(date)] WWAN interface detected: $WWAN_IFACE" | tee -a "$LOG"

echo "[$(date)] Starting modem connection for $NODE_NAME..." | tee -a "$LOG"

# Esperar al dispositivo QMI
for i in {1..60}; do
    if [ -e "$QMI_DEVICE" ]; then
        echo "[$(date)] QMI device found: $QMI_DEVICE" | tee -a "$LOG"
        break
    fi
    echo "[$(date)] Waiting for QMI device..." | tee -a "$LOG"
    sleep 2
done

if [ ! -e "$QMI_DEVICE" ]; then
    echo "[$(date)] ERROR: QMI device not found: $QMI_DEVICE" | tee -a "$LOG"
    exit 1
fi

# Esperar a la interfaz WWAN
for i in {1..60}; do
    if ip link show "$WWAN_IFACE" >/dev/null 2>&1; then
        echo "[$(date)] WWAN interface found: $WWAN_IFACE" | tee -a "$LOG"
        break
    fi
    echo "[$(date)] Waiting for WWAN interface..." | tee -a "$LOG"
    sleep 2
done

if ! ip link show "$WWAN_IFACE" >/dev/null 2>&1; then
    echo "[$(date)] ERROR: WWAN interface not found: $WWAN_IFACE" | tee -a "$LOG"
    exit 1
fi

# Configurar raw-ip
sudo ip link set "$WWAN_IFACE" down || true
echo Y | sudo tee /sys/class/net/"$WWAN_IFACE"/qmi/raw_ip >/dev/null
sudo ip link set "$WWAN_IFACE" up

# Reiniciar sesión QMI
sudo qmi-network "$QMI_DEVICE" stop || true
sleep 3

sudo qmi-network "$QMI_DEVICE" start
sleep 3

# Obtener IP
sudo udhcpc -i "$WWAN_IFACE" -q

echo "[$(date)] Modem connected successfully." | tee -a "$LOG"
ip addr show "$WWAN_IFACE" | tee -a "$LOG"
ip route | tee -a "$LOG"
