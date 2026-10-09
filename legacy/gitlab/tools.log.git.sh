#!/usr/bin/env bash

# Définir les codes de couleur
yellow='\033[1;33m'
reset='\033[0m'

# Définir une fonction pour afficher les commentaires en jaune
function print_comment {
    echo -e "${yellow}$1${reset}"
}

# Afficher un commentaire
print_comment "Téléchargement du script..."
curl -O https://gitlab.com/CoreDockWorker/coredockworker.tools.public/raw/master/tools.log.git.sh
chmod +x tools.log.git.sh

# Définir les variables de chemin et d'information
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
if [ -z "$SCRIPT_DIR" ]; then
    print_comment "Erreur : Impossible de déterminer le répertoire du script."
    exit 1
fi

THIS="${SCRIPT_DIR}/$(basename "${BASH_SOURCE[0]}")"
HOSTNAME=$(hostname)
AUTHOR="$(whoami) <$(whoami)@${HOSTNAME}>"
DATEHOUR="$(TZ="Europe/Paris" date +'%Y-%m-%d %H-%M %Z %A')"
LOGDIR="${HOSTNAME}/$(whoami)"

# Afficher les informations pour le débogage
print_comment "Auteur : $AUTHOR"
print_comment "Date et heure : $DATEHOUR"
print_comment "Répertoire de log : $LOGDIR"
print_comment "Chemin du script : $THIS"

# Créer le répertoire temporaire et cloner le dépôt Git
mkdir -p /tmp/ && cd /tmp/
if ! git clone git@gitlab.com:environnements/tools.log.git.sh.git; then
    print_comment "Erreur : Impossible de cloner le dépôt Git. Vérifiez votre accès et votre connexion."
    exit 1
fi

# Préparer le fichier de log
cd tools.log.git.sh && mkdir -p $LOGDIR
LOGFILE="/tmp/tools.log.git.sh/${LOGDIR}/${DATEHOUR}.log"

# Enregistrer la configuration crontab actuelle
print_comment "Enregistrement de la configuration crontab..."
echo "$(crontab -l)" >> "${LOGFILE}"
echo "" >> "${LOGFILE}"
echo "===================================" >> "${LOGFILE}"
echo "" >> "${LOGFILE}"

# Parcourir tous les répertoires Git et enregistrer leur statut
for dir in $(find $DIR -name ".git")
do 
    cd ${dir%/*}
    print_comment "Traitement du répertoire : $PWD"
    echo $PWD >> "${LOGFILE}"
    echo "$(git status)" >> "${LOGFILE}"
    echo "" >> "${LOGFILE}"
    echo "===================================" >> "${LOGFILE}"
    echo "" >> "${LOGFILE}"
done

# Commit et push des changements
cd "/tmp/tools.log.git.sh"
git add --all
git commit --author="$AUTHOR" -am "$(whoami)@$HOSTNAME $(TZ="Europe/Paris" date +'%Y-%m-%d %H:%M %Z %A')"
if ! git push origin master; then
    print_comment "Erreur : Impossible de pousser les modifications. Vérifiez votre accès au dépôt distant."
    exit 1
fi

# Nettoyer le répertoire temporaire
rm -rf "/tmp/tools.log.git.sh"


# Charger la librairie pour insérer dans crontab
timestamp=`date +%Y%m%d%H%M%S`
curl -s https://gitlab.com/CoreDockWorker/coredockworker.tools.public/raw/master/tools.function.insertcrontab.sh -o /tmp/.myscript.${timestamp}.tmp
source /tmp/.myscript.${timestamp}.tmp
rm -f /tmp/.myscript.${timestamp}.tmp

# Installer et mettre à jour le crontab
insertcrontab "${THIS}"