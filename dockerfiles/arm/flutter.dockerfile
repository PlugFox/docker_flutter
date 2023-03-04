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
# + Dmitrii ZS <z-dima@live.ru>
# + DoumanAsh <douman@gmx.se>
# ----------------------------------------------------------------------------------------

ARG VERSION="stable"
ARG FLUTTER_HOME="/opt/flutter"
ARG PUB_CACHE="/var/tmp/.pub_cache"
ARG FLUTTER_URL="https://github.com/flutter/flutter"

FROM debian:bookworm-slim AS build

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

# Install linux dependency and utils
RUN set -eux; apt-get update \
    && mkdir -p /usr/lib $PUB_CACHE \
    && apt-get install -y bash curl git ca-certificates wget unzip \
    && rm -rf /var/lib/apt/lists/* /var/cache/apk/*

# Install & config Flutter
RUN set -eux; git clone -b ${VERSION} --depth 1 "${FLUTTER_URL}.git" "${FLUTTER_ROOT}" \
    && cd "${FLUTTER_ROOT}" \
    && git gc --prune=all

# Create dependencies
RUN set -eux; for f in \
    /etc/ssl/certs \
    /usr/share/ca-certificates \
    /etc/apk/keys \
    ${FLUTTER_HOME} \
    ${PUB_CACHE} \
    /root \
    ; do \
    dir="$(dirname "$f")"; \
    mkdir -p "/build_dependencies$dir"; \
    cp --archive --link --dereference --no-target-directory "$f" "/build_dependencies$f"; \
    done

# Create new clear layer
FROM debian:bookworm-slim as production

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
    && rm -rf /tmp/* /var/lib/apt/lists/* /var/cache/apk/* \
    /usr/share/man/* /usr/share/doc \
    && dart --disable-analytics && flutter config --no-analytics \
    && flutter doctor && flutter precache --universal

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
