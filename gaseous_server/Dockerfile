FROM gaseousgames/gaseousserver:latest

# Install additional tools for Home Assistant integration
RUN apt-get update && apt-get install -y \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Remove any existing config files from the image
RUN rm -rf /home/gaseous/.gaseous-server/config.json \
    /root/.gaseous-server/config.json 2>/dev/null || true

# Create symlink so Gaseous config goes to /config (Home Assistant managed)
RUN mkdir -p /config && \
    mkdir -p /home/gaseous && \
    rm -rf /home/gaseous/.gaseous-server && \
    ln -sf /config /home/gaseous/.gaseous-server && \
    rm -rf /root/.gaseous-server && \
    ln -sf /config /root/.gaseous-server

# Copy startup wrapper script
COPY run.sh /usr/local/bin/run-wrapper.sh
RUN chmod a+x /usr/local/bin/run-wrapper.sh

# Expose port
EXPOSE 80

# Use wrapper that sets env vars then calls original entrypoint
CMD ["/usr/local/bin/run-wrapper.sh"]
