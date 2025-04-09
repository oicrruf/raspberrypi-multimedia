# Instalación en Raspberry Pi

Este documento describe cómo instalar y configurar el stack multimedia en un Raspberry Pi 4.

## Requisitos

- Raspberry Pi 4 (recomendado 4GB o 8GB de RAM)
- Tarjeta SD de al menos 32GB (recomendado 64GB o más)
- Raspberry Pi OS 64-bit (recomendado)
- Disco duro externo (opcional, pero recomendado para almacenamiento)

## Pasos de Instalación

1. **Preparar el Raspberry Pi**
   - Instalar Raspberry Pi OS 64-bit
   - Conectar el Raspberry Pi a la red
   - Actualizar el sistema:
     ```bash
     sudo apt update && sudo apt upgrade -y
     ```

2. **Configuración Inicial**
   - Clonar este repositorio:
     ```bash
     cd ~
     git clone https://github.com/tu-usuario/raspberry.git
     cd raspberry
     ```
   - Ejecutar el script de configuración:
     ```bash
     chmod +x setup_raspberry.sh
     ./setup_raspberry.sh
     ```
   - Reiniciar el sistema después de la configuración

3. **Configurar el Almacenamiento (Opcional)**
   - Conectar el disco duro externo
   - Montar el disco:
     ```bash
     sudo mkdir -p /mnt/media
     sudo mount /dev/sdX /mnt/media  # Reemplazar sdX con tu dispositivo
     ```
   - Añadir al fstab para montaje automático:
     ```bash
     echo "/dev/sdX /mnt/media ext4 defaults 0 0" | sudo tee -a /etc/fstab
     ```

4. **Instalar los Servicios**
   - Ejecutar el instalador:
     ```bash
     cd ~/raspberry
     ./install.sh
     ```
   - Seleccionar los servicios que deseas instalar

## Puertos y Accesos

- Transmission: http://localhost:9091
- Jackett: http://localhost:9117
- Sonarr: http://localhost:8989
- Radarr: http://localhost:7878
- Lidarr: http://localhost:8686
- Plex: http://localhost:32400/web
- Prowlarr: http://localhost:9696
- Bazarr: http://localhost:6767
- Tautulli: http://localhost:8181
- Overseerr: http://localhost:5055

## Configuración Recomendada

1. **Transmission**
   - Configurar usuario y contraseña en el archivo .env
   - Configurar directorios de descarga

2. **Jackett**
   - Añadir trackers de torrent
   - Configurar API key

3. **Sonarr/Radarr/Lidarr**
   - Conectar con Jackett
   - Configurar calidad y rutas

4. **Plex**
   - Configurar bibliotecas
   - Añadir usuarios

## Solución de Problemas

1. **Problemas de Rendimiento**
   - Ajustar la calidad de transcodificación en Plex
   - Limitar el número de descargas simultáneas en Transmission

2. **Problemas de Almacenamiento**
   - Verificar permisos de directorios
   - Comprobar espacio disponible

3. **Problemas de Red**
   - Verificar puertos abiertos
   - Comprobar configuración de red

## Mantenimiento

- Actualizar regularmente:
  ```bash
  cd ~/raspberry
  git pull
  ./install.sh
  ```

- Hacer copias de seguridad de la configuración:
  ```bash
  tar -czf backup.tar.gz ~/multimedia/config
  ``` 