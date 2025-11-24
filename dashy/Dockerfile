ARG BUILD_FROM=ghcr.io/hassio-addons/base:15.0.1
FROM $BUILD_FROM

# Install dependencies
RUN apk add --no-cache \
    nodejs \
    npm \
    yarn \
    git

# Clone and build Dashy
WORKDIR /app
RUN git clone https://github.com/Lissy93/dashy.git . && \
    yarn install --frozen-lockfile && \
    yarn build

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
