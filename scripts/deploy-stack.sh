#!/usr/bin/env bash
# Despliega (o actualiza) el stack moodle-studio en el swarm.
#
#   scripts/deploy-stack.sh
#   SWARM_HOST=arkantu@192.168.0.105 scripts/deploy-stack.sh
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANAGER="${SWARM_HOST:-arkantu@192.168.0.105}"
DATAHOST="${STUDIO_DATA_HOST:-arkantu@192.168.0.80}"
REMOTE="${STUDIO_DEPLOY_DIR:-/home/arkantu/produccion/moodle-studio}"

echo "==> datos persistentes en $DATAHOST:/mnt/docker-ssd/moodle-studio/jobs"
ssh -o StrictHostKeyChecking=no "$DATAHOST" \
  'sudo mkdir -p /mnt/docker-ssd/moodle-studio/jobs && sudo chown -R 1000:1000 /mnt/docker-ssd/moodle-studio'

echo "==> stack a $MANAGER:$REMOTE"
ssh -o StrictHostKeyChecking=no "$MANAGER" "mkdir -p $REMOTE"
rsync -az "$HERE/deploy/studio.yml" "$MANAGER:$REMOTE/studio.yml"

ssh -o StrictHostKeyChecking=no "$MANAGER" \
  "cd $REMOTE && docker stack deploy -c studio.yml moodle-studio"

echo "==> estado"
ssh -o StrictHostKeyChecking=no "$MANAGER" \
  "docker stack services moodle-studio --format 'table {{.Name}}\t{{.Replicas}}\t{{.Ports}}'"
