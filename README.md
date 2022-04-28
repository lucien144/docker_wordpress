# Dockerized Wordpress
Dockerized Bedrock (Wordpress) with Nginx, MySQL, Imgproxy and S3 backups running on Traefik.

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

```.env
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