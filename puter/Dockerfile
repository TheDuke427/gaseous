ARG BUILD_FROM=ghcr.io/hassio-addons/base-debian:stable
FROM $BUILD_FROM

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git curl python3 python3-pip nodejs npm && \
    rm -rf /var/lib/apt/lists/*

# Install Puter
RUN git clone https://github.com/HeyPuter/puter.git /opt/puter
WORKDIR /opt/puter

RUN npm install --omit=dev

# Expose default Puter port
EXPOSE 4100

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
