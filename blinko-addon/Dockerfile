ARG BUILD_FROM
FROM blinkospace/blinko:latest

# Install MariaDB
RUN apk add --no-cache \
    mariadb \
    mariadb-client \
    bash

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
