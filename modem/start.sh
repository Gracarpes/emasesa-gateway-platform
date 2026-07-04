#!/bin/bash
set -e

BASE="/opt/EMASESA/lafuentedepias"
LOG="$BASE/logs/modem.log"

echo "[$(date)] ===== BG96 START SEQUENCE =====" | tee -a "$LOG"

"$BASE/modem/power_on_bg96.sh"

sleep 5

"$BASE/modem/connect.sh"

sleep 3

"$BASE/modem/status.sh" | tee -a "$LOG"

echo "[$(date)] ===== BG96 START COMPLETE =====" | tee -a "$LOG"
