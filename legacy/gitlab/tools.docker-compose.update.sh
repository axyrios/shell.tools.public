#!/usr/bin/env bash

curl -O https://gitlab.com/CoreDockWorker/coredockworker.tools.public/raw/master/tools.docker-compose.update.sh && chmod +x tools.docker-compose.update.sh
# ./tools.docker-compose.update.sh

#read -p "mettre à jour le docker-compose (y/n)?" choice
#	case "$choice" in 
#	  y|Y ) echo "yes" && 
        docker-compose pull
        docker-compose build --pull --no-cache
        docker-compose down
        docker-compose up -d --remove-orphans
#	  ;;
#	  n|N ) echo "no" ;;
#	  * ) echo "invalid" ;;
#	esac

# chargement librairie insert crontab
# This directory path
DIR="$(cd "$(dirname "$0")" && pwd -P)"
# Full path of this script
THIS="${DIR}/$(basename "$0")"
timestamp=`date +%Y%m%d%H%M%S`
curl -s https://gitlab.com/CoreDockWorker/coredockworker.tools.public/raw/master/tools.function.insertcrontab.sh -o /tmp/.myscript.${timestamp}.tmp
source /tmp/.myscript.${timestamp}.tmp
rm -f /tmp/.myscript.${timestamp}.tmp

# install and update crontab atv_cron
insertcrontab "${THIS}"