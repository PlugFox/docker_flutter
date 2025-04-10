# ------------------------------
# Arguments
# ------------------------------
ARG UBUNTU_VERSION=24.04
ARG VERSION=stable
ARG FLUTTER_HOME=/opt/flutter
ARG PUB_CACHE=/var/cache/pub
ARG FLUTTER_URL=https://github.com/flutter/flutter.git

# ------------------------------
# Flutter image based on Ubuntu
# ------------------------------
FROM ubuntu:${UBUNTU_VERSION} AS flutter

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Build arguments
ARG VERSION
ARG FLUTTER_HOME
ARG PUB_CACHE
ARG FLUTTER_URL

# Set environment variables for Flutter in production
ENV FLUTTER_HOME=${FLUTTER_HOME} \
    FLUTTER_ROOT=${FLUTTER_HOME} \
    PUB_CACHE=${PUB_CACHE} \
    PATH=$PATH:${FLUTTER_HOME}/bin:${PUB_CACHE}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin

USER root
WORKDIR /app

# Install only runtime dependencies without extra recommendations and extract the Flutter SDK
RUN set -eux; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        unzip \
        xz-utils \
        zip \
        # libglu1-mesa \
        # bash \
        ca-certificates && \
    # Clean up the package lists and cache to reduce the image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/cache/apt/* \
           /usr/share/man/* /usr/share/doc/* && \
    # Clone the Flutter SDK from GitHub
    git clone -b ${VERSION} --depth 1 "${FLUTTER_URL}" "${FLUTTER_HOME}" && \
    # Change the working directory to the Flutter SDK
    cd "${FLUTTER_HOME}" && \
    # Clean up the Flutter SDK by running the git garbage collector
    git gc --aggressive --prune=all && \
    # Remove unnecessary files and directories
    #find . \( -type d \( -name "doc" -o -name "examples" -o -name "dev" \) \) -exec rm -rf {} + && \
    # Set proper ownership
    mkdir -p ${PUB_CACHE} && \
    chown -R root:root ${FLUTTER_HOME} ${PUB_CACHE} && \
    # Set the Flutter SDK directory permissions
    git config --global --add safe.directory ${FLUTTER_HOME} && \
    # Disable Flutter analytics and CLI animations
    dart --disable-analytics && \
    flutter config --disable-analytics --no-cli-animations && \
    # Precache the Flutter SDK and run the doctor
    flutter precache --universal && \
    flutter doctor --verbose

# Add image metadata labels
LABEL org.opencontainers.image.title="Flutter Docker" \
      org.opencontainers.image.description="Ubuntu-based Docker image with Flutter and Dart" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/plugfox/docker_flutter" \
      maintainer="Plague Fox <PlugFox@gmail.com>" \
      family=plugfox/flutter

# Default command to run when the container starts
CMD ["flutter", "doctor"]
