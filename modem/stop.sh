#!/bin/bash
set -e

BASE="/opt/EMASESA/lafuentedepias"
LOG="$BASE/logs/modem.log"

echo "[$(date)] ===== BG96 STOP SEQUENCE =====" | tee -a "$LOG"

"$BASE/modem/disconnect.sh" || true

echo "[$(date)] BG96 powered state left unchanged." | tee -a "$LOG"
echo "[$(date)] ===== BG96 STOP COMPLETE =====" | tee -a "$LOG"
