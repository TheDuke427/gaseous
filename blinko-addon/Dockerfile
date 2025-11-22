ARG BUILD_FROM
FROM blinkospace/blinko:latest

# Install PostgreSQL, jq, nginx, curl, bash
RUN apk add --no-cache \
    postgresql \
    postgresql-contrib \
    bash \
    jq \
    nginx \
    curl

# Install node-fetch globally for proxy
RUN npm install express node-fetch

# Copy Ollama proxy script
COPY ollama-proxy.js /app/ollama-proxy.js

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
