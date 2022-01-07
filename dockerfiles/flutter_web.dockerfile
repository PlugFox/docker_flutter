# ----------------------------------------------------------------------------------------
#                                        Dockerfile
# ----------------------------------------------------------------------------------------
# image:       plugfox/flutter:${FLUTTER_CHANNEL}${FLUTTER_VERSION}-web
# repository:  https://github.com/plugfox/docker_flutter
# license:     MIT
# requires:
# + plugfox/flutter:<version>
# authors:
# + Plague Fox <PlugFox@gmail.com>
# + Maria Melnik
# + Dmitri Z <z-dima@live.ru>
# + DoumanAsh <douman@gmx.se>
# ----------------------------------------------------------------------------------------

ARG FLUTTER_CHANNEL
ARG FLUTTER_VERSION

FROM plugfox/flutter:${FLUTTER_CHANNEL}${FLUTTER_VERSION}

# Setup flutter tools for web developement
RUN set -eux; flutter upgrade \
    && dart --disable-analytics \
    && flutter config --no-analytics --enable-web --no-enable-linux-desktop --no-enable-macos-desktop \
                      --no-enable-windows-desktop --no-enable-windows-uwp-desktop --no-enable-android \
                      --no-enable-ios --no-enable-fuchsia --no-enable-custom-devices \
    && flutter precache --web --no-universal --no-ios --no-linux --no-windows --no-winuwp --no-macos --no-fuchsia

# Add lables
LABEL name="plugfox/flutter:${FLUTTER_CHANNEL}${FLUTTER_VERSION}-web" \
      description="Alpine with flutter & dart for web" \
      flutter.channel="${FLUTTER_CHANNEL}" \
      flutter.version="${FLUTTER_VERSION}"

# User by default
USER flutter
WORKDIR /
SHELL [ "/bin/bash", "-c" ]

# Default command
CMD [ "flutter", "doctor" ]
