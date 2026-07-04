#!/bin/bash

source /opt/EMASESA/lafuentedepias/config/gateway.conf
source /opt/EMASESA/lafuentedepias/config/modem.conf

LOG="/opt/EMASESA/lafuentedepias/logs/modem.log"

echo "[$(date)] Checking BG96 power state..." >> "$LOG"

if [ -e /dev/cdc-wdm0 ]; then
    echo "[$(date)] BG96 already detected: /dev/cdc-wdm0" >> "$LOG"
    exit 0
fi

echo "[$(date)] BG96 not detected. Trying to power on modem..." >> "$LOG"

cd "$SIXFAB_DIR" || {
    echo "[$(date)] ERROR: Sixfab directory not found: $SIXFAB_DIR" >> "$LOG"
    exit 1
}

python3 BG96sample.py >> "$LOG" 2>&1

echo "[$(date)] Waiting for BG96 USB devices..." >> "$LOG"

for i in {1..60}; do
    if [ -e /dev/cdc-wdm0 ]; then
        echo "[$(date)] BG96 detected after power on." >> "$LOG"
        exit 0
    fi

    echo "[$(date)] Waiting for /dev/cdc-wdm0..." >> "$LOG"
    sleep 2
done

echo "[$(date)] ERROR: BG96 not detected after power on attempt." >> "$LOG"
exit 1
