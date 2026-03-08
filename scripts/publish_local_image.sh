#!/usr/bin/env bash

set -euo pipefail

registry_name="${REGISTRY_NAME:-local-registry}"
registry_port="${REGISTRY_PORT:-5001}"
source_image="${SOURCE_IMAGE:-devops-intern-final:latest}"
target_image="${TARGET_IMAGE:-localhost:${registry_port}/devops-intern-final:latest}"

if docker ps --format '{{.Names}}' | rg -x "${registry_name}" >/dev/null; then
  :
elif docker ps -a --format '{{.Names}}' | rg -x "${registry_name}" >/dev/null; then
  docker start "${registry_name}" >/dev/null
else
  docker run -d -p "${registry_port}:5000" --restart unless-stopped --name "${registry_name}" registry:2 >/dev/null
fi

docker build -t "${source_image}" .
docker tag "${source_image}" "${target_image}"
docker push "${target_image}"

printf 'Published %s\n' "${target_image}"
