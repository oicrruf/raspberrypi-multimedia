#!/bin/bash

# Colores para la salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Directorio base
BASE_DIR="$HOME/multimedia"
LOG_FILE="/var/log/multimedia-containers.log"

# Función para registrar logs
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Verificar si Docker está corriendo
if ! systemctl is-active --quiet docker; then
    log "${RED}Docker no está corriendo. Iniciando Docker...${NC}"
    sudo systemctl start docker
    sleep 10
fi

# Verificar si la red existe
if ! docker network ls | grep -q multimedia_network; then
    log "${YELLOW}Creando red multimedia_network...${NC}"
    docker network create multimedia_network
fi

# Iniciar los contenedores
log "${GREEN}Iniciando contenedores multimedia...${NC}"

# Lista de servicios a iniciar
SERVICES=(
    "transmission"
    "jackett"
    "sonarr"
    "radarr"
    "lidarr"
    "plex"
    "prowlarr"
    "bazarr"
    "tautulli"
    "overseerr"
)

# Iniciar cada servicio
for service in "${SERVICES[@]}"; do
    if [ -d "$BASE_DIR/$service" ]; then
        log "${YELLOW}Iniciando $service...${NC}"
        cd "$BASE_DIR/$service"
        docker-compose up -d
        if [ $? -eq 0 ]; then
            log "${GREEN}$service iniciado correctamente${NC}"
        else
            log "${RED}Error al iniciar $service${NC}"
        fi
    fi
done

log "${GREEN}Todos los contenedores han sido iniciados${NC}" 