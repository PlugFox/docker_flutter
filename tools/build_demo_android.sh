#!/bin/bash

set -eux; mkdir -p /home/build; cd /home/build
/usr/bin/time /bin/sh -c '\
flutter create --project-name demo --org dev.flutter -t app --no-overwrite \
 --pub -a kotlin --platforms android --description "Demo application" demo \
 && cd demo && flutter pub get \
 && flutter build apk --release --no-pub --shrink --target-platform android-arm,android-arm64,android-x64'
