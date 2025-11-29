ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    bash

WORKDIR /app

RUN git clone https://github.com/HeyPuter/puter.git .
RUN npm install

RUN mkdir -p /etc/services.d/puter

COPY run.sh /etc/services.d/puter/run
RUN chmod a+x /etc/services.d/puter/run

EXPOSE 4100
