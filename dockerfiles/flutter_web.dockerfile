ARG VERSION="stable"

# ------------------------------
# Build minifier binary
# ------------------------------
FROM golang:alpine AS minifier-builder

WORKDIR /build

# Compile minify as a static binary
RUN apk add --no-cache git && \
    git clone -b master --depth 1 https://github.com/tdewolff/minify.git && \
    cd /build/minify/cmd/minify && \
    CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o /out/minify . && \
    chmod +x /out/minify

# ------------------------------
# Flutter web development image
# ------------------------------
FROM plugfox/flutter:${VERSION}

USER root
WORKDIR /app

# Copy the minify binary from the builder stage
COPY --from=minifier-builder /out/ /bin/

# Setup flutter tools for web developement
RUN set -eux; flutter config --enable-web \
    && flutter precache --web

CMD [ "flutter", "doctor" ]
