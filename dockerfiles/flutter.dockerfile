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

# Build stage: Use Ubuntu as base image
ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION} AS builder

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Build arguments
ARG VERSION=stable
ARG FLUTTER_HOME=/opt/flutter
ARG PUB_CACHE=/var/cache/pub
ARG FLUTTER_URL=https://github.com/flutter/flutter.git

# Set environment variables for Flutter
ENV VERSION=${VERSION} \
    FLUTTER_HOME=${FLUTTER_HOME} \
    FLUTTER_ROOT=${FLUTTER_HOME} \
    PUB_CACHE=${PUB_CACHE} \
    PATH=$PATH:${FLUTTER_HOME}/bin:${PUB_CACHE}/bin

# Update package lists and install required packages without extra recommendations
RUN set -eux; apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    git \
    wget \
    unzip \
    xz-utils \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /

# Clone the Flutter repository with the specified branch (preserving the .git folder) and optimize it
RUN set -eux; git clone -b ${VERSION} --depth 1 ${FLUTTER_URL} ${FLUTTER_HOME} && \
    cd ${FLUTTER_HOME} && \
    git gc --prune=all

# Configure Flutter: disable analytics, pre-cache universal artifacts, and run doctor
RUN set -eux; ${FLUTTER_HOME}/bin/flutter config --no-analytics && \
    ${FLUTTER_HOME}/bin/flutter precache --universal && \
    ${FLUTTER_HOME}/bin/flutter doctor --verbose

# Package the entire Flutter SDK (including .git) into a tarball for efficient transfer
RUN set -eux; mkdir -p /build && \
    tar czf /build/flutter-sdk.tar.gz -C ${FLUTTER_HOME} .

# ------------------------------
# Production Stage: Final Image
# ------------------------------
FROM ubuntu:${UBUNTU_VERSION} AS production

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Build arguments for production stage
ARG FLUTTER_HOME=/opt/flutter
ARG PUB_CACHE=/var/cache/pub

# Set environment variables for Flutter in production
ENV FLUTTER_HOME=${FLUTTER_HOME} \
    FLUTTER_ROOT=${FLUTTER_HOME} \
    PUB_CACHE=${PUB_CACHE} \
    PATH=$PATH:${FLUTTER_HOME}/bin:${PUB_CACHE}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin

COPY --from=builder /build/flutter-sdk.tar.gz /build/flutter-sdk.tar.gz

# Install only runtime dependencies without extra recommendations
RUN set -eux; apt-get update && apt-get install -y --no-install-recommends \
    bash \
    git \
    curl \
    unzip \
    xz-utils \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    # Create the Flutter directory and copy the Flutter SDK tarball from the builder stage
    mkdir -p ${FLUTTER_HOME} ${PUB_CACHE} && \
    # Extract the Flutter SDK tarball into the target directory
    tar xzf /build/flutter-sdk.tar.gz -C ${FLUTTER_HOME} && \
    # Create a non-root user for better security and adjust permissions on Flutter directories
    useradd -m -s /bin/bash flutter && \
    chown -R flutter: ${FLUTTER_HOME} ${PUB_CACHE} && \
    rm -rf /build/flutter-sdk.tar.gz

# Switch to the non-root user
USER flutter
WORKDIR /home/flutter

# Add image metadata labels
LABEL org.opencontainers.image.title="Flutter Docker" \
      org.opencontainers.image.description="Ubuntu-based Docker image with Flutter and Dart" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/plugfox/docker_flutter" \
      maintainer="Plague Fox <PlugFox@gmail.com>"

# Default command to run when the container starts
#SHELL [ "/bin/bash", "-c" ]
CMD ["flutter", "doctor"]
