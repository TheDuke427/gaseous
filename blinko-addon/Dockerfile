ARG BUILD_FROM
FROM blinkospace/blinko:latest

# Install PostgreSQL
RUN apk add --no-cache \
    postgresql \
    postgresql-contrib \
    bash

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
