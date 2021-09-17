# ------------------------------------------------------
#                       Dockerfile
# ------------------------------------------------------
# image:       plugfox/flutter:base
# repository:  https://github.com/plugfox/docker_flutter
# requires:    debian:buster-slim
# license:     MIT
# authors:     Plague Fox, Maria Melnik
# ------------------------------------------------------

ARG FLUTTER_VERSION="stable"
ARG FLUTTER_HOME="/opt/flutter"
ARG PUB_CACHE="/var/tmp/.pub_cache"
ARG GLIBC_VERSION="2.34-r0"

FROM alpine:latest as build

USER root

ARG FLUTTER_VERSION
ARG FLUTTER_HOME
ARG PUB_CACHE
ARG GLIBC_VERSION

WORKDIR /

ENV GLIBC_VERSION=$GLIBC_VERSION \
    FLUTTER_VERSION=$FLUTTER_VERSION \
    FLUTTER_HOME=$FLUTTER_HOME \
    PUB_CACHE=$PUB_CACHE \
    FLUTTER_ROOT=$FLUTTER_HOME \
    PATH="${PATH}:${FLUTTER_HOME}/bin:${PUB_CACHE}/bin"

# Install linux dependency and utils
RUN set -eux; mkdir -p /usr/lib /tmp/glibc $PUB_CACHE \
    && apk --no-cache add bash curl git ca-certificates wget unzip \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub \
      https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget -O /tmp/glibc/glibc.apk \
      https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
    && wget -O /tmp/glibc/glibc-bin.apk \
      https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk

# Install & config Flutter
RUN set -eux; git clone -b ${FLUTTER_VERSION} https://github.com/flutter/flutter.git "${FLUTTER_ROOT}"

# Create user & group
RUN set -eux; addgroup -S flutter \
    && adduser -S flutter -G flutter -h /home \
    && chown -R flutter:flutter ${FLUTTER_ROOT} ${PUB_CACHE}

# Create system dependencies
RUN set -eux; for f in \
        /etc/group \
        /etc/passwd \
        /etc/ssl/certs \
        /usr/share/ca-certificates \
        /tmp/glibc \
        /etc/apk/keys \
    ; do \
        dir="$(dirname "$f")"; \
        mkdir -p "/build_system_dependencies$dir"; \
        cp --archive --link --dereference --no-target-directory "$f" "/build_system_dependencies$f"; \
    done

# Create flutter dependencies
RUN set -eux; \
    for f in \
        ${FLUTTER_HOME} \
        ${PUB_CACHE} \
        /home \
    ; do \
        dir="$(dirname "$f")"; \
        mkdir -p "/build_flutter_dependencies$dir"; \
        cp --archive --link --dereference --no-target-directory "$f" "/build_flutter_dependencies$f"; \
    done

# Create new clear layer
FROM alpine:latest as production

ARG FLUTTER_VERSION
ARG FLUTTER_HOME
ARG PUB_CACHE

# Copy system & flutter dependencies
COPY --from=build /build_system_dependencies/ /
COPY --chown=flutter:flutter --from=build /build_flutter_dependencies/ /

# Install linux dependency and utils
RUN set -eux; apk --no-cache add bash git curl unzip \
      /tmp/glibc/glibc.apk \
      /tmp/glibc/glibc-bin.apk \
    && rm -rf /tmp/*

# Add enviroment variables
ENV FLUTTER_HOME=$FLUTTER_HOME \
    PUB_CACHE=$PUB_CACHE \
    FLUTTER_ROOT=$FLUTTER_HOME \
    PATH="${PATH}:${FLUTTER_HOME}/bin:${PUB_CACHE}/bin"

# Add lables
LABEL name="plugfox/flutter:base-${FLUTTER_VERSION}" \
      description="Alpine with flutter & dart" \
      license="MIT" \
      vcs-type="git" \
      vcs-url="https://github.com/plugfox/docker_flutter" \
      maintainer="plugfox@gmail.com" \
      authors="plugfox" \
      user="flutter" \
      build_date="$(date +'%m/%d/%Y')" \
      dart.flutter.version="$FLUTTER_VERSION" \
      dart.flutter.home="$FLUTTER_HOME" \
      dart.cache="$PUB_CACHE"

# User by default
USER flutter
WORKDIR /home
SHELL [ "/bin/bash", "-c" ]

# Default command
CMD [ "flutter", "doctor" ]