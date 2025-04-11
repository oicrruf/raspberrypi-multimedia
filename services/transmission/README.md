# Transmission

Transmission es un cliente de BitTorrent ligero y fácil de usar.

## Configuración

### Puertos
- **9091**: Interfaz web
- **51413**: Puerto para conexiones peer (TCP y UDP)

### Directorios
- **./downloads**: Directorio donde se guardan los archivos descargados
- **./downloads/incomplete**: Directorio donde se guardan los archivos incompletos
- **./config**: Directorio de configuración
- **./watch**: Directorio para monitorear nuevos archivos .torrent

### Características
- Interfaz web predeterminada accesible en `http://raspberrypi.local:9091/transmission/web/`
- Reinicio automático del contenedor a menos que se detenga manualmente
- Integrado con la red `multimedia_network` para comunicación con otros servicios

## Uso

1. Accede a la interfaz web a través de `http://raspberrypi.local:9091/transmission/web/`
2. Para agregar torrents:
   - Usa el botón "Añadir" en la interfaz web
   - O coloca archivos .torrent en el directorio `./watch`

## Notas
- La configuración se mantiene en el directorio `./config`
- Los archivos descargados se guardan en `./downloads`
- El contenedor se reiniciará automáticamente si el sistema se reinicia 