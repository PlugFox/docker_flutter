# Flutter docker image

[![BUILD AND PUBLISH FLUTTER IMAGES](https://github.com/PlugFox/docker_flutter/actions/workflows/build_and_publish_tag.yml/badge.svg)](https://github.com/PlugFox/docker_flutter/actions/workflows/build_and_publish_tag.yml)
[![GitHub](https://img.shields.io/badge/Git-Hub-purple.svg)](https://github.com/PlugFox/docker_flutter/pkgs/container/flutter)
[![Docker](https://img.shields.io/badge/Docker-Hub-2496ed.svg)](https://hub.docker.com/r/plugfox/flutter/tags)
[![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://github.com/PlugFox/docker_flutter/blob/master/LICENSE)

Docker Images for Flutter & Dart with useful utils and web build support.
Symlinks to dart, flutter in the folder: `/opt/flutter`
Release update strategy at every new flutter version.

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
- ANDROID_PLATFORM_VERSION: `XX`
- ANDROID_BUILD_TOOLS_VERSION: `XX.0.0`

### How to check image

```bash
cd /tmp
docker run --rm -it --name flutter_web \
    -w /opt/flutter/examples/hello_world/ \
    -v ./build:/opt/flutter/examples/hello_world/build/web \
    -v ./cache:/var/cache/pub \
    plugfox/flutter:stable-web \
    /bin/bash -c "set -eux; flutter pub get && flutter build web --release"
```