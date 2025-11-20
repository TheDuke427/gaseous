ARG BUILD_FROM
FROM $BUILD_FROM

# Install dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    bash

# Install xdccget
RUN pip3 install --no-cache-dir xdccget --break-system-packages

# Create directories
RUN mkdir -p /data/downloads /data/config

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

EXPOSE 8080

CMD [ "/run.sh" ]
