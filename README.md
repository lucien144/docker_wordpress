# Dockerized Wordpress
Dockerized [Bedrock (Wordpress)](https://roots.io/bedrock/) with Nginx, MySQL, [Imgproxy](https://imgproxy.net/) and S3 backups running on [Traefik](https://github.com/traefik/traefik).

## Run

```bash
$ ./deploy.sh

Usage: deploy.sh -w
  -w: rebuild wordpress container & image, only for production

1) Production - Removes the shared volume.
2) Local - For local development only.
3) Quit
```

## Env

### `.env`

```ini
PROJECT_NAME='project' # Name of the project. Used to name the docker containers.
VOLUME='shared_volume' # For production -> creates the shared volume.
VOLUME='./wordpress' # For local development, binds the directory to a volume

PORT_IMGPROXY=16001 # Traefik port.
PORT_NGINX=16010 # Traefik port.
PORT_MYSQL=16020 # Traefik port.
PORT_ADMINER=16030 # Traefik port.

HOST_IMAGES='i.project.test' # Host of the Imgproxy.
HOST_WORDPRESS='cms.project.test' # Host of the Wordpress installation.
HOST_ADMINER='adminer.project.test' # Host of the Adminer.

ADMINER_USER='...' # Adminer username.
ADMINER_PASSWORD='...' # Adminer password.
```

## Adminer
If you want to put basic HTTP authentication in front of Adminer, you must uncomment these lines in `docker-compose.yaml`:

```ini
      - traefik.http.routers.${PROJECT_NAME}__adminer.middlewares=${PROJECT_NAME}__adminer-auth
      # echo $(htpasswd -nb user password) | sed -e s/\\$/\\$\\$/g
      - traefik.http.middlewares.${PROJECT_NAME}__adminer-auth.basicauth.users=${ADMINER_USER}:${ADMINER_PASSWORD}
```

Then generate the username/password and update them in the `.env` file.

```bash
$ echo $(htpasswd -nb user password) | sed -e s/\\$/\\$\\$/g
```