ARG NODE_VERSION
ARG IMAGE_REPO
FROM ${IMAGE_REPO:-lagoon}/node:${NODE_VERSION}

MAINTAINER amazee.io
ENV LAGOON=node

RUN apk update \
    && apk upgrade \
    && apk add --no-cache \
        libstdc++ \
    && apk add --no-cache \
        binutils-gold \
        curl \
        g++ \
        gcc \
        gnupg \
        libgcc \
        linux-headers \
        make \
        git \
        file \
        openssl \
        python \
        bash \
        ca-certificates \
        wget \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.26-r0/glibc-2.26-r0.apk \
    && apk add glibc-2.26-r0.apk \
    && rm -rf /var/cache/apk/*

CMD ["/bin/docker-sleep"]