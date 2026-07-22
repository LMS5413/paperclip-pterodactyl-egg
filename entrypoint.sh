#!/bin/sh
set -eu

export HOST="${SERVER_IP:-0.0.0.0}"
export PORT="${SERVER_PORT:-3100}"
export OPENCODE_ALLOW_ALL_MODELS=$([[ "$OPENCODE_ALLOW_ALL_MODELS" == "1" ]] && echo "true" || echo "false")

cd /home/container
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

${MODIFIED_STARTUP}