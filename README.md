# shell.tools.public

Outils shell AXYRIOS pour sauvegarder des configurations dans Git et mettre à jour un projet Docker Compose.

Les **13 scripts d'origine** sont conservés sans modification dans `legacy/gitlab/`, depuis [CoreDockWorker/coredockworker.tools.public](https://gitlab.com/CoreDockWorker/coredockworker.tools.public), commit `3fdfad6f23f3d8fad0fc064142b8f1ba4b276b1d`. Le dépôt source reste intact. Cette copie conserve leur provenance ; aucune nouvelle licence n'est attribuée aux scripts historiques.

## Outils maintenus

```bash
# Sauvegarder les chemins autorisés, puis rebaser et pousser sans forcer
bash tools.gitpush.simple.sh --repo /chemin/configuration --include docker-compose.yml --include conf
# Mettre à jour seulement un service
bash tools.docker-compose.update.simple.sh --project-dir /chemin/projet --service application
```

La sauvegarde Git compare les changements avant de créer un commit. Elle utilise l'accès déjà configuré pour le remote, sans connexion SSH spécifique à GitLab, sans modification de la configuration Git globale et sans téléchargement de son propre script. Sans `--include`, elle ajoute seulement les fichiers déjà suivis. Un contrôle refuse les chemins de données/secrets et les secrets reconnaissables ; il ne remplace pas la revue des fichiers destinés à être publiés.

La mise à jour Compose conserve les volumes, ne fait pas de `down`, de purge Docker ni de suppression des autres services. Avec `--service`, elle utilise `--no-deps`. Une erreur de validation ou de téléchargement arrête l'exécution. Elle utilise l'image déclarée dans Compose : une version fixée reste fixée ; changer sa version exige de modifier la configuration. `--build` est réservé aux projets construisant une image locale.

Les sauvegardes et contrôles métier sont à réaliser dans un script propre à chaque application, avant et après l'appel de l'outil Compose. Aucun cron n'est créé automatiquement. Les scripts historiques sont des références, notamment leurs anciennes opérations `down`, auto-téléchargements et ajouts de cron ; ils ne sont pas les points d'entrée maintenus.

Prérequis : Bash, Git, Python 3 ; Docker Compose pour la maintenance Docker. `flock`, lorsqu'il est disponible, sérialise les synchronisations Git.

Tests : `python3 -m unittest discover -s tests -v`.
