# Servicios systemd

Este directorio contiene copias de referencia de los servicios utilizados por el gateway.

Para instalar un servicio:

sudo cp services/bg96.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable bg96.service
sudo systemctl start bg96.service
