@ECHO OFF
@SET FLUTTER_VERSION=stable
@docker build --no-cache --force-rm --squash --compress ^
    --file flutter_android_base.dockerfile ^
    --build-arg FLUTTER_VERSION="%FLUTTER_VERSION%" ^
    --tag plugfox/flutter:%FLUTTER_VERSION%-android-base .
rem docker run --rm -it --user root -v ${PWD}:/build --workdir /build plugfox/flutter:base-stable bash
rem docker push plugfox/flutter:base-stable