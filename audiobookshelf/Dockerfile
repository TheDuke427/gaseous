ARG BUILD_FROM=ghcr.io/advplyr/audiobookshelf:latest
FROM $BUILD_FROM

# Install bashio for Home Assistant
RUN apk add --no-cache bash curl

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

WORKDIR /
EXPOSE 80

CMD ["/run.sh"]
