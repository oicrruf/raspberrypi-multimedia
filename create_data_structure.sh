#!/bin/bash

# Colores para la salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Creando estructura de datos para servicios multimedia ===${NC}"

# Directorio base
BASE_DIR="$HOME/multimedia"
echo -e "${YELLOW}Creando directorio base en: $BASE_DIR${NC}"

# Crear estructura principal
mkdir -p "$BASE_DIR"/{config,downloads,media}

# Estructura para cada servicio
SERVICES=(
    "transmission:config,downloads"
    "jackett:config,downloads"
    "sonarr:config,tv"
    "radarr:config,movies"
    "lidarr:config,music"
    "plex:config,transcode,media"
    "prowlarr:config,downloads"
    "bazarr:config,movies,tv"
    "tautulli:config"
    "overseerr:config"
)

# Crear estructura para cada servicio
for service in "${SERVICES[@]}"; do
    IFS=':' read -r name dirs <<< "$service"
    echo -e "${YELLOW}Creando estructura para $name...${NC}"
    
    # Crear directorios del servicio
    IFS=',' read -ra dir_array <<< "$dirs"
    for dir in "${dir_array[@]}"; do
        mkdir -p "$BASE_DIR/$name/$dir"
        echo -e "  - $BASE_DIR/$name/$dir"
    done
done

# Crear estructura de medios
echo -e "${YELLOW}Creando estructura de medios...${NC}"
mkdir -p "$BASE_DIR/media"/{movies,tv,music}

# Crear estructura común de descargas
echo -e "${YELLOW}Creando estructura común de descargas...${NC}"
mkdir -p "$BASE_DIR/downloads"/{complete,incomplete,torrents}
echo -e "  - $BASE_DIR/downloads/complete"
echo -e "  - $BASE_DIR/downloads/incomplete"
echo -e "  - $BASE_DIR/downloads/torrents"

# Crear enlaces simbólicos para las descargas
echo -e "${YELLOW}Creando enlaces simbólicos para las descargas...${NC}"
ln -s "$BASE_DIR/downloads/complete" "$BASE_DIR/media/downloads"
ln -s "$BASE_DIR/downloads/complete/movies" "$BASE_DIR/media/movies/downloads"
ln -s "$BASE_DIR/downloads/complete/tv" "$BASE_DIR/media/tv/downloads"
ln -s "$BASE_DIR/downloads/complete/music" "$BASE_DIR/media/music/downloads"

# Establecer permisos
echo -e "${YELLOW}Estableciendo permisos...${NC}"
chmod -R 755 "$BASE_DIR"
chown -R $USER:$USER "$BASE_DIR"

echo -e "${GREEN}=== Estructura de datos creada exitosamente ===${NC}"
echo -e "${YELLOW}La estructura completa está en: $BASE_DIR${NC}"

# Mostrar estructura
echo -e "\n${GREEN}Estructura creada:${NC}"
tree "$BASE_DIR" -L 3 