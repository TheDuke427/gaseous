ARG BUILD_FROM=ghcr.io/advplyr/audiobookshelf:latest
FROM $BUILD_FROM

# Install bashio for Home Assistant integration
RUN apk add --no-cache bash curl

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Expose port (audiobookshelf uses port 80 internally)
EXPOSE 80

CMD ["/run.sh"]
