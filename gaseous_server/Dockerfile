FROM gaseousgames/gaseousserver:latest

# Install additional tools for Home Assistant integration
RUN apt-get update && apt-get install -y \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Copy startup wrapper script
COPY run.sh /usr/local/bin/run-wrapper.sh
RUN chmod a+x /usr/local/bin/run-wrapper.sh

# Expose port
EXPOSE 80

# Use wrapper that sets env vars then calls original entrypoint
CMD ["/usr/local/bin/run-wrapper.sh"]
