# ------------------------------------------------------
#                       Dockerfile
# ------------------------------------------------------
# image:    flutter:stable
# name:     plugfox/flutter:stable
# repo:     https://github.com/plugfox/docker_flutter
# requires: debian:stretch
# authors:  plugfox@gmail.com
# license:  MIT
# ------------------------------------------------------

FROM debian:stretch

ARG flutter_version

ENV FLUTTER_VERSION=$flutter_version
ENV ANDROID_VERSION="29"

# image mostly inspired from https://github.com/GoogleCloudPlatform/cloud-builders-community/blob/770e0e9/flutter/Dockerfile

LABEL dev.plugfox.flutter.name="Debian linux image for Flutter & Dart with helpful utils" \
      dev.plugfox.flutter.license="MIT" \
      dev.plugfox.flutter.vcs-type="git" \
      dev.plugfox.flutter.vcs-url="https://github.com/plugfox/docker_flutter" \
      maintainer="plugfox@gmail.com" \
      authors="plugfox" \
      version="$FLUTTER_VERSION"

WORKDIR /

RUN apt-get update -y
RUN apt-get install -y \
  git \
  wget \
  curl \
  unzip \
  lcov \
  lib32stdc++6 \
  libglu1-mesa \
  default-jdk-headless \
  sqlite3 \
  libsqlite3-dev


#RUN mkdir -p /root/db

# Install the Android SDK Dependency.
ENV ANDROID_SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip"
ENV ANDROID_TOOLS_ROOT="/opt/android_sdk"
RUN mkdir -p "${ANDROID_TOOLS_ROOT}"
ENV ANDROID_SDK_ARCHIVE="${ANDROID_TOOLS_ROOT}/archive"
RUN wget -q "${ANDROID_SDK_URL}" -O "${ANDROID_SDK_ARCHIVE}"
RUN unzip -q -d "${ANDROID_TOOLS_ROOT}" "${ANDROID_SDK_ARCHIVE}"
RUN yes "y" | "${ANDROID_TOOLS_ROOT}/tools/bin/sdkmanager" "build-tools;$ANDROID_VERSION.0.0"
RUN yes "y" | "${ANDROID_TOOLS_ROOT}/tools/bin/sdkmanager" "platforms;android-$ANDROID_VERSION"
RUN yes "y" | "${ANDROID_TOOLS_ROOT}/tools/bin/sdkmanager" "platform-tools"
RUN rm "${ANDROID_SDK_ARCHIVE}"
ENV PATH="${ANDROID_TOOLS_ROOT}/tools:${PATH}"
ENV PATH="${ANDROID_TOOLS_ROOT}/tools/bin:${PATH}"

# Install Flutter.
ENV FLUTTER_HOME="/opt/flutter"
ENV FLUTTER_ROOT=$FLUTTER_HOME
RUN git clone --branch ${FLUTTER_VERSION} --depth=1 https://github.com/flutter/flutter "${FLUTTER_ROOT}"
ENV PATH="${FLUTTER_ROOT}/bin:${PATH}"
ENV ANDROID_HOME="${ANDROID_TOOLS_ROOT}"

# Disable analytics and crash reporting on the builder.
RUN flutter config  --no-analytics

# Perform an artifact precache so that no extra assets need to be downloaded on demand.
RUN flutter precache

# Accept licenses.
RUN yes "y" | flutter doctor --android-licenses

# Perform a doctor run.
RUN flutter doctor -v

ENV PATH $PATH:/flutter/bin/cache/dart-sdk/bin:/flutter/bin

# Enable web
RUN flutter config --enable-web \
    && apt-get update \
    && apt-get install -y chromium

ENV CHROME_EXECUTABLE=/usr/bin/chromium

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#CMD ['ansible']
#ENTRYPOINT [ "sqlite3" ]