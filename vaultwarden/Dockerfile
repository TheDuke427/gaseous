ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache bash curl jq tar gzip sqlite openssl tini

# Create app dir
RUN mkdir -p /opt/vaultwarden /data
WORKDIR /opt/vaultwarden

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 80

CMD [ "/run.sh" ]
