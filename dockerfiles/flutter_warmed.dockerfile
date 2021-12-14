ARG FLUTTER_CHANNEL=""
ARG FLUTTER_VERSION=""

FROM plugfox/flutter:${FLUTTER_CHANNEL}${FLUTTER_VERSION}

# Setup flutter tools for web developement
# Unfortunately flutter doesn't have convenient way to tell it to install web/universal only
RUN set -eux; flutter --suppress-analytics upgrade; \
    flutter --suppress-analytics precache --no-ios --no-linux --no-windows --no-winuwp --no-macos --no-fuchsia --universal --web

# Add lables
LABEL name="plugfox/flutter-warmed:${FLUTTER_CHANNEL}${FLUTTER_VERSION}" \
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
WORKDIR /home
SHELL [ "/bin/bash", "-c" ]

# Default command
CMD [ "flutter", "doctor" ]
