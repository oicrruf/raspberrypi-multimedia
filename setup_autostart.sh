#!/bin/bash

# Colores para la salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Configurando inicio automático de contenedores ===${NC}"

# Verificar si estamos en un Raspberry Pi
if ! grep -q "Raspberry Pi" /proc/device-tree/model 2>/dev/null; then
    echo -e "${RED}Este script debe ejecutarse en un Raspberry Pi${NC}"
    exit 1
fi

# Hacer el script de inicio ejecutable
echo -e "${YELLOW}Configurando permisos...${NC}"
chmod +x start_containers.sh

# Crear directorio para logs si no existe
echo -e "${YELLOW}Configurando logs...${NC}"
sudo touch /var/log/multimedia-containers.log
sudo chown pi:pi /var/log/multimedia-containers.log

# Copiar el servicio systemd
echo -e "${YELLOW}Instalando servicio systemd...${NC}"
sudo cp multimedia-containers.service /etc/systemd/system/

# Recargar systemd
echo -e "${YELLOW}Recargando configuración de systemd...${NC}"
sudo systemctl daemon-reload

# Habilitar el servicio
echo -e "${YELLOW}Habilitando servicio de inicio automático...${NC}"
sudo systemctl enable multimedia-containers.service

# Iniciar el servicio
echo -e "${YELLOW}Iniciando servicio...${NC}"
sudo systemctl start multimedia-containers.service

# Verificar estado
echo -e "${YELLOW}Verificando estado del servicio...${NC}"
sudo systemctl status multimedia-containers.service

echo -e "${GREEN}=== Configuración completada ===${NC}"
echo -e "${YELLOW}El servicio se iniciará automáticamente al reiniciar el sistema${NC}"
echo -e "${YELLOW}Para ver los logs:${NC}"
echo -e "${GREEN}tail -f /var/log/multimedia-containers.log${NC}" 