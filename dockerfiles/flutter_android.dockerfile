# ----------------------------------------------------------------------------------------
#                                        Dockerfile
# ----------------------------------------------------------------------------------------
# image:       plugfox/flutter:${FLUTTER_CHANNEL}${FLUTTER_VERSION}-android
# repository:  https://github.com/plugfox/docker_flutter
# license:     MIT
# requires:
# + alpine:latest
# + plugfox/flutter:${FLUTTER_CHANNEL}${FLUTTER_VERSION}
# authors:
# + Plague Fox <PlugFox@gmail.com>
# + Maria Melnik
# + Dmitri Z <z-dima@live.ru>
# ----------------------------------------------------------------------------------------

ARG FLUTTER_CHANNEL=""
ARG FLUTTER_VERSION=""
ARG ANDROID_PLATFORM_VERSION=31
ARG ANDROID_BUILD_TOOLS_VERSION=31.0.0
# ANDROID_SDK_TOOLS_VERSION Comes from https://developer.android.com/studio/#command-tools
ARG ANDROID_SDK_TOOLS_VERSION=7583922
ARG ANDROID_HOME="/opt/android"

FROM alpine:latest as build

USER root

ARG ANDROID_PLATFORM_VERSION
ARG ANDROID_BUILD_TOOLS_VERSION
ARG ANDROID_SDK_TOOLS_VERSION
ARG ANDROID_HOME

WORKDIR /

ENV ANDROID_HOME=$ANDROID_HOME \
    ANDROID_SDK_ROOT=$ANDROID_HOME \
    ANDROID_TOOLS_ROOT=$ANDROID_HOME \
    PATH="${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools"

# Install linux dependency and utils
RUN set -eux; apk --no-cache add bash curl wget unzip openjdk11-jdk \
    && rm -rf /tmp/* /var/cache/apk/* \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools /root/.android

# Install the Android SDK Dependency.
RUN set -eux; wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip -O /tmp/android-sdk-tools.zip \
    && unzip -q /tmp/android-sdk-tools.zip -d /tmp/ \
    && mv /tmp/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest/ \
    && rm -rf /tmp/* \
    && touch /root/.android/repositories.cfg \
    && yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses \
    && sdkmanager --sdk_root=${ANDROID_HOME} --install "platform-tools" \
    && cd / && mv /root /home/

# Create android dependencies
RUN set -eux; \
    for f in \
        ${ANDROID_HOME} \
        /home \
    ; do \
        dir="$(dirname "$f")"; \
        mkdir -p "/build_android_dependencies$dir"; \
        cp --archive --link --dereference --no-target-directory "$f" "/build_android_dependencies$f"; \
    done

# Create new clear layer
FROM plugfox/flutter:${FLUTTER_CHANNEL}${FLUTTER_VERSION} as production

USER root

ARG FLUTTER_CHANNEL
ARG FLUTTER_VERSION
ARG ANDROID_PLATFORM_VERSION
ARG ANDROID_BUILD_TOOLS_VERSION
ARG ANDROID_SDK_TOOLS_VERSION
ARG ANDROID_HOME

# Add enviroment variables
ENV ANDROID_HOME=$ANDROID_HOME \
    ANDROID_SDK_ROOT=$ANDROID_HOME \
    ANDROID_TOOLS_ROOT=$ANDROID_HOME \
    PATH="${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools"

# Copy android dependencies
COPY --chown=101:101 --from=build /build_android_dependencies/ /

#RUN mkdir -p /tmp && find / -xdev | sort > /tmp/before.txt

# Init android dependency and utils
RUN set -eux; apk add --no-cache openjdk11-jdk \
    && rm -rf /tmp/* /var/lib/apt/lists/* /var/cache/apk/* \
      /usr/share/man/* /usr/share/doc

#RUN find / -xdev | sort > /tmp/after.txt

# Add lables
LABEL name="plugfox/flutter:${FLUTTER_CHANNEL}${FLUTTER_VERSION}-android" \
      description="Alpine with flutter & dart for android" \
      license="MIT" \
      vcs-type="git" \
      vcs-url="https://github.com/plugfox/docker_flutter" \
      maintainer="Plague Fox <plugfox@gmail.com>" \
      authors="@plugfox" \
      user="flutter" \
      android.version="${ANDROID_PLATFORM_VERSION}" \
      android.build_tools_version="${ANDROID_BUILD_TOOLS_VERSION}" \
      android.build_tools_version="${ANDROID_SDK_TOOLS_VERSION}" \
      android.home="${ANDROID_HOME}"

# User by default
USER flutter
WORKDIR /home
SHELL [ "/bin/bash", "-c" ]

# Default command
CMD [ "flutter", "doctor" ]