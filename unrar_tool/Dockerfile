ARG BUILD_FROM
FROM $BUILD_FROM

# Add edge repository and install unrar
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache \
    unrar \
    bash \
    python3 \
    py3-pip

# Verify unrar is installed
RUN which unrar || echo "Warning: unrar not found in PATH"

# Copy the extraction script
COPY run.sh /
COPY extract.py /

# Make scripts executable
RUN chmod a+x /run.sh /extract.py

CMD [ "/run.sh" ]
