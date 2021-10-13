@ECHO OFF
@SET FLUTTER_CHANNEL=stable
@docker build --no-cache --force-rm --squash --compress ^
    --file .\dockerfiles\flutter_android_warmed.dockerfile ^
    --build-arg FLUTTER_CHANNEL="%FLUTTER_CHANNEL%" ^
    --tag plugfox/flutter:%FLUTTER_CHANNEL%-android-warmed .
rem docker run --rm -it --user root -v ${PWD}:/build --workdir /build plugfox/flutter:%FLUTTER_CHANNEL%-base bash
rem docker push plugfox/flutter:%FLUTTER_CHANNEL%-base