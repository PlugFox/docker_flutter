# ----------------------------------------------------------------------------------------
#                                        Dockerfile
# ----------------------------------------------------------------------------------------
# image:       plugfox/flutter:${VERSION}
# repository:  https://github.com/plugfox/docker_flutter
# license:     MIT
# requires:
# + ubuntu:latest
# authors:
# + Plague Fox <PlugFox@gmail.com>
# + Maria Melnik
# + Dmitri Z <z-dima@live.ru>
# + DoumanAsh <douman@gmx.se>
# ----------------------------------------------------------------------------------------

# ------------------------------
# Flutter image based on Ubuntu
# ------------------------------
ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION} AS flutter

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Build arguments
ARG VERSION=stable
ARG FLUTTER_HOME=/opt/flutter
ARG PUB_CACHE=/var/cache/pub
ARG FLUTTER_URL=https://github.com/flutter/flutter.git

# Set environment variables for Flutter in production
ENV FLUTTER_HOME=${FLUTTER_HOME} \
    FLUTTER_ROOT=${FLUTTER_HOME} \
    PUB_CACHE=${PUB_CACHE} \
    PATH=$PATH:${FLUTTER_HOME}/bin:${PUB_CACHE}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin

# Install only runtime dependencies without extra recommendations and extract the Flutter SDK
RUN set -eux; \
    apt-get update && apt-get install -y --no-install-recommends \
        bash \
        git \
        curl \
        unzip \
        xz-utils \
        ca-certificates \
    # Clean up the package lists and cache to reduce the image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/cache/apt/* \
           /usr/share/man/* /usr/share/doc/* && \
    # Ensure the /opt/flutter directory exists and is writable before switching users
    mkdir -p ${FLUTTER_HOME} ${PUB_CACHE} && \
    # Download the Flutter SDK from the GitHub repository
    git clone -b ${VERSION} --depth 1 ${FLUTTER_URL} ${FLUTTER_HOME} && \
    cd ${FLUTTER_HOME} && \
    # Set the Flutter SDK directory permissions
    git config --global --add safe.directory ${FLUTTER_HOME} && \
    # Clean up the Flutter SDK by running the git garbage collector
    git gc --aggressive --prune=all && \
    # Disable Flutter analytics and CLI animations
    ${FLUTTER_HOME}/bin/flutter config --disable-analytics --no-cli-animations && \
    # Precache the Flutter SDK and run the doctor
    ${FLUTTER_HOME}/bin/flutter precache --universal && \
    ${FLUTTER_HOME}/bin/flutter doctor --verbose && \
    && chown -R root:root ${FLUTTER_HOME}

USER root
WORKDIR /

# Create a non-root user for better security and adjust ownership
#RUN set -eux; \
#    useradd -m -s /bin/bash flutter && \
#    chown -R flutter:flutter ${FLUTTER_HOME} ${PUB_CACHE}

# Switch to the non-root user **AFTER** installing Flutter
#USER flutter
#WORKDIR /home/flutter

# Disable Flutter analytics and CLI animations for the non-root user
#RUN set -eux; ${FLUTTER_HOME}/bin/flutter config --disable-analytics --no-cli-animations

# Add image metadata labels
LABEL org.opencontainers.image.title="Flutter Docker" \
      org.opencontainers.image.description="Ubuntu-based Docker image with Flutter and Dart" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/plugfox/docker_flutter" \
      maintainer="Plague Fox <PlugFox@gmail.com>" \
      family=plugfox/flutter

# Default command to run when the container starts
CMD ["flutter", "doctor"]
