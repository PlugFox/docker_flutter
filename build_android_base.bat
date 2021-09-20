@ECHO OFF
@SET FLUTTER_CHANNEL=stable
@docker build --no-cache --force-rm --squash --compress ^
    --file flutter_android_base.dockerfile ^
    --build-arg FLUTTER_CHANNEL="%FLUTTER_CHANNEL%" ^
    --tag plugfox/flutter:%FLUTTER_CHANNEL%-android-base .
rem docker run --rm -it --user root -v ${PWD}:/build --workdir /build plugfox/flutter:base-stable bash
rem docker push plugfox/flutter:base-stable