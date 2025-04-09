# Servidor Multimedia en Raspberry Pi

Este proyecto configura un servidor multimedia completo en una Raspberry Pi utilizando Docker.

## Servicios Incluidos

- Plex: Servidor de medios
- Sonarr: Gestión de series
- Radarr: Gestión de películas
- Lidarr: Gestión de música
- Transmission: Cliente de torrents
- Jackett: Indexador de torrents
- Prowlarr: Gestión de indexadores
- Bazarr: Gestión de subtítulos
- Tautulli: Monitoreo de Plex
- Overseerr: Solicitudes de contenido
- Komga: Gestión de mangas
- Traefik: Proxy inverso con HTTPS

## Requisitos

- Raspberry Pi 4 (recomendado)
- Docker y Docker Compose instalados
- Al menos 4GB de RAM
- Almacenamiento externo para medios (recomendado)

## Instalación

1. Clona este repositorio:
```bash
git clone https://github.com/tu-usuario/raspberry-media-server.git
cd raspberry-media-server
```

2. Ejecuta el script de instalación:
```bash
chmod +x install.sh
./install.sh
```

3. Sigue las instrucciones en pantalla para configurar las variables de entorno.

## Configuración de Subdominios y Certificados

Para acceder a los servicios a través de subdominios seguros (HTTPS), sigue estos pasos:

1. Configura tu DNS local para que `*.raspberrypi.local` apunte a la IP de tu Raspberry Pi.

2. Agrega las siguientes líneas a tu archivo `/etc/hosts`:
```
127.0.0.1 raspberrypi.local
127.0.0.1 *.raspberrypi.local
```

3. Asegúrate de que los puertos 80 y 443 estén abiertos en tu firewall.

4. Los servicios estarán disponibles en:
   - Plex: https://plex.raspberrypi.local
   - Sonarr: https://sonarr.raspberrypi.local
   - Radarr: https://radarr.raspberrypi.local
   - Transmission: https://transmission.raspberrypi.local
   - Jackett: https://jackett.raspberrypi.local
   - Overseerr: https://overseerr.raspberrypi.local
   - Tautulli: https://tautulli.raspberrypi.local
   - Bazarr: https://bazarr.raspberrypi.local
   - Prowlarr: https://prowlarr.raspberrypi.local
   - Lidarr: https://lidarr.raspberrypi.local
   - Komga: https://komga.raspberrypi.local
   - Traefik Dashboard: https://traefik.raspberrypi.local

5. Los certificados SSL se generarán automáticamente mediante Let's Encrypt.

## Estructura de Directorios

```
/data
  /plex
  /sonarr
  /radarr
  /lidarr
  /transmission
  /jackett
  /prowlarr
  /bazarr
  /tautulli
  /overseerr
  /komga
  /media
    /movies
    /series
    /music
    /mangas
```

## Mantenimiento

Para actualizar todos los servicios:
```bash
docker-compose pull
docker-compose up -d
```

Para ver los logs:
```bash
docker-compose logs -f
```

## Solución de Problemas

Si encuentras problemas con los certificados SSL:
1. Verifica que los puertos 80 y 443 estén abiertos
2. Asegúrate de que el dominio esté correctamente configurado
3. Revisa los logs de Traefik: `docker-compose logs traefik`

## Contribuir

Las contribuciones son bienvenidas. Por favor, abre un issue o envía un pull request.

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo LICENSE para más detalles. 