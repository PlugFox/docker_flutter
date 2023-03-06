# ----------------------------------------------------------------------------------------
#                                        Dockerfile
# ----------------------------------------------------------------------------------------
# image:       plugfox/flutter:${VERSION}-web
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

ARG VERSION="stable"

FROM plugfox/flutter:${VERSION}

# Setup flutter tools for web developement
RUN set -eux; flutter config --no-analytics --enable-web \
    && flutter precache --universal --web

# Add lables
LABEL name="plugfox/flutter:${VERSION}-web" \
    description="Alpine with flutter & dart for web" \
    flutter.channel="${VERSION}" \
    flutter.version="${VERSION}"

# By default
USER root
WORKDIR /build
SHELL [ "/bin/bash", "-c" ]
CMD [ "flutter", "doctor" ]
