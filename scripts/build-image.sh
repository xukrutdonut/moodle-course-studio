#!/usr/bin/env bash
# Construye la imagen arm64 de Moodle Course Studio en el nodo con Docker
# (192.168.0.80) y la publica en el registry del swarm (192.168.0.101:5555).
#
#   scripts/build-image.sh            # tag 1.0.0
#   STUDIO_TAG=1.0.1 scripts/build-image.sh
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REG="${STUDIO_REGISTRY:-192.168.0.101:5555}"
NS="${STUDIO_NAMESPACE:-moodle}"
TAG="${STUDIO_TAG:-1.0.0}"
HOST="${STUDIO_BUILD_HOST:-arkantu@192.168.0.80}"
REMOTE="${STUDIO_BUILD_DIR:-/home/arkantu/build/moodle-course-studio}"

echo "==> sincronizando fuentes a $HOST:$REMOTE"
ssh -o StrictHostKeyChecking=no "$HOST" "mkdir -p $REMOTE"
rsync -az --delete --exclude .git --exclude data --exclude '*.log'   "$HERE/" "$HOST:$REMOTE/"

echo "==> build $REG/$NS/studio:$TAG"
ssh -o StrictHostKeyChecking=no "$HOST" \
  "cd $REMOTE && docker build -t $REG/$NS/studio:$TAG . && docker push $REG/$NS/studio:$TAG"

echo "Hecho: $REG/$NS/studio:$TAG"
