FROM ghcr.io/paperclipai/paperclip:latest

ARG USER_UID=1000
ARG USER_GID=1000

USER root

RUN apt-get update \
 && apt-get install -y --no-install-recommends libnss-wrapper \
 && rm -rf /var/lib/apt/lists/*

RUN usermod -l container -d /home/container -m node -g ${USER_GID} -u ${USER_UID} \
 && groupmod -n container node \
 && mkdir -p /home/container \
 && chown -R container:container /home/container

RUN find /app/node_modules/.pnpm \
        -type f \
        -path '*/node_modules/@embedded-postgres/linux-*/native/lib/lib*.so.*' \
        -exec /bin/sh -c '\
            for source do \
                directory=${source%/*}; \
                filename=${source##*/}; \
                alias=$(printf "%s\n" "$filename" | sed -E "s/^(lib.+\\.so\\.[0-9]+)\\.[0-9]+(\\.[0-9]+)?$/\\1/"); \
                if [ "$alias" != "$filename" ] && [ ! -e "$directory/$alias" ] && [ ! -L "$directory/$alias" ]; then \
                    ln -s "$filename" "$directory/$alias"; \
                fi; \
            done \
        ' /bin/sh {} +


RUN find /app/node_modules/.pnpm \
        -type f \
        -path '*/node_modules/@embedded-postgres/linux-*/native/bin/*' \
        -exec chmod 755 {} + \
 && find /app/node_modules/.pnpm \
        -type f \
        -path '*/node_modules/embedded-postgres/dist/index.js' \
        -exec sed -i "/await fs.chmod(postgres, '755');/d; /await fs.chmod(initdb, '755');/d" {} +


RUN native_helper=/app/packages/db/src/embedded-postgres-native.ts \
 && sed -i '/const aliasPath = path.join(libDir, aliasName);/a\    if (await pathExists(aliasPath)) continue;' "$native_helper" \
 && grep -Fq 'if (await pathExists(aliasPath)) continue;' "$native_helper"

ENV USER=container \
    HOME=/home/container \
    PAPERCLIP_HOME=/home/container \
    PAPERCLIP_CONFIG=/home/container/instances/default/config.json

WORKDIR /home/container

COPY --chown=container:container --chmod=755 entrypoint.sh /entrypoint.sh

USER container

ENTRYPOINT []
CMD ["/bin/bash", "/entrypoint.sh"]
