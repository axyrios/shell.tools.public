#!/usr/bin/env bash
set -euo pipefail

project_dir=.
compose_file=docker-compose.yml
project_name=
services=()
build=0
while (($#)); do
  case "$1" in
    --project-dir) project_dir=$2; shift 2 ;;
    --file) compose_file=$2; shift 2 ;;
    --project-name) project_name=$2; shift 2 ;;
    --service) services+=("$2"); shift 2 ;;
    --build) build=1; shift ;;
    --help) echo "Usage: $0 [--project-dir DIR] [--file FILE] [--project-name NAME] [--service NAME ...] [--build]"; exit 0 ;;
    *) echo "Option inconnue: $1" >&2; exit 2 ;;
  esac
done
cd -- "$project_dir"
project_dir=$PWD
if docker compose version >/dev/null 2>&1; then
  compose=(docker compose)
elif command -v docker-compose >/dev/null; then
  compose=(docker-compose)
else
  echo "Docker Compose est requis" >&2; exit 1
fi
compose+=(--project-directory "$project_dir" -f "$compose_file")
[[ -z $project_name ]] || compose+=(-p "$project_name")
"${compose[@]}" config --quiet
"${compose[@]}" pull "${services[@]}"
if ((build)); then
  "${compose[@]}" build --pull "${services[@]}"
fi
up=(up -d --pull never)
if ((${#services[@]})); then up+=(--no-deps); fi
"${compose[@]}" "${up[@]}" "${services[@]}"
echo "COMPOSE_UPDATE_OK services=${services[*]:-all}"
