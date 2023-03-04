# ----------------------------------------------------------------------------------------
#                                        Dockerfile
# ----------------------------------------------------------------------------------------
# image:       plugfox/flutter:${VERSION}
# repository:  https://github.com/plugfox/docker_flutter
# license:     MIT
# requires:
# + alpine:latest
# authors:
# + Plague Fox <PlugFox@gmail.com>
# + Maria Melnik
# + Dmitri Z <z-dima@live.ru>
# + DoumanAsh <douman@gmx.se>
# ----------------------------------------------------------------------------------------

ARG VERSION="stable"
ARG FLUTTER_HOME="/opt/flutter"
ARG PUB_CACHE="/var/tmp/.pub_cache"
ARG FLUTTER_URL="https://github.com/flutter/flutter"

FROM alpine:latest as build

USER root
WORKDIR /

ARG VERSION
ARG FLUTTER_HOME
ARG PUB_CACHE
ARG FLUTTER_URL

ENV VERSION=$VERSION \
    FLUTTER_HOME=$FLUTTER_HOME \
    FLUTTER_ROOT=$FLUTTER_HOME \
    PUB_CACHE=$PUB_CACHE \
    PATH="${PATH}:${FLUTTER_HOME}/bin:${PUB_CACHE}/bin"

#RUN mkdir -p /tmp && find / -xdev | sort > /tmp/before.txt

# Install linux dependency and utils
RUN set -eux; mkdir -p /usr/lib /tmp/glibc $PUB_CACHE \
    #&& echo "flutter:x:101:flutter" >> /etc/group \
    #&& echo "flutter:x:101:101:Flutter user,,,:/home:/sbin/nologin" >> /etc/passwd \
    && apk --no-cache add bash curl git ca-certificates wget unzip \
    && rm -rf /var/lib/apt/lists/* /var/cache/apk/*

# Install & config Flutter
RUN set -eux; git clone -b ${VERSION} --depth 1 "${FLUTTER_URL}.git" "${FLUTTER_ROOT}" \
    && cd "${FLUTTER_ROOT}" \
    && git gc --prune=all

# Get glibc for current architecure
RUN arch=$(uname -m); \
    if [[ $arch == x86_64* ]] || [[ $arch == i*86 ]]; then \
    echo "x86_64 Architecture"; \
    export GLIBC_URL="https://github.com/sgerrand/alpine-pkg-glibc"; \
    export GLIBC_VERSION="2.29-r0"; \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub; \
    wget -O /tmp/glibc/glibc.apk ${GLIBC_URL}/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk; \
    wget -O /tmp/glibc/glibc-bin.apk ${GLIBC_URL}/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk; \
    elif  [[ $arch == arm* ]] || [[ $arch == aarch* ]]; then \
    echo "ARM Architecture"; \
    #export GLIBC_URL="https://github.com/sgerrand/alpine-pkg-glibc"; \
    #export GLIBC_VERSION="2.35-r0"; \
    #wget -q -O /etc/apk/keys/rjerk.rsa.pub https://raw.githubusercontent.com/Rjerk/alpine-pkg-glibc/2.30-r0-aarch64/rjerk.rsa.pub; \
    #wget -O /tmp/glibc/glibc.apk ${GLIBC_URL}/releases/download/${GLIBC_VERSION}-arm64/glibc-${GLIBC_VERSION}.apk; \
    #wget -O /tmp/glibc/glibc-bin.apk ${GLIBC_URL}/releases/download/${GLIBC_VERSION}-arm64/glibc-bin-${GLIBC_VERSION}.apk; \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub; \
    wget -O /tmp/glibc/glibc.apk ${GLIBC_URL}/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk; \
    wget -O /tmp/glibc/glibc-bin.apk ${GLIBC_URL}/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk; \
    #apk add glibc-2.35-r0.apk; \
    echo "* * * ARM Ready * * *"; \
    else \
    >&2 echo "Unsupported Architecture"; \
    exit 1; \
    fi

#RUN find / -xdev | sort > /tmp/after.txt

# Create dependencies
RUN set -eux; for f in \
    /etc/ssl/certs \
    /usr/share/ca-certificates \
    /etc/apk/keys \
    #/etc/group \
    #/etc/passwd \
    ${FLUTTER_HOME} \
    ${PUB_CACHE} \
    /root \
    /tmp/glibc \
    ; do \
    dir="$(dirname "$f")"; \
    mkdir -p "/build_dependencies$dir"; \
    cp --archive --link --dereference --no-target-directory "$f" "/build_dependencies$f"; \
    done

# Create new clear layer
FROM alpine:latest as production

ARG VERSION
ARG FLUTTER_HOME
ARG PUB_CACHE
ARG FLUTTER_URL
ARG GLIBC_VERSION
ARG GLIBC_URL

# Add enviroment variables
ENV FLUTTER_HOME=$FLUTTER_HOME \
    PUB_CACHE=$PUB_CACHE \
    FLUTTER_ROOT=$FLUTTER_HOME \
    PATH="${PATH}:${FLUTTER_HOME}/bin:${PUB_CACHE}/bin"

# Copy dependencies
COPY --from=build /build_dependencies/ /

# Install linux dependency and utils
RUN set -eux; mkdir -p /build; apk --no-cache add bash git curl unzip  \
    && apk --no-cache add --force-overwrite /tmp/glibc/glibc.apk /tmp/glibc/glibc-bin.apk \
    -u alpine-keys --allow-untrusted \
    && rm -rf /tmp/* /var/lib/apt/lists/* /var/cache/apk/* \
    /usr/share/man/* /usr/share/doc \
    && dart --disable-analytics && flutter config --no-analytics \
    && flutter doctor && flutter precache --universal

#RUN set -eux; git config --global user.email "flutter@dart.dev" \
#&& git config --global user.name "Flutter" \
#&& git config --global --add safe.directory /opt/flutter

#ENV BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

# Add lables
LABEL name="plugfox/flutter:${VERSION}" \
    description="Alpine OS with flutter & dart" \
    license="MIT" \
    vcs-type="git" \
    vcs-url="https://github.com/plugfox/docker_flutter" \
    github="https://github.com/plugfox/docker_flutter" \
    dockerhub="https://hub.docker.com/r/plugfox/flutter" \
    maintainer="Plague Fox <plugfox@gmail.com>" \
    family="plugfox/flutter" \
    flutter.version="${VERSION}" \
    flutter.home="${FLUTTER_HOME}" \
    flutter.cache="${PUB_CACHE}" \
    flutter.url="${FLUTTER_URL}"

# By default
USER root
WORKDIR /build
SHELL [ "/bin/bash", "-c" ]
CMD [ "flutter", "doctor" ]
