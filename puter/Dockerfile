ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache \
    jq \
    wget

COPY run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 4100
