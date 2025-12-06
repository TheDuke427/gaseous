FROM authelia/authelia:4.38

USER root

RUN apk add --no-cache \
    bash \
    jq \
    openssl

COPY run.sh /
RUN chmod a+x /run.sh

EXPOSE 9091

CMD ["/run.sh"]
