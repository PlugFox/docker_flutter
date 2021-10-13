# ----------------------------------------------------------------------------------------
#                                        Dockerfile
# ----------------------------------------------------------------------------------------
# image:       plugfox/flutter:${FLUTTER_CHANNEL}${FLUTTER_VERSION}-android-warmed
# repository:  https://github.com/plugfox/docker_flutter
# license:     MIT
# requires:
# + alpine:latest
# authors:
# + Plague Fox <PlugFox@gmail.com>
# + Maria Melnik
# + Dmitri Z <z-dima@live.ru>
# ----------------------------------------------------------------------------------------

ARG FLUTTER_CHANNEL="stable"
ARG FLUTTER_VERSION=""
ARG FLUTTER_HOME="/opt/flutter"
ARG PUB_CACHE="/var/tmp/.pub_cache"
ARG GLIBC_VERSION="2.34-r0"
ARG ANDROID_PLATFORM_VERSION=31
ARG ANDROID_BUILD_TOOLS_VERSION=31.0.0
# ANDROID_SDK_TOOLS_VERSION Comes from https://developer.android.com/studio/#command-tools
ARG ANDROID_SDK_TOOLS_VERSION=7583922
ARG ANDROID_HOME="/opt/android"

FROM alpine:latest as build

USER root

ARG FLUTTER_CHANNEL
ARG FLUTTER_VERSION
ARG FLUTTER_HOME
ARG PUB_CACHE
ARG GLIBC_VERSION
ARG ANDROID_PLATFORM_VERSION
ARG ANDROID_BUILD_TOOLS_VERSION
ARG ANDROID_SDK_TOOLS_VERSION
ARG ANDROID_HOME

WORKDIR /

ENV GLIBC_VERSION=$GLIBC_VERSION \
    FLUTTER_CHANNEL=$FLUTTER_CHANNEL \
    FLUTTER_VERSION=$FLUTTER_VERSION \
    FLUTTER_HOME=$FLUTTER_HOME \
    FLUTTER_ROOT=$FLUTTER_HOME \
    PUB_CACHE=$PUB_CACHE \
    ANDROID_HOME=$ANDROID_HOME \
    ANDROID_SDK_ROOT=$ANDROID_HOME \
    ANDROID_TOOLS_ROOT=$ANDROID_HOME \
    PATH="${PATH}:${FLUTTER_HOME}/bin:${PUB_CACHE}/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools"

