#!/bin/bash

# Colores para los mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Función para mostrar mensajes
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Función para mostrar advertencias
warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Directorio base
BASE_DIR="/home/oicrruf/raspberrypi-multimedia"

# Crear estructura de directorios
log "Creando estructura de directorios..."
mkdir -p $BASE_DIR/data/transmission/downloads/{complete,incomplete}/{radarr,sonarr,lidarr}
mkdir -p $BASE_DIR/services/{radarr,sonarr,lidarr}/{config,media}

# Establecer permisos
log "Estableciendo permisos..."
sudo chown -R 1000:1000 $BASE_DIR/data/transmission/downloads
sudo chmod -R 755 $BASE_DIR/data/transmission/downloads

# Reiniciar servicios en orden
log "Reiniciando servicios..."
cd $BASE_DIR/services

# 1. Transmission (base para descargas)
log "Reiniciando Transmission..."
cd transmission && docker-compose down && docker-compose up -d && cd ..

# 2. Radarr
log "Reiniciando Radarr..."
cd radarr && docker-compose down && docker-compose up -d && cd ..

# 3. Sonarr
log "Reiniciando Sonarr..."
cd sonarr && docker-compose down && docker-compose up -d && cd ..

# 4. Lidarr
log "Reiniciando Lidarr..."
cd lidarr && docker-compose down && docker-compose up -d && cd ..

# 5. Plex
log "Reiniciando Plex..."
cd plex && docker-compose down && docker-compose up -d && cd ..

log "Configuración completada!" 