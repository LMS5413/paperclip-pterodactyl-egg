FROM ghcr.io/paperclipai/paperclip:latest

USER root

RUN usermod -l container -d /home/container -m node \
 && groupmod -n container node \
 && mkdir -p /home/container \
 && chown -R container:container /home/container

ENV USER=container \
    HOME=/home/container \
    PAPERCLIP_HOME=/home/container \
    PAPERCLIP_CONFIG=/home/container/instances/default/config.json

WORKDIR /home/container

COPY --chown=container:container --chmod=755 entrypoint.sh /entrypoint.sh

USER container

ENTRYPOINT ["/entrypoint.sh"]
CMD ["node", "--import", "/app/server/node_modules/tsx/dist/loader.mjs", "/app/server/dist/index.js"]