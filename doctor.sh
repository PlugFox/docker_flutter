#!/usr/bin/env bash

set -ex

docker run --rm -it -v ${PWD}:/build --workdir /build plugfox/flutter:stable flutter doctor
docker run --rm -it -v ${PWD}:/build --workdir /build plugfox/flutter:beta flutter doctor