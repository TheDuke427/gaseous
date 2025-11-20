ARG BUILD_FROM
FROM $BUILD_FROM

# Install build dependencies and runtime requirements
RUN apk add --no-cache \
    bash \
    python3 \
    py3-pip \
    make \
    g++ \
    wget

# Download and compile unrar from source
RUN cd /tmp && \
    wget https://www.rarlab.com/rar/unrarsrc-7.1.1.tar.gz && \
    tar -xzf unrarsrc-7.1.1.tar.gz && \
    cd unrar && \
    make && \
    install -v -m755 unrar /usr/bin && \
    cd / && \
    rm -rf /tmp/unrar /tmp/unrarsrc-7.1.1.tar.gz

# Remove build dependencies to reduce image size
RUN apk del make g++ wget

# Copy the extraction script
COPY run.sh /
COPY extract.py /

# Make scripts executable
RUN chmod a+x /run.sh /extract.py

CMD [ "/run.sh" ]
