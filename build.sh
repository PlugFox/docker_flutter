#!/usr/bin/env bash

set -ex

#nohup 
sh -c ' \
    docker pull debian:stretch \
    && docker build \
    --build-arg flutter_version="stable" \
    --tag plugfox/flutter:stable \
    $PWD \
    && docker build \
    --build-arg flutter_version="beta" \
    --tag plugfox/flutter:beta \
    $PWD \
    && echo "DOCKERFILE BUILD SUCCESSFUL"' \
     > log.txt \
     && echo "DOCKERFILE BUILD SUCCESSFUL"


docker run --rm -it -v ${PWD}:/build --workdir /build plugfox/flutter:stable flutter doctor
docker run --rm -it -v ${PWD}:/build --workdir /build plugfox/flutter:beta flutter doctor
#&