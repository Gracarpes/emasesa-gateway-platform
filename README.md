# EMASESA Gateway – LaFuenteDePias

Gateway remoto basado en Raspberry Pi para control y monitorización de una fuente de EMASESA.

## Objetivo

Construir una plataforma base reutilizable para futuros gateways remotos de EMASESA, utilizando:

- Raspberry Pi OS Lite
- Sixfab Cellular IoT HAT
- Quectel BG96
- QMI / raw-ip
- Cloudflare Tunnel
- Mosquitto MQTT
- Node-RED

## Nodo

- Nombre: `lafuentedepias`
- Dominio: `lafuentedepias.org`
- Acceso SCADA: `scada.lafuentedepias.org`

## Arquitectura

```text
BG96
  ↓
qmi_wwan
  ↓
/dev/cdc-wdm0
  ↓
qmi-network
  ↓
WWAN
  ↓
Cloudflare Tunnel
  ↓
Node-RED
  ↓
Dashboard / MQTT / Control

Estructura

/opt/EMASESA/lafuentedepias/

├── backup/
├── cloudflare/
├── config/
├── dashboard/
├── docs/
├── logs/
├── modem/
├── mqtt/
├── nodered/
├── scripts/
└── services/

Estado actual

BG96 operativo mediante QMI.
PPP descartado.
Interfaz WWAN detectada automáticamente.
ModemManager deshabilitado por conflicto con QMI.
Cloudflare Tunnel operativo.
Node-RED instalado y securizado.
Mosquitto con usuarios y ACL.
Servicio bg96.service creado.

Nota de seguridad

Este repositorio no debe contener:

Tokens de Cloudflare.
Contraseñas.
Ficheros flows_cred.json.
Certificados.
Claves privadas.
Ficheros de credenciales Mosquitto.
