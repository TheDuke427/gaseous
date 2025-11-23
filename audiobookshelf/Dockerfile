ARG BUILD_FROM
FROM ghcr.io/advplyr/audiobookshelf:latest AS audiobookshelf

FROM $BUILD_FROM

ENV LANG=C.UTF-8

# Install dependencies
RUN apk add --no-cache \
    nodejs \
    npm \
    ffmpeg \
    curl \
    tzdata

# Copy only the production files from audiobookshelf
COPY --from=audiobookshelf /prod/server /server
COPY --from=audiobookshelf /prod/client /client

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

WORKDIR /server
EXPOSE 80

CMD ["/run.sh"]
