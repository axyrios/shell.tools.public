#!/usr/bin/env bash

# Définir la couleur jaune
yellow='\033[1;33m'
reset='\033[0m'

# Télécharger le script et le rendre exécutable
echo -e "${yellow}Téléchargement du script...${reset}"
curl -O https://gitlab.com/CoreDockWorker/coredockworker.tools.public/raw/master/tools.gitpush.sh
echo -e "${yellow}Rendre le script exécutable...${reset}"
chmod +x tools.gitpush.sh

# Définir les variables de chemin
echo -e "${yellow}Définition des variables de chemin...${reset}"
DIR="$(cd "$(dirname "$0")" && pwd -P)"
THIS="${DIR}/$(basename "$0")"

# Exécuter les commandes Git
echo -e "${yellow}Récupération des dernières modifications...${reset}"
git fetch --all

echo -e "${yellow}Fusion des changements distants...${reset}"
git pull origin $(git rev-parse --abbrev-ref HEAD)

echo -e "${yellow}Ajout de tous les fichiers modifiés...${reset}"
git add --all

echo -e "${yellow}Création du commit...${reset}"
git commit --author="$(whoami) <$(whoami)@$HOSTNAME>" -am "$(whoami)@$HOSTNAME $(TZ="Europe/Paris" date +'%Y-%m-%d %H:%M %Z %A')"

echo -e "${yellow}Envoi des modifications vers le dépôt distant...${reset}"
git push origin $(git rev-parse --abbrev-ref HEAD)

echo -e "${yellow}Récupération finale des changements distants...${reset}"
git pull origin $(git rev-parse --abbrev-ref HEAD)


withoutlog=0;


for ((i=1;i<=$#;i++)); 
do
  if [ $1 = "--withoutlog" ]; 
  then ((i++)) 
    withoutlog=1;
  fi
done;
if [ $withoutlog = 0 ]; then
# avec log
    curl -O https://gitlab.com/CoreDockWorker/coredockworker.tools.public/raw/master/tools.log.git.sh
    chmod +x tools.log.git.sh
    ./tools.log.git.sh
    
    # chargement librairie insert crontab
    timestamp=`date +%Y%m%d%H%M%S`
    curl -s https://gitlab.com/CoreDockWorker/coredockworker.tools.public/raw/master/tools.function.insertcrontab.sh -o /tmp/.myscript.${timestamp}.tmp
    source /tmp/.myscript.${timestamp}.tmp
    rm -f /tmp/.myscript.${timestamp}.tmp
    
    # install and update crontab atv_cron
    insertcrontab "${THIS}"
    exit 0
fi
# SANS LOG
    # chargement librairie insert crontab
    timestamp=`date +%Y%m%d%H%M%S`
    curl -s https://gitlab.com/CoreDockWorker/coredockworker.tools.public/raw/master/tools.function.insertcrontab.sh -o /tmp/.myscript.${timestamp}.tmp
    source /tmp/.myscript.${timestamp}.tmp
    rm -f /tmp/.myscript.${timestamp}.tmp
    
    # install and update crontab atv_cron
    insertcrontab "${THIS} --withoutlog"
