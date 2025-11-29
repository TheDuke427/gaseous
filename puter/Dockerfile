ARG BUILD_FROM=ghcr.io/home-assistant/{arch}-base:latest
FROM $BUILD_FROM

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

RUN apk add --no-cache \
    git \
    curl \
    python3 \
    py3-pip \
    nodejs \
    npm

# Clone Puter
RUN git clone https://github.com/HeyPuter/puter.git /opt/puter

WORKDIR /opt/puter

# Install ALL dependencies (including dev) so webpack build works
RUN npm install

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 4100

CMD [ "/run.sh" ]
