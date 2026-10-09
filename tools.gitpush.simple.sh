#!/usr/bin/env bash
set -euo pipefail

repo=.
remote=origin
message="Sauvegarde automatique des configurations"
includes=()
while (($#)); do
  case "$1" in
    --repo) repo=$2; shift 2 ;;
    --remote) remote=$2; shift 2 ;;
    --message) message=$2; shift 2 ;;
    --include) includes+=("$2"); shift 2 ;;
    --help) echo "Usage: $0 [--repo DIR] [--remote origin] [--include PATH ...] [--message TEXT]"; exit 0 ;;
    *) echo "Option inconnue: $1" >&2; exit 2 ;;
  esac
done
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd -- "$repo"
git rev-parse --is-inside-work-tree >/dev/null
branch=$(git symbolic-ref --quiet --short HEAD) || { echo "Branche Git requise" >&2; exit 1; }
git_dir=$(git rev-parse --absolute-git-dir)
if command -v flock >/dev/null; then
  exec 9>"$git_dir/shell-tools-sync.lock"
  flock -w 120 9
fi
if [[ -n $(git ls-files --unmerged) ]]; then
  echo "Conflit Git à résoudre avant synchronisation" >&2; exit 1
fi
git config user.name >/dev/null || git config user.name "Sauvegarde configurations"
git config user.email >/dev/null || git config user.email "configuration-backup@localhost"
if ((${#includes[@]})); then
  git add --all -- "${includes[@]}"
else
  # Par défaut, seuls les fichiers déjà suivis sont ajoutés.
  git add -u
fi
python3 "$script_dir/tools.git.check-staged.py" --repo .
if ! git diff --cached --quiet; then
  git diff --cached --check
  git commit -m "$message"
else
  echo "Aucune modification à commiter"
fi
git fetch "$remote" "$branch"
git rebase "$remote/$branch"
git push "$remote" "HEAD:refs/heads/$branch"
[[ $(git rev-parse HEAD) == $(git rev-parse "$remote/$branch") ]]
echo "GIT_SYNC_OK branch=$branch revision=$(git rev-parse HEAD)"
