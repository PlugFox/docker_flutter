ARG FLUTTER_CHANNEL
ARG FLUTTER_VERSION

FROM plugfox/flutter:${FLUTTER_CHANNEL}${FLUTTER_VERSION}

# Setup flutter tools for web developement
# Unfortunately flutter doesn't have convenient way to tell it to install web/universal only
RUN set -eux; \
    flutter upgrade; \
    flutter config --no-analytics --enable-web --no-enable-linux-desktop --no-enable-macos-desktop --no-enable-windows-desktop --no-enable-windows-uwp-desktop --no-enable-android --no-enable-ios --no-enable-fuchsia --no-enable-custom-devices ;\
    flutter precache --no-ios --no-linux --no-windows --no-winuwp --no-macos --no-fuchsia --universal --web

# Add lables
LABEL name="plugfox/flutter:${FLUTTER_CHANNEL}${FLUTTER_VERSION}-web-warmed" \
      description="Alpine with flutter & dart for android" \
      license="MIT" \
      vcs-type="git" \
      vcs-url="https://github.com/plugfox/docker_flutter" \
      maintainer="Plague Fox <plugfox@gmail.com>" \
      authors="@plugfox" \
      user="flutter" \
      group="flutter" \
      build_date="${BUILD_DATE}" \
      flutter.channel="${FLUTTER_CHANNEL}" \
      flutter.version="${FLUTTER_VERSION}"

# User by default
USER flutter
WORKDIR /
SHELL [ "/bin/bash", "-c" ]

# Default command
CMD [ "flutter", "doctor" ]
