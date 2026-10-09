#!/usr/bin/env bash

curl -O https://gitlab.com/CoreDockWorker/coredockworker.tools.public/raw/master/tools.docker-compose.update.simple.sh && chmod +x tools.docker-compose.update.simple.sh
# ./tools.docker-compose.update.sh

#read -p "mettre à jour le docker-compose (y/n)?" choice
#	case "$choice" in 
#	  y|Y ) echo "yes" && 
        docker-compose pull
        docker-compose build --pull
        docker-compose down
        docker-compose up -d --remove-orphans
#	  ;;
#	  n|N ) echo "no" ;;
#	  * ) echo "invalid" ;;
#	esac
