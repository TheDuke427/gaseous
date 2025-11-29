ARG BUILD_FROM=ghcr.io/home-assistant/{arch}-base:latest
FROM $BUILD_FROM

# Install dependencies (Alpine uses apk)
RUN apk add --no-cache \
    git \
    curl \
    python3 \
    py3-pip \
    nodejs \
    npm

# Install Puter
RUN git clone https://github.com/HeyPuter/puter.git /opt/puter
WORKDIR /opt/puter

RUN npm install --omit=dev

EXPOSE 4100

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
