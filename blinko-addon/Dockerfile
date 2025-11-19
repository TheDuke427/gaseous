ARG BUILD_FROM
FROM blinkospace/blinko:latest

# Install PostgreSQL and jq for JSON parsing
RUN apk add --no-cache \
    postgresql \
    postgresql-contrib \
    bash \
    jq

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
