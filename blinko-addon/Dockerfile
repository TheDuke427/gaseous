ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install MariaDB
RUN apk add --no-cache \
    mariadb \
    mariadb-client \
    curl \
    nodejs \
    npm

# Set up environment
ENV NODE_ENV=production

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
