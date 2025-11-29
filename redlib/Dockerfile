ARG BUILD_FROM
FROM quay.io/redlib/redlib:latest AS redlib

FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copy redlib binary from official image
COPY --from=redlib /usr/local/bin/redlib /usr/local/bin/redlib

# Copy root filesystem
COPY run.sh /
RUN chmod a+x /run.sh

# Expose port
EXPOSE 8090

CMD ["/run.sh"]
