ARG VERSION="stable"

# https://developer.android.com/studio/#command-tools
ARG ANDROID_SDK_TOOLS_VERSION=11076708

# https://developer.android.com/studio/releases/build-tools
ARG ANDROID_PLATFORM_VERSION=35
ARG ANDROID_BUILD_TOOLS_VERSION=35.0.0

ARG ANDROID_HOME="/opt/android"

# Build stage to prepare Android SDK
ARG UBUNTU_VERSION=24.04

# ------------------------------
# Get Android SDK
# ------------------------------
FROM ubuntu:${UBUNTU_VERSION} AS build

USER root
WORKDIR /app

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

ARG ANDROID_SDK_TOOLS_VERSION
ARG ANDROID_HOME

ENV ANDROID_HOME=$ANDROID_HOME \
    ANDROID_SDK_ROOT=$ANDROID_HOME \
    ANDROID_TOOLS_ROOT=$ANDROID_HOME \
    PATH="${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools"

# Install Linux dependencies and utils
RUN set -eux; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        unzip \
        openjdk-17-jdk-headless \
        ca-certificates && \
    # Clean up to reduce image size
    rm -rf /var/lib/apt/lists/* /tmp/* /var/cache/apt/* && \
    # Create Android SDK directories
    mkdir -p ${ANDROID_HOME}/cmdline-tools /root/.android

# Install the Android SDK
RUN set -eux; \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip -O /tmp/android-sdk-tools.zip && \
    unzip -q /tmp/android-sdk-tools.zip -d /tmp/ && \
    mv /tmp/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest/ && \
    rm -rf /tmp/* && \
    touch /root/.android/repositories.cfg && \
    yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses && \
    sdkmanager --sdk_root=${ANDROID_HOME} --install "platform-tools"

# Create Android dependencies for later copying
RUN set -eux; \
    for f in \
        ${ANDROID_HOME} \
        /root/.android \
    ; do \
        dir="$(dirname "$f")"; \
        mkdir -p "/build_android_dependencies$dir"; \
        cp --archive --link --dereference --no-target-directory "$f" "/build_android_dependencies$f"; \
    done

# ------------------------------
# Flutter Android development image
# ------------------------------
FROM plugfox/flutter:${VERSION} AS production

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

ARG VERSION
ARG ANDROID_HOME
ARG ANDROID_SDK_TOOLS_VERSION
ARG ANDROID_PLATFORM_VERSION
ARG ANDROID_BUILD_TOOLS_VERSION

# Add environment variables
ENV ANDROID_HOME=$ANDROID_HOME \
    ANDROID_SDK_ROOT=$ANDROID_HOME \
    ANDROID_TOOLS_ROOT=$ANDROID_HOME \
    ANDROID_SDK_TOOLS_VERSION=$ANDROID_SDK_TOOLS_VERSION \
    ANDROID_PLATFORM_VERSION=$ANDROID_PLATFORM_VERSION \
    ANDROID_BUILD_TOOLS_VERSION=$ANDROID_BUILD_TOOLS_VERSION \
    PATH="${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools"

# Copy Android dependencies from build stage
COPY --from=build /build_android_dependencies/ /

# Install OpenJDK and initialize Android dependencies
RUN set -eux; \
    # Create man directory to prevent errors
    mkdir -p /usr/share/man/man1 && \
    # Install OpenJDK
    apt-get update && \
    apt-get install -y --no-install-recommends default-jdk-headless && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/cache/apt/* \
           /usr/share/doc/* && \
    # Configure Flutter for Android development
    cd "${FLUTTER_HOME}/bin" && \
    yes "y" | flutter doctor --android-licenses && \
    flutter config --enable-android && \
    # Precache Flutter dependencies for Android
    flutter precache --android

# Install Android SDK components separately to avoid errors
RUN set -eux; \
    sdkmanager --sdk_root=${ANDROID_HOME} --install "platform-tools" && \
    sdkmanager --sdk_root=${ANDROID_HOME} --install "platforms;android-$ANDROID_PLATFORM_VERSION" && \
    sdkmanager --sdk_root=${ANDROID_HOME} --install "build-tools;$ANDROID_BUILD_TOOLS_VERSION" && \
    sdkmanager --sdk_root=${ANDROID_HOME} --install "extras;google;instantapps" && \
    sdkmanager --list_installed > /root/sdkmanager-list-installed.txt && \
    ln -sf ${ANDROID_HOME}/platform-tools/adb /usr/bin/adb

# Optional: Validate the installation by building a test app
# Uncomment if you want to verify everything works during build
# RUN set -eux; \
#     cd "/tmp" && \
#     flutter create --pub -a kotlin --project-name test_app --platforms android -t app test_app && \
#     cd test_app && \
#     flutter pub get && \
#     flutter build apk --debug --target-platform android-arm64 && \
#     cd .. && \
#     rm -rf test_app

CMD ["flutter", "doctor"]