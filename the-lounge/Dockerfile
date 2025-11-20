ARG BUILD_FROM
FROM $BUILD_FROM

# Install Node.js and dependencies
RUN apk add --no-cache \
    nodejs \
    npm \
    bash \
    python3 \
    make \
    g++ \
    cairo-dev \
    jpeg-dev \
    pango-dev \
    giflib-dev \
    expect

# Install The Lounge
RUN npm install -g thelounge

# Create necessary directories
RUN mkdir -p /data/thelounge

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Expose web interface port
EXPOSE 9000

CMD [ "/run.sh" ]
