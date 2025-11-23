ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

# Install dependencies
RUN apk add --no-cache \
    nodejs \
    npm \
    ffmpeg \
    curl \
    git \
    python3 \
    make \
    g++ \
    tzdata

# Set working directory
WORKDIR /app

# Clone audiobookshelf
ARG AUDIOBOOKSHELF_VERSION=v2.17.4
RUN git clone --branch ${AUDIOBOOKSHELF_VERSION} --depth 1 https://github.com/advplyr/audiobookshelf.git /app

# Build client
WORKDIR /app/client
RUN npm ci && npm cache clean --force
RUN npm run generate

# Build server
WORKDIR /app
RUN npm ci --only=production && npm cache clean --force

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

WORKDIR /app
EXPOSE 80

CMD ["/run.sh"]
