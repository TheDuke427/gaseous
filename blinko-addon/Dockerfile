ARG BUILD_FROM
FROM blinkospace/blinko:latest

# Install PostgreSQL, jq, and nginx for Ollama proxy
RUN apk add --no-cache \
    postgresql \
    postgresql-contrib \
    bash \
    jq \
    nginx

# Copy nginx config template for Ollama endpoint translation
COPY ollama-proxy.conf.template /etc/nginx/http.d/ollama-proxy.conf.template

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
