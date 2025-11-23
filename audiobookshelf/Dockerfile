ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install required packages
RUN apk add --no-cache \
    nodejs \
    npm \
    ffmpeg \
    curl \
    tzdata

# Set working directory
WORKDIR /app

# Download and extract Audiobookshelf
ARG AUDIOBOOKSHELF_VERSION=2.17.4
RUN curl -fsSL https://github.com/advplyr/audiobookshelf/releases/download/v${AUDIOBOOKSHELF_VERSION}/audiobookshelf-${AUDIOBOOKSHELF_VERSION}-linux-x64.tar.gz \
    | tar xzf - -C /app

# Create necessary directories
RUN mkdir -p /config /metadata /audiobooks /podcasts

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Expose port
EXPOSE 8000

CMD ["/run.sh"]
