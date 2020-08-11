#!/usr/bin/env bash

set -ex

#docker tag plugfox/flutter plugfox/flutter:stable
docker push plugfox/flutter:stable
docker push plugfox/flutter:beta