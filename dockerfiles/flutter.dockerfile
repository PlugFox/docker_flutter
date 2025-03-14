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

# 3.35
# 3.31
# 2.6

# ------------------------------
# Builder Stage: Build and Package Flutter SDK
# ------------------------------
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
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p ${PUB_CACHE}

WORKDIR /

# Clone the Flutter repository with the specified branch (preserving the .git folder) and optimize it
RUN set -eux; \
    git clone -b ${VERSION} --depth 1 ${FLUTTER_URL} ${FLUTTER_HOME} && \
    cd ${FLUTTER_HOME} && \
    git gc --prune=all

# Create dependencies
RUN set -eux; \
    for f in \
        /etc/ssl/certs \
        /usr/share/ca-certificates \
        ${FLUTTER_HOME} \
        ${PUB_CACHE} \
    ; do \
        dir="$(dirname "$f")"; \
        mkdir -p "/dependencies$dir"; \
        cp --archive --link --dereference --no-target-directory "$f" "/dependencies$f"; \
    done

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

# Copy the Flutter SDK tarball from the builder stage
COPY --from=builder /dependencies /

# Install only runtime dependencies without extra recommendations and extract the Flutter SDK
RUN set -eux; \
    apt-get update && apt-get install -y --no-install-recommends \
        bash \
        git \
        curl \
        unzip \
        xz-utils \
        ca-certificates && \
    # Clean up the package lists and cache to reduce the image size
    rm -rf /var/lib/apt/lists/*  \
        /usr/share/man/* /usr/share/doc && \
    # Set the Flutter SDK directory permissions
    git config --global --add safe.directory /opt/flutter && \
    # Create a non-root user for better security and adjust ownership
    useradd -m -s /bin/bash flutter && \
    chown -R flutter: ${FLUTTER_HOME} ${PUB_CACHE}

# Switch to the non-root user
USER flutter
WORKDIR /home/flutter

# Disable Flutter analytics and CLI animations,
# precache the Flutter SDK and run the doctor
RUN set -eux; \
    ${FLUTTER_HOME}/bin/flutter config --disable-analytics --no-cli-animations && \
    ${FLUTTER_HOME}/bin/flutter precache --universal && \
    ${FLUTTER_HOME}/bin/flutter doctor --verbose

# Add image metadata labels
LABEL org.opencontainers.image.title="Flutter Docker" \
      org.opencontainers.image.description="Ubuntu-based Docker image with Flutter and Dart" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/plugfox/docker_flutter" \
      maintainer="Plague Fox <PlugFox@gmail.com>"

# Default command to run when the container starts
CMD ["flutter", "doctor"]
