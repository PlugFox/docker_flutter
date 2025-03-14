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

# Update package list and install dependencies with no recommended extras
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        wget \
        unzip \
        xz-utils \
        ca-certificates \
        bash && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# Clone the Flutter repository (shallow clone) and optimize repository
RUN git clone -b ${VERSION} --depth 1 ${FLUTTER_URL} ${FLUTTER_HOME} && \
    cd ${FLUTTER_HOME} && \
    git gc --prune=all

# Configure Flutter, pre-cache necessary artifacts and run doctor to validate installation
RUN ${FLUTTER_HOME}/bin/flutter config --no-analytics && \
    ${FLUTTER_HOME}/bin/flutter precache --universal && \
    ${FLUTTER_HOME}/bin/flutter doctor --verbose

##############################
# Production stage: Final image
##############################
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
    PATH=$PATH:${FLUTTER_HOME}/bin:${PUB_CACHE}/bin

# Install only runtime dependencies with no recommended extras
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        git \
        curl \
        unzip \
        xz-utils \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Copy Flutter SDK and cached artifacts from builder stage
COPY --from=builder ${FLUTTER_HOME} ${FLUTTER_HOME}
COPY --from=builder ${PUB_CACHE} ${PUB_CACHE}

# Create a non-root user for security and adjust ownership of Flutter directories
RUN useradd -m -s /bin/bash flutter && \
    chown -R flutter: ${FLUTTER_HOME} ${PUB_CACHE} && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# Switch to non-root user
USER flutter
WORKDIR /home/flutter

# Add image metadata labels
LABEL org.opencontainers.image.title="Flutter Docker" \
      org.opencontainers.image.description="Ubuntu-based Docker image with Flutter and Dart" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/plugfox/docker_flutter" \
      maintainer="Plague Fox <PlugFox@gmail.com>"

# Default command to run when container starts
#SHELL [ "/bin/bash", "-c" ]
CMD ["flutter", "doctor"]
