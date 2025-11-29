ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache git nodejs npm

RUN git clone https://github.com/HeyPuter/puter.git /opt/puter \
    && cd /opt/puter \
    && npm install \
    && npm run build

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
