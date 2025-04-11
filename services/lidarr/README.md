# Lidarr

Lidarr es un gestor de música que automatiza la descarga y organización de tu biblioteca musical.

## Configuración

### Puertos
- **8686**: Interfaz web

### Directorios
- **./config**: Directorio de configuración
- **./music**: Directorio donde se guarda la música

### Características
- Interfaz web accesible en `http://raspberrypi.local:8686`
- Integración con Jackett para indexadores
- Integración con Transmission para descargas
- Reinicio automático del contenedor a menos que se detenga manualmente
- Integrado con la red `multimedia_network` para comunicación con otros servicios

## Uso

1. Accede a la interfaz web a través de `http://raspberrypi.local:8686`
2. Configuración inicial:
   - Añade tus indexadores (Jackett)
   - Configura el cliente de descargas (Transmission)
   - Añade tus artistas favoritos
   - Configura las rutas de descarga

## Integración con Jackett
1. Ve a Settings > Indexers
2. Haz clic en el botón "+" para añadir un nuevo indexador
3. Selecciona "Jackett"
4. Configura:
   - URL: `http://raspberrypi.local:9117/api/v2.0`
   - API Key: (la obtendrás de la interfaz de Jackett)

## Integración con Transmission
1. Ve a Settings > Download Clients
2. Haz clic en el botón "+" para añadir un nuevo cliente
3. Selecciona "Transmission"
4. Configura:
   - Host: `transmission`
   - Puerto: `9091`
   - URL Base: `/transmission/`

## Notas
- La configuración se mantiene en el directorio `./config`
- La música se guarda en el directorio `./music`
- El contenedor se reiniciará automáticamente si el sistema se reinicia 