# Install linux dependency and utils
RUN set -eux; mkdir -p /usr/lib /tmp/glibc ${PUB_CACHE} ${ANDROID_HOME}/cmdline-tools /root/.android \
    && apk --no-cache add bash curl git ca-certificates wget unzip openjdk11-jdk \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub \
      https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget -O /tmp/glibc/glibc.apk \
      https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
    && wget -O /tmp/glibc/glibc-bin.apk \
      https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk \
    && apk --no-cache add /tmp/glibc/glibc.apk /tmp/glibc/glibc-bin.apk \
    && rm -rf /var/lib/apt/lists/* /var/cache/apk/*

# Create system dependencies
RUN set -eux; for f in \
        /etc/ssl/certs \
        /usr/share/ca-certificates \
        /tmp/glibc \
        /etc/apk/keys \
    ; do \
        dir="$(dirname "$f")"; \
        mkdir -p "/build_system_dependencies$dir"; \
        cp --archive --link --dereference --no-target-directory "$f" "/build_system_dependencies$f"; \
    done

# Install & config Flutter
RUN set -eux; if [[ -z "$FLUTTER_VERSION" ]] ; then \
        git clone -b ${FLUTTER_CHANNEL} --depth 1 --no-tags https://github.com/flutter/flutter.git "${FLUTTER_ROOT}" ; \
    else \
        git clone -b ${FLUTTER_VERSION} --depth 1 --no-tags https://github.com/flutter/flutter.git "${FLUTTER_ROOT}" ; \
    fi \
        && cd "${FLUTTER_ROOT}" \
        && git gc --prune=all

# Install the Android SDK Dependency.
RUN set -eux; wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip -O /tmp/android-sdk-tools.zip \
    && unzip -q /tmp/android-sdk-tools.zip -d /tmp/ \
    && mv /tmp/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest/ \
    && touch /root/.android/repositories.cfg \
    && yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses \
    && sdkmanager --sdk_root=${ANDROID_HOME} --install "platform-tools" \
    && sdkmanager --sdk_root=${ANDROID_HOME} --install "extras;google;instantapps"

# Init android dependency and utils & prebuild app
RUN set -eux; cd "${FLUTTER_ROOT}/bin" \
    && yes "y" | flutter doctor --android-licenses \
    && flutter doctor \
    && flutter precache --universal --android \
    && flutter config --no-analytics --enable-android \
    && cd "${FLUTTER_ROOT}/examples/" \
    && flutter create --pub -a kotlin --project-name warmup --platforms android -t app warmup \
    && cd warmup \
    && flutter pub get \
    && flutter pub upgrade --major-versions \
    && flutter build apk --release --pub --shrink --target-platform android-arm,android-arm64,android-x64 \
    && cd .. && rm -rf warmup \
    && mv /root /home/

# Create flutter & android dependencies
RUN set -eux; \
    for f in \
        ${FLUTTER_HOME} \
        ${PUB_CACHE} \
        ${ANDROID_HOME} \
        /home \
    ; do \
        dir="$(dirname "$f")"; \
        mkdir -p "/build_user_dependencies$dir"; \
        cp --archive --link --dereference --no-target-directory "$f" "/build_user_dependencies$f"; \
    done


# Create new clear layer
FROM alpine:latest as production

USER root

ARG FLUTTER_CHANNEL
ARG FLUTTER_VERSION
ARG FLUTTER_HOME
ARG PUB_CACHE
ARG ANDROID_PLATFORM_VERSION
ARG ANDROID_BUILD_TOOLS_VERSION
ARG ANDROID_SDK_TOOLS_VERSION
ARG ANDROID_HOME

# Copy system dependencies
COPY --from=build /build_system_dependencies/ /

# Install linux dependency and utils
RUN set -eux; apk --no-cache add bash git curl unzip \
      /tmp/glibc/glibc.apk \
      /tmp/glibc/glibc-bin.apk \
      openjdk11-jdk \
    && rm -rf /tmp/* /var/lib/apt/lists/* /var/cache/apk/* \
      /usr/share/man/* /usr/share/doc \
    && echo "flutter:x:501:flutter" >> /etc/group \
    && echo "flutter:x:500:101:Flutter user,,,:/home:/sbin/nologin" >> /etc/passwd \
    && chown flutter:flutter -R /tmp

# Copy android dependencies
COPY --chown=flutter:flutter --from=build /build_user_dependencies/ /

# User by default
USER flutter
WORKDIR /home
SHELL [ "/bin/bash", "-c" ]

# Add enviroment variables
ENV FLUTTER_HOME=$FLUTTER_HOME \
    FLUTTER_ROOT=$FLUTTER_HOME \
    PUB_CACHE=$PUB_CACHE \
    ANDROID_HOME=$ANDROID_HOME \
    ANDROID_SDK_ROOT=$ANDROID_HOME \
    ANDROID_TOOLS_ROOT=$ANDROID_HOME \
    PATH="${PATH}:${FLUTTER_HOME}/bin:${PUB_CACHE}/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools"

# Init android dependency and utils
RUN set -eux; yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses \
    && flutter config --no-analytics \
    #&& yes "y" | flutter doctor --android-licenses \
    #&& sdkmanager --sdk_root=${ANDROID_HOME} --install "platform-tools;extras;google;instantapps" \
    && git config --global user.email "plugfox@gmail.com" \
    && git config --global user.name "Plague Fox"

# Add lables
LABEL name="plugfox/flutter:${FLUTTER_CHANNEL}${FLUTTER_VERSION}-android-warmed" \
    description="Alpine with flutter & dart for android, warmed up" \
    license="MIT" \
    vcs-type="git" \
    vcs-url="https://github.com/plugfox/docker_flutter" \
    maintainer="Plague Fox <plugfox@gmail.com>" \
    authors="@plugfox" \
    user="flutter" \
    build_date="$(date +'%m/%d/%Y')" \
    flutter.channel="${FLUTTER_CHANNEL}" \
    flutter.version="${FLUTTER_VERSION}" \
    flutter.home="${FLUTTER_HOME}" \
    flutter.cache="${PUB_CACHE}" \
    android.version="${ANDROID_PLATFORM_VERSION}" \
    android.build_tools_version="${ANDROID_BUILD_TOOLS_VERSION}" \
    android.build_tools_version="${ANDROID_SDK_TOOLS_VERSION}" \
    android.home="${ANDROID_HOME}"

# Default command
CMD [ "flutter", "doctor" ]