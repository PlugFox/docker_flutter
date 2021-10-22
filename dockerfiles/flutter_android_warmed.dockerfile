# ----------------------------------------------------------------------------------------
#                                        Dockerfile
# ----------------------------------------------------------------------------------------
# image:       plugfox/flutter:${FLUTTER_CHANNEL}${FLUTTER_VERSION}-android-warmed
# repository:  https://github.com/plugfox/docker_flutter
# license:     MIT
# requires:
# + alpine:latest
# authors:
# + Plague Fox <PlugFox@gmail.com>
# + Maria Melnik
# + Dmitri Z <z-dima@live.ru>
# ----------------------------------------------------------------------------------------

ARG FLUTTER_CHANNEL="stable"
ARG FLUTTER_VERSION=""
ARG FLUTTER_HOME="/opt/flutter"

FROM plugfox/flutter:${FLUTTER_CHANNEL}${FLUTTER_VERSION}-android-base as build

ARG FLUTTER_CHANNEL
ARG FLUTTER_VERSION
ARG FLUTTER_HOME

WORKDIR /

#RUN mkdir -p /tmp && find / -xdev | sort > /tmp/before.txt

# Init android dependency and utils & prebuild app
RUN set -eux; cd "${FLUTTER_HOME}/bin" \
    && yes "y" | flutter doctor --android-licenses \
    && flutter precache --universal --android \
    && flutter config --no-analytics --enable-android \
    #&& sdkmanager --list > sdkmanager-list.txt \
    && sdkmanager --sdk_root=${ANDROID_HOME} --install 'patcher;v4' 'emulator' 'platforms;android-30' 'build-tools;29.0.2' 'platform-tools' 'extras;google;instantapps'

# Сборка демо проекта
#RUN set -eux; cd "/home/" \
#    && flutter create --pub -a kotlin --project-name warmup --platforms android -t app warmup \
#    && cd warmup \
#    && flutter pub get \
#    && flutter pub upgrade --major-versions \
#    && flutter build apk --release --pub --shrink --target-platform android-arm,android-arm64,android-x64 \
#    && cd .. && rm -rf warmup

#RUN cd / && find / -xdev | sort > /tmp/after.txt

# Add lables
LABEL name="plugfox/flutter:${FLUTTER_CHANNEL}${FLUTTER_VERSION}-android-warmed" \
    description="Alpine with flutter & dart for android, warmed up" \
    license="MIT" \
    vcs-type="git" \
    vcs-url="https://github.com/plugfox/docker_flutter" \
    maintainer="Plague Fox <plugfox@gmail.com>" \
    authors="@plugfox" \
    user="flutter" \
    build_date="$(date +'%m/%d/%Y')" \
    flutter.channel="${FLUTTER_CHANNEL}" \
    flutter.version="${FLUTTER_VERSION}" \
    flutter.home="${FLUTTER_HOME}"