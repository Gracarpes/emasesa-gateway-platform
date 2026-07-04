# Troubleshooting

## ModemManager bloquea QMI

Síntomas:

- CID allocation failed
- Transaction timed out
- client not allocated

Solución:

sudo systemctl stop ModemManager
sudo systemctl disable ModemManager
sudo systemctl mask ModemManager

## cloudflared no llega al origen

Si aparece:

dial tcp [::1]:1880: connect: connection refused

Cloudflare funciona, pero Node-RED no está escuchando en localhost:1880.
