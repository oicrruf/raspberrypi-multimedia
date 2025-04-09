#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Función para imprimir mensajes
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    print_error "Docker no está instalado. Por favor, instala Docker primero."
    exit 1
fi

# Verificar si Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose no está instalado. Por favor, instala Docker Compose primero."
    exit 1
fi

# Crear estructura de directorios
print_message "Creando estructura de directorios..."
./create_data_structure.sh

# Función para solicitar variables de entorno
request_env_variables() {
    # Solicitar PLEX_CLAIM
    if [ -z "$PLEX_CLAIM" ]; then
        print_warning "Se requiere un PLEX_CLAIM válido para la configuración de Plex"
        print_message "Puedes obtenerlo en: https://plex.tv/claim"
        read -p "Ingresa tu PLEX_CLAIM: " PLEX_CLAIM
    fi

    # Solicitar OVERSEERR_JWT_SECRET
    if [ -z "$OVERSEERR_JWT_SECRET" ]; then
        print_warning "Se requiere un OVERSEERR_JWT_SECRET para la seguridad de Overseerr"
        read -p "Ingresa un OVERSEERR_JWT_SECRET (puede ser cualquier string largo y aleatorio): " OVERSEERR_JWT_SECRET
    fi

    # Solicitar credenciales de Transmission
    if [ -z "$TRANSMISSION_USERNAME" ] || [ -z "$TRANSMISSION_PASSWORD" ]; then
        print_warning "Configuración de credenciales para Transmission"
        read -p "Usuario de Transmission (default: admin): " TRANSMISSION_USERNAME
        TRANSMISSION_USERNAME=${TRANSMISSION_USERNAME:-admin}
        read -p "Contraseña de Transmission: " TRANSMISSION_PASSWORD
    fi

    # Solicitar credenciales de Komga
    if [ -z "$KOMGA_ADMIN_USER" ] || [ -z "$KOMGA_ADMIN_PASSWORD" ]; then
        print_warning "Configuración de credenciales para Komga"
        read -p "Usuario administrador de Komga (default: admin): " KOMGA_ADMIN_USER
        KOMGA_ADMIN_USER=${KOMGA_ADMIN_USER:-admin}
        read -p "Contraseña de administrador de Komga: " KOMGA_ADMIN_PASSWORD
    fi

    # Solicitar configuración de dominio
    if [ -z "$DOMAIN" ]; then
        print_warning "Configuración de dominio"
        read -p "Dominio base (default: raspberrypi.local): " DOMAIN
        DOMAIN=${DOMAIN:-raspberrypi.local}
    fi

    if [ -z "$TRAEFIK_EMAIL" ]; then
        print_warning "Configuración de email para certificados"
        read -p "Email para certificados (default: admin@${DOMAIN}): " TRAEFIK_EMAIL
        TRAEFIK_EMAIL=${TRAEFIK_EMAIL:-admin@${DOMAIN}}
    fi
}

# Solicitar variables de entorno necesarias
request_env_variables

# Copiar y configurar archivos .env
print_message "Configurando archivos .env..."

# Copiar .env.example principal
cp .env.example .env

# Actualizar variables en .env principal
sed -i "s|TZ=.*|TZ=America/El_Salvador|g" .env
sed -i "s|PLEX_CLAIM=.*|PLEX_CLAIM=$PLEX_CLAIM|g" .env
sed -i "s|TRANSMISSION_USERNAME=.*|TRANSMISSION_USERNAME=$TRANSMISSION_USERNAME|g" .env
sed -i "s|TRANSMISSION_PASSWORD=.*|TRANSMISSION_PASSWORD=$TRANSMISSION_PASSWORD|g" .env
sed -i "s|KOMGA_ADMIN_USER=.*|KOMGA_ADMIN_USER=$KOMGA_ADMIN_USER|g" .env
sed -i "s|KOMGA_ADMIN_PASSWORD=.*|KOMGA_ADMIN_PASSWORD=$KOMGA_ADMIN_PASSWORD|g" .env
sed -i "s|DOMAIN=.*|DOMAIN=$DOMAIN|g" .env
sed -i "s|TRAEFIK_EMAIL=.*|TRAEFIK_EMAIL=$TRAEFIK_EMAIL|g" .env
sed -i "s|OVERSEERR_JWT_SECRET=.*|OVERSEERR_JWT_SECRET=$OVERSEERR_JWT_SECRET|g" .env

# Configurar .env de cada servicio
for service in services/*/; do
    if [ -f "${service}.env.example" ]; then
        cp "${service}.env.example" "${service}.env"
        sed -i "s|TZ=.*|TZ=America/El_Salvador|g" "${service}.env"
        
        # Configuraciones específicas por servicio
        case $(basename "$service") in
            "overseerr")
                sed -i "s|OVERSEERR_JWT_SECRET=.*|OVERSEERR_JWT_SECRET=$OVERSEERR_JWT_SECRET|g" "${service}.env"
                ;;
            "transmission")
                sed -i "s|TRANSMISSION_USERNAME=.*|TRANSMISSION_USERNAME=$TRANSMISSION_USERNAME|g" "${service}.env"
                sed -i "s|TRANSMISSION_PASSWORD=.*|TRANSMISSION_PASSWORD=$TRANSMISSION_PASSWORD|g" "${service}.env"
                ;;
            "komga")
                sed -i "s|KOMGA_ADMIN_USER=.*|KOMGA_ADMIN_USER=$KOMGA_ADMIN_USER|g" "${service}.env"
                sed -i "s|KOMGA_ADMIN_PASSWORD=.*|KOMGA_ADMIN_PASSWORD=$KOMGA_ADMIN_PASSWORD|g" "${service}.env"
                ;;
            "traefik")
                sed -i "s|TRAEFIK_EMAIL=.*|TRAEFIK_EMAIL=$TRAEFIK_EMAIL|g" "${service}.env"
                ;;
        esac
    fi
done

# Crear red Docker si no existe
print_message "Creando red Docker multimedia..."
docker network create multimedia_network 2>/dev/null || true

# Iniciar servicios
print_message "Iniciando servicios..."
docker-compose up -d

# Configurar autostart
print_message "Configurando autostart..."
./setup_autostart.sh

print_message "Instalación completada. Por favor, verifica los logs de los servicios para asegurarte de que todo funciona correctamente."
print_message "Puedes acceder a los servicios en:"
print_message "Plex: https://plex.${DOMAIN}"
print_message "Sonarr: https://sonarr.${DOMAIN}"
print_message "Radarr: https://radarr.${DOMAIN}"
print_message "Transmission: https://transmission.${DOMAIN}"
print_message "Jackett: https://jackett.${DOMAIN}"
print_message "Overseerr: https://overseerr.${DOMAIN}"
print_message "Tautulli: https://tautulli.${DOMAIN}"
print_message "Bazarr: https://bazarr.${DOMAIN}"
print_message "Prowlarr: https://prowlarr.${DOMAIN}"
print_message "Lidarr: https://lidarr.${DOMAIN}"
print_message "Komga: https://komga.${DOMAIN}"
print_message "Traefik Dashboard: https://traefik.${DOMAIN}" 