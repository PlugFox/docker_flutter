#!/usr/bin/env bash
set -ex
FLUTTER_VERSION="stable"
docker build --no-cache --force-rm --squash --compress \
    --file flutter_android_base.dockerfile \
    --build-arg FLUTTER_VERSION="${FLUTTER_VERSION}" \
    --tag "plugfox/flutter:${FLUTTER_VERSION}-android-base" .