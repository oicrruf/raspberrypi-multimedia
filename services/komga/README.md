# Komga - Servidor de Manga

Komga es un servidor de manga que permite organizar y leer tus mangas desde cualquier dispositivo.

## Configuración

1. Copia el archivo `.env.example` a `.env`:
```bash
cp .env.example .env
```

2. Edita el archivo `.env` con tus configuraciones:
- `KOMGA_PORT`: Puerto para acceder a la interfaz web
- `KOMGA_ADMIN_USER`: Usuario administrador
- `KOMGA_ADMIN_PASSWORD`: Contraseña del administrador
- `MANGAS_PATH`: Ruta donde se almacenarán tus mangas

## Uso

1. Inicia el servicio:
```bash
docker-compose up -d
```

2. Accede a la interfaz web en `http://localhost:${KOMGA_PORT}`

3. Inicia sesión con las credenciales configuradas

4. Para agregar mangas:
   - Ve a "Libraries" y crea una nueva biblioteca
   - Sube tus archivos CBZ/CBR o apunta a una carpeta existente
   - Komga indexará automáticamente tus mangas

## Características

- Soporte para formatos CBZ y CBR
- Interfaz web responsive
- Lectura en línea
- Organización por series y colecciones
- Búsqueda avanzada
- Soporte para múltiples idiomas

## Integración con otros servicios

Komga puede integrarse con:
- Plex (usando el plugin Plex-Komga)
- Jellyfin (usando el plugin Jellyfin-Komga)
- Kodi (usando el addon Komga) 