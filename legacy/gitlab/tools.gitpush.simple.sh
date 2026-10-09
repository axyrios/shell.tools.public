#!/usr/bin/env bash
set -e # Arrête le script immédiatement si une commande échoue

# curl -O https://gitlab.com/CoreDockWorker/coredockworker.tools.public/raw/master/tools.gitpush.simple.sh && chmod +x tools.gitpush.simple.sh;


# --- Définitions ---
# Couleurs pour les messages
yellow='\033[1;33m'
green='\033[0;32m'
red='\033[0;31m'
reset='\033[0m'

# Nom de la branche actuelle (ex: main, master, develop)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# --- Configuration Git ---
check_and_set_git_config() {
    local config_key=$1
    local config_value=$2

    if git config --get "$config_key" >/dev/null 2>&1; then
        echo -e "${green}# La valeur '$config_key' est déjà définie : $(git config --get "$config_key")${reset}"
    else
        git config --global "$config_key" "$config_value"
        echo -e "${green}# La valeur '$config_key' a été définie : $(git config --get "$config_key")${reset}"
    fi
}

echo -e "${yellow}--- Étape 1: Vérification de la configuration Git ---${reset}"
check_and_set_git_config "pull.rebase" "true"
check_and_set_git_config "user.email" "$(whoami)@$HOSTNAME"
check_and_set_git_config "user.name" "$(whoami)@$HOSTNAME"
echo ""

# --- Vérification de la connexion SSH ---
echo -e "${yellow}--- Étape 2: Vérification de la connexion SSH à GitLab ---${reset}"
if ! ssh-add -l >/dev/null 2>&1; then
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa
fi
ssh -T git@gitlab.com
echo ""

# --- Logique de synchronisation Git corrigée ---
echo -e "${yellow}--- Étape 3: Sauvegarde des modifications locales ---${reset}"
git add --all
echo "Fichiers locaux ajoutés à l'index."

if ! git diff-index --quiet HEAD --; then
    echo "Création du commit..."
    git commit --author="$(whoami) <$(whoami)@$HOSTNAME>" -m "AUTO-COMMIT: $(whoami)@$HOSTNAME $(TZ='Europe/Paris' date +'%Y-%m-%d %H:%M')"
else
    echo "Aucune modification à commiter, l'espace de travail est propre."
fi
echo ""

echo -e "${yellow}--- Étape 4: Synchronisation avec le dépôt distant ---${reset}"
echo "Récupération des changements distants (pull --rebase)..."
git pull origin "$CURRENT_BRANCH"

echo "Envoi des modifications vers le dépôt distant (push)..."
git push origin "$CURRENT_BRANCH"
echo ""

# --- NOUVELLE ÉTAPE DE VÉRIFICATION ---
echo -e "${yellow}--- Étape 5: Vérification finale du statut du dépôt ---${reset}"
GIT_STATUS=$(git status --porcelain)

if [ -z "$GIT_STATUS" ]; then
    echo -e "${green}✅ Dépôt propre. Synchronisation terminée avec succès !${reset}"
else
    echo -e "${red}❌ ERREUR : Le dépôt n'est pas propre après la synchronisation.${reset}"
    echo -e "Il reste des modifications non validées ou des conflits. Statut Git :"
    git status
    exit 1 # Termine le script avec un code d'erreur
fi