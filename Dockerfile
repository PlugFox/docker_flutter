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

FROM debian:bullseye-slim as build

USER root

ARG FLUTTER_VERSION
ARG FLUTTER_HOME
ARG PUB_CACHE

WORKDIR /

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    FLUTTER_VERSION=$FLUTTER_VERSION \
    FLUTTER_HOME=$FLUTTER_HOME \
    PUB_CACHE=$PUB_CACHE \
    FLUTTER_ROOT=$FLUTTER_HOME \
    PATH="${PATH}:${FLUTTER_HOME}/bin:${PUB_CACHE}/bin"

# Make base dir if not exists
# Install linux dependency and utils
RUN set -eux; mkdir -p /usr/lib /var/tmp /bin $PUB_CACHE \
    && apt-get clean -y \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends \
                       git curl unzip ca-certificates \
                       dnsutils openssh-client lib32stdc++6 \
    # Remove dependencies
    && apt-get autoremove -y \
    && apt-get clean -y \
    # Clean trash
    && rm -rf /var/lib/apt/lists/* /tmp/*

# Install & config Flutter
RUN set -eux; git clone -b ${FLUTTER_VERSION} https://github.com/flutter/flutter.git "${FLUTTER_ROOT}" \
    && chown -R $(whoami):$(whoami) ${FLUTTER_ROOT} ${PUB_CACHE} \
    && cd "${FLUTTER_ROOT}" \
    && git clean -fdx

# Create user & group
RUN set -eux; groupadd flutter \
    && useradd -m --home-dir /home/flutter -g flutter flutter \
    && chown -R flutter:flutter /opt

# Create system dependencies
RUN set -eux; for f in \
        /etc/group \
        /etc/passwd \
        /etc/nsswitch.conf \
        /etc/ssl/certs \
        /usr/share/ca-certificates \
        /usr/bin/unzip \
        /usr/bin/git \
        #/usr/bin/curl \
        #/usr/lib/x86_64-linux-gnu/libcurl.so.4 \
        #/lib/ \
        #/lib32/ \
        #/lib64/ \
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
        /home/flutter \
    ; do \
        dir="$(dirname "$f")"; \
        mkdir -p "/build_flutter_dependencies$dir"; \
        cp --archive --link --dereference --no-target-directory "$f" "/build_flutter_dependencies$f"; \
    done

# Create new clear layer
#FROM scratch as production
FROM debian:bullseye-slim as production
#FROM gcr.io/distroless/base as production

ARG FLUTTER_VERSION
ARG ANDROID_HOME
ARG FLUTTER_HOME
ARG PUB_CACHE

# Copy system & flutter dependencies
COPY --from=build /build_system_dependencies/ /
COPY --chown=flutter:flutter --from=build /build_flutter_dependencies/ /

# Add enviroment variables
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    FLUTTER_HOME=$FLUTTER_HOME \
    PUB_CACHE=$PUB_CACHE \
    FLUTTER_ROOT=$FLUTTER_HOME \
    PATH="${PATH}:${FLUTTER_HOME}/bin:${PUB_CACHE}/bin"

# Add lables
LABEL name="plugfox/flutter:base-${FLUTTER_VERSION}" \
      description="Debian with flutter & dart" \
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
WORKDIR /home/flutter
SHELL [ "/bin/bash", "-c" ]

# Default command
CMD [ "flutter", "doctor" ]
#ENTRYPOINT [  ]