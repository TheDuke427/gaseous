ARG BUILD_FROM
FROM ghcr.io/advplyr/audiobookshelf:latest AS audiobookshelf

FROM $BUILD_FROM

ENV LANG C.UTF-8

# Install dependencies
RUN apk add --no-cache \
    nodejs \
    npm \
    ffmpeg \
    curl \
    tzdata

# Copy audiobookshelf from official image
COPY --from=audiobookshelf /server /server
COPY --from=audiobookshelf /client /client
COPY --from=audiobookshelf /usr/local/bin/node /usr/local/bin/node
COPY --from=audiobookshelf /usr/local/lib/node_modules /usr/local/lib/node_modules

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

WORKDIR /server
EXPOSE 80

CMD ["/run.sh"]
