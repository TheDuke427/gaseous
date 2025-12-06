ARG BUILD_FROM
FROM ${BUILD_FROM}

RUN apk add --no-cache \
    authelia \
    bash

COPY run.sh /
RUN chmod a+x /run.sh

EXPOSE 9091

CMD ["/run.sh"]
