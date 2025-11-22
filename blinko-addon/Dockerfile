ARG BUILD_FROM
FROM blinkospace/blinko:latest

# Install dependencies
RUN apk add --no-cache \
    postgresql \
    postgresql-contrib \
    bash \
    jq \
    curl \
    nodejs npm

# Set working directory
WORKDIR /app

# Copy app files
COPY run.sh /run.sh
COPY ollama-proxy.js /app/ollama-proxy.js
RUN chmod a+x /run.sh

# Install Node dependencies for proxy
RUN npm init -y && npm install express node-fetch

CMD [ "/run.sh" ]
