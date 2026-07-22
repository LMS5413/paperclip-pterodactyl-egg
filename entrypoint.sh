#!/bin/sh
set -eu

export HOST="0.0.0.0"
export PORT="${SERVER_PORT:-3100}"

case "${OPENCODE_ALLOW_ALL_MODELS:-true}" in
    1|true|TRUE|yes|YES|on|ON)
        export OPENCODE_ALLOW_ALL_MODELS=true
        ;;
    *)
        export OPENCODE_ALLOW_ALL_MODELS=false
        ;;
esac

cd /home/container

if [ -z "${STARTUP:-}" ]; then
    echo "Error: the STARTUP environment variable is not set." >&2
    exit 1
fi

MODIFIED_STARTUP=$(printf '%s' "$STARTUP" | sed -e 's/{{/${/g' -e 's/}}/}/g')

echo ":/home/container$ $MODIFIED_STARTUP"
exec /bin/bash -c "$MODIFIED_STARTUP"
