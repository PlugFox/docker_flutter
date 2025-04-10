# Flutter docker image

[![BUILD AND PUBLISH FLUTTER IMAGES](https://github.com/PlugFox/docker_flutter/actions/workflows/build_and_publish_tag.yml/badge.svg)](https://github.com/PlugFox/docker_flutter/actions/workflows/build_and_publish_tag.yml)
[![GitHub](https://img.shields.io/badge/Git-Hub-purple.svg)](https://github.com/PlugFox/docker_flutter/pkgs/container/flutter)
[![Docker](https://img.shields.io/badge/Docker-Hub-2496ed.svg)](https://hub.docker.com/r/plugfox/flutter/tags)
[![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://github.com/PlugFox/docker_flutter/blob/master/LICENSE)

Docker Images for Flutter & Dart with useful utils and web build support.
Symlinks to dart, flutter in the folder: `/opt/flutter`
Release update strategy at every new flutter version.

Android tags include the Android SDK and Flutter for Android development.
Web tags include the `minify` utility for web build optimization.

### Environment variables

Base environment variables:
- USER: `flutter`
- WORKDIR: `/home/flutter`
- SHELL: `/bin/bash`
- FLUTTER_ROOT: `/opt/flutter`
- FLUTTER_HOME: `/opt/flutter`
- PUB_CACHE: `/var/cache/pub`

Andoid SDK environment variables:
- ANDROID_HOME: `/opt/android`
- ANDROID_SDK_ROOT: `/opt/android`
- ANDROID_TOOLS_ROOT: `/opt/android`
- ANDROID_SDK_TOOLS_VERSION: `NNNNNNNN`

### How to build locally

```bash
docker build --compress \
    --file ./dockerfiles/flutter.dockerfile \
    --build-arg VERSION=stable \
    --tag plugfox/flutter:local .

docker build --compress \
    --file ./dockerfiles/flutter_web.dockerfile \
    --build-arg VERSION=local \
    --tag plugfox/flutter:local-web .

docker build --compress \
    --file ./dockerfiles/flutter_android.dockerfile \
    --build-arg VERSION=local \
    --tag plugfox/flutter:local-android .
```

### How to get shell

```bash
docker run --rm -it --name flutter \
    -w /app \
    plugfox/flutter:local \
    /bin/bash
```

### How to check image

```bash
docker run --rm -it --name flutter_web \
    -w /app \
    -v /tmp/build:/app/build/web \
    -v /tmp/cache:/var/cache/pub \
    plugfox/flutter:stable-web \
    /bin/bash -c "set -eux; flutter --version; dart --version; \
    flutter create --org="dev.flutter" --project-name="example" \
    --platforms=web --description="Example" . && \
    flutter pub get && flutter build web --release && \
    cd build/web && \
    mv index.html index.src.html && \
    minify --output index.html index.src.html"
```
