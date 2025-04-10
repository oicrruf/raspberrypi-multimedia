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

# Cargar variables de entorno desde el archivo .env si existe
if [ -f ".env" ]; then
    print_message "Cargando variables de entorno desde .env..."
    export $(grep -v '^#' .env | xargs)
    print_message "Variables de entorno cargadas correctamente."
fi

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    print_error "Docker no está instalado. Por favor, instala Docker primero."
    exit 1
fi

# Verificar si Docker Compose está instalado
if ! docker compose version &> /dev/null; then
    print_warning "Docker Compose no está instalado. Intentando instalarlo..."
    
    # Intentar instalar Docker Compose usando apt
    if ! sudo apt-get install -y docker-compose-plugin; then
        print_error "No se pudo instalar Docker Compose. Por favor, instálalo manualmente."
        exit 1
    fi
    
    print_message "Docker Compose instalado correctamente."
fi

# Función para verificar si una variable está configurada en un archivo .env
check_env_variable() {
    local file=$1
    local var_name=$2
    if [ -f "$file" ] && grep -q "^${var_name}=" "$file" && ! grep -q "^${var_name}=$" "$file" && ! grep -q "^${var_name}=.*\$" "$file"; then
        return 0
    else
        return 1
    fi
}

# Verificar si los archivos .env existen y tienen las variables configuradas
ENV_FILES_EXIST=true
ENV_VARS_CONFIGURED=true

# Verificar archivo .env principal
if [ ! -f ".env" ]; then
    ENV_FILES_EXIST=false
else
    # Verificar variables principales
    for var in "PLEX_CLAIM" "OVERSEERR_JWT_SECRET" "TRANSMISSION_USERNAME" "TRANSMISSION_PASSWORD" "KOMGA_ADMIN_USER" "KOMGA_ADMIN_PASSWORD" "DOMAIN" "TRAEFIK_EMAIL"; do
        if ! check_env_variable ".env" "$var"; then
            ENV_VARS_CONFIGURED=false
            break
        fi
    done
fi

# Verificar archivos .env de servicios
for service in "overseerr" "transmission" "komga" "traefik"; do
    if [ ! -f "services/${service}/.env" ]; then
        ENV_FILES_EXIST=false
    fi
done

if [ "$ENV_FILES_EXIST" = true ] && [ "$ENV_VARS_CONFIGURED" = true ]; then
    print_message "Los archivos .env ya están configurados correctamente. Procediendo a iniciar los contenedores..."
else
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

    # Copiar .env.example principal si no existe
    if [ ! -f ".env" ]; then
        cp .env.example .env
    fi

    # Actualizar variables en .env principal
    print_message "Actualizando variables en .env principal..."
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
    print_message "Configurando archivos .env de servicios..."
    for service_dir in services/*/; do
        service_name=$(basename "$service_dir")
        env_file="${service_dir}.env"
        env_example="${service_dir}.env.example"
        
        # Asegurarse de que el directorio del servicio existe
        mkdir -p "$service_dir"
        
        # Copiar .env.example si existe y .env no existe
        if [ -f "$env_example" ] && [ ! -f "$env_file" ]; then
            print_message "Copiando $env_example a $env_file"
            cp "$env_example" "$env_file"
        fi
        
        # Actualizar variables en el archivo .env del servicio
        if [ -f "$env_file" ]; then
            print_message "Actualizando variables en $env_file"
            sed -i "s|TZ=.*|TZ=America/El_Salvador|g" "$env_file"
            
            # Configuraciones específicas por servicio
            case "$service_name" in
                "overseerr")
                    sed -i "s|OVERSEERR_JWT_SECRET=.*|OVERSEERR_JWT_SECRET=$OVERSEERR_JWT_SECRET|g" "$env_file"
                    ;;
                "transmission")
                    sed -i "s|TRANSMISSION_USERNAME=.*|TRANSMISSION_USERNAME=$TRANSMISSION_USERNAME|g" "$env_file"
                    sed -i "s|TRANSMISSION_PASSWORD=.*|TRANSMISSION_PASSWORD=$TRANSMISSION_PASSWORD|g" "$env_file"
                    ;;
                "komga")
                    sed -i "s|KOMGA_ADMIN_USER=.*|KOMGA_ADMIN_USER=$KOMGA_ADMIN_USER|g" "$env_file"
                    sed -i "s|KOMGA_ADMIN_PASSWORD=.*|KOMGA_ADMIN_PASSWORD=$KOMGA_ADMIN_PASSWORD|g" "$env_file"
                    ;;
                "traefik")
                    sed -i "s|TRAEFIK_EMAIL=.*|TRAEFIK_EMAIL=$TRAEFIK_EMAIL|g" "$env_file"
                    ;;
            esac
        else
            # Si no existe el archivo .env, crearlo con las variables necesarias
            print_message "Creando archivo $env_file"
            touch "$env_file"
            echo "TZ=America/El_Salvador" > "$env_file"
            
            # Agregar variables específicas por servicio
            case "$service_name" in
                "overseerr")
                    echo "OVERSEERR_JWT_SECRET=$OVERSEERR_JWT_SECRET" >> "$env_file"
                    ;;
                "transmission")
                    echo "TRANSMISSION_USERNAME=$TRANSMISSION_USERNAME" >> "$env_file"
                    echo "TRANSMISSION_PASSWORD=$TRANSMISSION_PASSWORD" >> "$env_file"
                    ;;
                "komga")
                    echo "KOMGA_ADMIN_USER=$KOMGA_ADMIN_USER" >> "$env_file"
                    echo "KOMGA_ADMIN_PASSWORD=$KOMGA_ADMIN_PASSWORD" >> "$env_file"
                    ;;
                "traefik")
                    echo "TRAEFIK_EMAIL=$TRAEFIK_EMAIL" >> "$env_file"
                    ;;
            esac
        fi
    done

    # Verificar que los archivos .env se hayan creado correctamente
    print_message "Verificando archivos .env..."
    for service in "overseerr" "transmission" "komga" "traefik"; do
        if [ ! -f "services/${service}/.env" ]; then
            print_error "No se pudo crear el archivo .env para ${service}"
            exit 1
        fi
    done
fi

# Crear red Docker si no existe
print_message "Creando red Docker multimedia..."
docker network create multimedia_network 2>/dev/null || true

# Verificar y reiniciar contenedores
print_message "Verificando y reiniciando contenedores..."
docker compose down
docker compose pull
docker compose up -d

# Verificar que los contenedores estén corriendo
print_message "Verificando estado de los contenedores..."
sleep 10
if ! docker compose ps | grep -q "Up"; then
    print_error "Algunos contenedores no se iniciaron correctamente. Revisa los logs con: docker compose logs"
    exit 1
fi

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