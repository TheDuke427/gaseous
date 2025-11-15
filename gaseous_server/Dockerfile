FROM gaseousgames/gaseousserver:latest

# Install additional tools for Home Assistant integration
RUN apt-get update && apt-get install -y \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Copy startup script
COPY run.sh /run.sh
RUN chmod a+x /run.sh

# Expose port
EXPOSE 80

# Use run.sh as entrypoint
CMD ["/run.sh"]
