# Jackett

Jackett es un proxy que traduce las solicitudes de diferentes trackers de torrents a un formato que pueden entender aplicaciones como Sonarr, Radarr, etc.

## Configuración

### Puertos
- **9117**: Interfaz web y API

### Directorios
- **./config**: Directorio de configuración
- **./downloads**: Directorio compartido con Transmission para las descargas

### Características
- Interfaz web accesible en `http://raspberrypi.local:9117`
- API disponible en `http://raspberrypi.local:9117/api/v2.0`
- Reinicio automático del contenedor a menos que se detenga manualmente
- Integrado con la red `multimedia_network` para comunicación con otros servicios

## Uso

1. Accede a la interfaz web a través de `http://raspberrypi.local:9117`
2. Configura los trackers que desees usar
3. Usa la URL de la API en Sonarr, Radarr y otras aplicaciones:
   - URL base: `http://raspberrypi.local:9117/api/v2.0`
   - API Key: Se genera automáticamente y se muestra en la interfaz web

## Notas
- La configuración se mantiene en el directorio `./config`
- Los archivos descargados se comparten con Transmission a través del directorio `./downloads`
- El contenedor se reiniciará automáticamente si el sistema se reinicia 