ARG BUILD_FROM
FROM lissy93/dashy:latest

# Install bashio and other dependencies for Home Assistant
RUN apk add --no-cache \
    bash \
    jq \
    curl

# Copy bashio
COPY --from=ghcr.io/hassio-addons/base:15.0.1 \
    /usr/bin/bashio \
    /usr/bin/bashio
COPY --from=ghcr.io/hassio-addons/base:15.0.1 \
    /usr/lib/bashio \
    /usr/lib/bashio

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

WORKDIR /app

CMD [ "/run.sh" ]
