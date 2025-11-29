ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    jq

WORKDIR /app

RUN git clone https://github.com/HeyPuter/puter.git .
RUN npm install

RUN mkdir -p /data/config /data/data

COPY run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 4100
