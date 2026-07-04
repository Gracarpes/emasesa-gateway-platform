# Módem BG96

El módem Quectel BG96 funciona mediante QMI, driver qmi_wwan y modo raw-ip.

PPP queda descartado.

## Puntos críticos

- Usar /dev/cdc-wdm0.
- Detectar automáticamente la interfaz WWAN.
- Desactivar ModemManager.
- Usar qmi-network.
- Obtener IP mediante udhcpc.
