ARG BUILD_FROM
FROM $BUILD_FROM

# Install unrar and other utilities
RUN apk add --no-cache \
    unrar \
    bash \
    python3 \
    py3-pip

# Copy the extraction script
COPY run.sh /
COPY extract.py /

# Make scripts executable
RUN chmod a+x /run.sh /extract.py

CMD [ "/run.sh" ]
