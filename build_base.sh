#!/usr/bin/env bash
set -ex
FLUTTER_CHANNEL="stable"
docker build --no-cache --force-rm --squash --compress \
    --file flutter_base.dockerfile \
    --build-arg FLUTTER_CHANNEL="${FLUTTER_CHANNEL}" \
    --tag "plugfox/flutter:${FLUTTER_CHANNEL}-base" .