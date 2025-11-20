ARG BUILD_FROM
FROM $BUILD_FROM

# Install required packages
RUN apk add --no-cache \
    bash \
    python3 \
    py3-pip \
    wget \
    libstdc++ \
    libgcc

# Download precompiled unrar binary
RUN cd /tmp && \
    wget https://www.rarlab.com/rar/rarlinux-x64-700.tar.gz && \
    tar -xzf rarlinux-x64-700.tar.gz && \
    cp rar/unrar /usr/bin/unrar && \
    chmod +x /usr/bin/unrar && \
    rm -rf /tmp/rar /tmp/rarlinux-x64-700.tar.gz

# Copy the extraction script
COPY run.sh /
COPY extract.py /

# Make scripts executable
RUN chmod a+x /run.sh /extract.py

CMD [ "/run.sh" ]
