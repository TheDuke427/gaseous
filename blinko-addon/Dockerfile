ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install PostgreSQL 14
RUN apk add --no-cache \
    postgresql14 \
    postgresql14-contrib \
    curl \
    nodejs \
    npm

# Set up environment
ENV PGDATA=/data/postgres
ENV NODE_ENV=production

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
