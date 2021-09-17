#!/usr/bin/env bash

set -ex

FLUTTER_VERSION="beta"
docker build --no-cache --force-rm --squash --compress \
    --file Dockerfile \
    --build-arg FLUTTER_VERSION="${FLUTTER_VERSION}" \
    --tag "plugfox/flutter:base-${FLUTTER_VERSION}" .