@ECHO OFF
@SET FLUTTER_VERSION=stable
rem @docker pull debian:buster-slim
rem --force-rm --squash
@docker build --no-cache --compress ^
    --file Dockerfile ^
    --build-arg FLUTTER_VERSION="%FLUTTER_VERSION%" ^
    --tag plugfox/flutter:base-%FLUTTER_VERSION% .

rem docker run --rm -it -v ${PWD}:/build --workdir /build plugfox/flutter:base-stable flutter doctor