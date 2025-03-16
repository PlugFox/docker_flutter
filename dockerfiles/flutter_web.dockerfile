ARG VERSION="stable"

FROM plugfox/flutter:${VERSION}

# Setup flutter tools for web developement
RUN set -eux; flutter config --enable-web \
    && flutter precache --web

CMD [ "flutter", "doctor" ]
