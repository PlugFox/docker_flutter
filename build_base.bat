@ECHO OFF
@SET FLUTTER_CHANNEL=stable
rem @SET FLUTTER_VERSION=2.5.0
@docker build --no-cache --force-rm --squash --compress ^
    --file flutter_base.dockerfile ^
    --build-arg FLUTTER_CHANNEL="%FLUTTER_CHANNEL%" ^
    --tag plugfox/flutter:%FLUTTER_CHANNEL%-base .
rem --build-arg FLUTTER_VERSION="%FLUTTER_VERSION%" ^

rem docker run --rm -it --user root -v ${PWD}:/build --workdir /build plugfox/flutter:%FLUTTER_CHANNEL%-base bash
rem docker push plugfox/flutter:%FLUTTER_CHANNEL%-base