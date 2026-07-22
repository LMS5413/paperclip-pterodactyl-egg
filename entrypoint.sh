#!/bin/sh
set -eu

CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

if ! getent passwd "$CURRENT_UID" >/dev/null 2>&1; then
    NSS_WRAPPER_DIR=$(mktemp -d)
    export NSS_WRAPPER_PASSWD="$NSS_WRAPPER_DIR/passwd"
    export NSS_WRAPPER_GROUP="$NSS_WRAPPER_DIR/group"

    cp /etc/passwd "$NSS_WRAPPER_PASSWD"
    cp /etc/group "$NSS_WRAPPER_GROUP"

    NSS_WRAPPER_LIBRARY=$(find /usr/lib -name libnss_wrapper.so -print -quit)
    if [ -z "$NSS_WRAPPER_LIBRARY" ]; then
        echo "Error: libnss_wrapper.so was not found." >&2
        exit 1
    fi

    export LD_PRELOAD="$NSS_WRAPPER_LIBRARY${LD_PRELOAD:+:$LD_PRELOAD}"
fi

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
