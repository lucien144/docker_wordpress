#!/bin/bash

# https://stackoverflow.com/questions/19331497/set-environment-variables-from-file-of-key-value-pairs/30969768#30969768
set -o allexport
source .env
set +o allexport

echo "Usage: deploy.sh -w"
echo "  -w: rebuild wordpress"
echo ""

PS3='What do you want to deploy: '
options=("Production" "Local" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Production")
            echo "Deploying production environment..."

            chmod -Rf 0777 ./volumes/wordpress-uploads/

            # Remove all containers
            docker rm -f "${PROJECT_NAME}__wordpress" "${PROJECT_NAME}__nginx"

            # Remove shared volume
            docker volume rm "${PROJECT_NAME}_${VOLUME}"

            while getopts 'wfa' c
            do
              case $c in
                w)
                  # Remove WP image to rebuild it
                  echo "-> Rebuilding Wordpress"
                  docker rmi -f "${PROJECT_NAME}_wordpress" "${PROJECT_NAME}_nginx"
                  ;;
                *) ;;
              esac
            done

            git config pull.ff only
            git pull --recurse-submodules
            docker-compose --profile production -p "$PROJECT_NAME" up -d --force-recreate --remove-orphans --build
            docker exec -it "${PROJECT_NAME}__wordpress" composer install

            echo -e "\n-------"
            echo -e "Status:"
            echo -e "-------"
            curl -ko /dev/null -Isw '%{http_code}\n' "https://${HOST_WORDPRESS}/" | grep -q "200" && echo -e "\033[0;32m[OK] WORDPRESS is running at ... ${HOST_WORDPRESS}" || echo -e "\033[0;31m[DOWN] WORDPRESS is not running\!"
            curl -ko /dev/null -Isw '%{http_code}\n' "https://${HOST_ADMINER}/" | grep -q "200" && echo -e "\033[0;32m[OK] ADMINER is running at ... ${HOST_ADMINER}" || echo -e "\033[0;31m[DOWN] ADMINER is not running\!"
            curl -ko /dev/null -Isw '%{http_code}\n' "https://${HOST_IMAGES}/" | grep -q "200" && echo -e "\033[0;32m[OK] IMGPROXY is running at ... ${HOST_IMAGES}" || echo -e "\033[0;31m[DOWN] IMGPROXY is not running\!"

            break
            ;;
        "Local")
            echo "Deploying local environment..."
            export VOLUME="./wordpress"

            # Remove all containers
            docker rm -f "${PROJECT_NAME}__wordpress" "${PROJECT_NAME}__nginx" "${PROJECT_NAME}__adminer"

            git config pull.ff only
            git pull --recurse-submodules
            docker-compose -p "$PROJECT_NAME" up -d --force-recreate --remove-orphans
            docker exec -it "${PROJECT_NAME}__wordpress" composer install

            echo -e "\n-------"
            echo -e "Status:"
            echo -e "-------"
            curl -ko /dev/null -Isw '%{http_code}\n' "https://${HOST_WORDPRESS}/" | grep -q "200" && echo -e "\033[0;32m[OK] WORDPRESS is running at ... ${HOST_WORDPRESS}" || echo -e "\033[0;31m[DOWN] WORDPRESS is not running\!"
            curl -ko /dev/null -Isw '%{http_code}\n' "https://${HOST_ADMINER}/" | grep -q "200" && echo -e "\033[0;32m[OK] ADMINER is running at ... ${HOST_ADMINER}" || echo -e "\033[0;31m[DOWN] ADMINER is not running\!"
            curl -ko /dev/null -Isw '%{http_code}\n' "https://${HOST_IMAGES}/" | grep -q "200" && echo -e "\033[0;32m[OK] IMGPROXY is running at ... ${HOST_IMAGES}" || echo -e "\033[0;31m[DOWN] IMGPROXY is not running\!"

            break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
