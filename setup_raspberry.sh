#!/bin/bash

# Colores para la salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Configuración inicial del Raspberry Pi ===${NC}"

# Verificar si estamos en un Raspberry Pi
if ! grep -q "Raspberry Pi" /proc/device-tree/model 2>/dev/null; then
    echo -e "${RED}Este script debe ejecutarse en un Raspberry Pi${NC}"
    exit 1
fi

# Actualizar el sistema
echo -e "${YELLOW}Actualizando el sistema...${NC}"
sudo apt-get update
sudo apt-get upgrade -y

# Instalar dependencias necesarias
echo -e "${YELLOW}Instalando dependencias...${NC}"
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    tree

# Instalar Docker
echo -e "${YELLOW}Instalando Docker...${NC}"
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

# Añadir el usuario actual al grupo docker
sudo usermod -aG docker $USER

# Instalar Docker Compose
echo -e "${YELLOW}Instalando Docker Compose...${NC}"
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Crear estructura de datos
echo -e "${YELLOW}Creando estructura de datos...${NC}"
./create_data_structure.sh

# Crear archivo .env
echo -e "${YELLOW}Creando archivo de configuración...${NC}"
cat > ~/multimedia/.env << EOL
# Configuración general
TZ=Europe/Madrid
PUID=1000
PGID=1000

# Configuración de red
DEFAULT_NETWORK=raspberry_network
MULTIMEDIA_NETWORK=multimedia_network

# Variables específicas de servicios multimedia
TRANSMISSION_USER=admin
TRANSMISSION_PASS=admin # Cambiar en producción

# Rutas de almacenamiento
MOVIES_PATH=/movies
TV_SHOWS_PATH=/tv
MUSIC_PATH=/music
DOWNLOADS_PATH=/downloads
EOL

# Clonar el repositorio
echo -e "${YELLOW}Clonando el repositorio...${NC}"
cd ~
git clone https://github.com/tu-usuario/raspberry.git
cd raspberry

# Hacer ejecutables los scripts
chmod +x install.sh
chmod +x create_data_structure.sh
chmod +x start_containers.sh
chmod +x setup_autostart.sh

# Configurar inicio automático
echo -e "${YELLOW}Configurando inicio automático...${NC}"
./setup_autostart.sh

echo -e "${GREEN}=== Configuración completada ===${NC}"
echo -e "${YELLOW}Por favor, reinicia el sistema para aplicar todos los cambios.${NC}"
echo -e "${YELLOW}Después de reiniciar, ejecuta:${NC}"
echo -e "${GREEN}cd ~/raspberry && ./install.sh${NC}" 