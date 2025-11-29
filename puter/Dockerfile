FROM ghcr.io/heyputer/puter:latest

RUN apk add --no-cache jq bash

COPY run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 4100

CMD ["/run.sh"]
