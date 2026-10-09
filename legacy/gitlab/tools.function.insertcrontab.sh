#!/usr/bin/env bash

# Définir les codes de couleur
green='\033[0;32m'
red='\033[0;31m'
reset='\033[0m'

# Fonction pour afficher des messages en vert
function print_success {
    echo -e "${green}$1${reset}"
}

# Fonction pour afficher des messages en rouge
function print_error {
    echo -e "${red}$1${reset}"
}

function insertcrontab () {
    script="$1"
    commandsearch="#$1"
    DIR="$(dirname "$script")"
    LAUNCH="$(basename "$script")"
    
    print_success "Insertion dans crontab : $script"
    print_success "Répertoire : $DIR"
    print_success "Script à lancer : $LAUNCH"
    
    if [ ! -d "$DIR" ]; then
        print_error "Erreur : Le répertoire du script ($DIR) n'existe pas ou n'est pas accessible."
        return 1
    fi
    
    command="cd \"${DIR}\" && \"${DIR}/${LAUNCH}\" ${commandsearch}"
    
    print_success "Commande à exécuter : $command"
    
    job="0 */8 * * * ${command}"
    if (crontab -l 2>/dev/null | grep -v -F "$commandsearch"; echo "$job") | crontab -; then
        print_success "Crontab mis à jour avec succès."
    else
        print_error "Erreur lors de la mise à jour du crontab."
        return 1
    fi
}
export -f insertcrontab