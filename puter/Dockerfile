FROM alpine:3.22

# Install dependencies
RUN apk add --no-cache git nodejs npm bash

# Pull Puter
RUN git clone https://github.com/HeyPuter/puter.git /opt/puter \
    && cd /opt/puter \
    && npm install \
    && npm run build

# Copy startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Expose Puter default port
EXPOSE 4100

# Run the script as PID 1
CMD ["/run.sh"]
