-include *.mk

.PHONY: all build push shell prune

all:
	@echo Вы можете использовать: build, push, shell
	@echo make build FLUTTER_CHANNEL="stable"
	@echo make push  FLUTTER_CHANNEL="stable"
	@echo make shell FLUTTER_CHANNEL="stable"

# Собрать образы соответсвующего канала или версии
# Запускается с аргументом FLUTTER_CHANNEL или FLUTTER_VERSION
# make build FLUTTER_CHANNEL="<КАНАЛ>" e.g. make build FLUTTER_CHANNEL="stable"
# make build FLUTTER_VERSION="<ВЕРСИЯ>" e.g. make build FLUTTER_VERSION="2.5.3"
build:
ifdef FLUTTER_CHANNEL
	@echo "BUILD FLUTTER CHANNEL $(FLUTTER_CHANNEL)"
	docker build --no-cache --force-rm --compress \
		 --file ./dockerfiles/flutter.dockerfile \
		 --build-arg FLUTTER_CHANNEL=$(FLUTTER_CHANNEL) \
		 --tag plugfox/flutter:$(FLUTTER_CHANNEL) .
	docker build --no-cache --force-rm --compress \
		 --file ./dockerfiles/flutter_web_warmed.dockerfile \
		 --build-arg FLUTTER_CHANNEL=$(FLUTTER_CHANNEL) \
		 --tag plugfox/flutter:$(FLUTTER_CHANNEL)-web-warmed .
	docker build --no-cache --force-rm --compress \
		 --file ./dockerfiles/flutter_android.dockerfile \
		 --build-arg FLUTTER_CHANNEL=$(FLUTTER_CHANNEL) \
		 --tag "plugfox/flutter:$(FLUTTER_CHANNEL)-android" .
	docker build --no-cache --force-rm --compress \
		 --file ./dockerfiles/flutter_android_warmed.dockerfile \
		 --build-arg FLUTTER_CHANNEL=$(FLUTTER_CHANNEL) \
		 --tag "plugfox/flutter:$(FLUTTER_CHANNEL)-android-warmed" .
endif
ifdef FLUTTER_VERSION
	@echo "BUILD FLUTTER VERSION $(FLUTTER_VERSION)"
	docker build --no-cache --force-rm --compress \
		 --file ./dockerfiles/flutter.dockerfile \
		 --build-arg FLUTTER_VERSION=$(FLUTTER_VERSION) \
		 --tag plugfox/flutter:$(FLUTTER_VERSION) .
	docker build --no-cache --force-rm --compress \
		 --file ./dockerfiles/flutter_web_warmed.dockerfile \
		 --build-arg FLUTTER_VERSION=$(FLUTTER_VERSION) \
		 --tag plugfox/flutter:$(FLUTTER_VERSION)-web-warmed .
	docker build --no-cache --force-rm --compress \
		 --file ./dockerfiles/flutter_android.dockerfile \
		 --build-arg FLUTTER_VERSION=$(FLUTTER_VERSION) \
		 --tag "plugfox/flutter:$(FLUTTER_VERSION)-android" .
	docker build --no-cache --force-rm --compress \
		 --file ./dockerfiles/flutter_android_warmed.dockerfile \
		 --build-arg FLUTTER_VERSION=$(FLUTTER_VERSION) \
		 --tag "plugfox/flutter:$(FLUTTER_VERSION)-android-warmed" .
endif

# Отправить собраные образы
# Запускается с аргументом FLUTTER_CHANNEL или FLUTTER_VERSION
# make push FLUTTER_CHANNEL="<КАНАЛ>" e.g. make push FLUTTER_CHANNEL="stable"
# make push FLUTTER_VERSION="<ВЕРСИЯ>" e.g. make push FLUTTER_VERSION="2.5.3"
push:
ifdef FLUTTER_CHANNEL
	@echo "PUSH FLUTTER $(FLUTTER_CHANNEL)"
	docker push plugfox/flutter:$(FLUTTER_CHANNEL)
	docker push plugfox/flutter:$(FLUTTER_CHANNEL)-web-warmed
	docker push plugfox/flutter:$(FLUTTER_CHANNEL)-android
	docker push plugfox/flutter:$(FLUTTER_CHANNEL)-android-warmed
endif
ifdef FLUTTER_VERSION
	@echo "PUSH FLUTTER $(FLUTTER_VERSION)"
	docker push plugfox/flutter:$(FLUTTER_VERSION)
	docker push plugfox/flutter:$(FLUTTER_VERSION)-web-warmed
	docker push plugfox/flutter:$(FLUTTER_VERSION)-android
	docker push plugfox/flutter:$(FLUTTER_VERSION)-android-warmed
endif


# Перейти в шелл образа
# Запускается с аргументом FLUTTER_CHANNEL или FLUTTER_VERSION
# make shell FLUTTER_CHANNEL="<КАНАЛ>" e.g. make shell FLUTTER_CHANNEL="stable"
# make shell FLUTTER_VERSION="<ВЕРСИЯ>" e.g. make shell FLUTTER_VERSION="2.5.3"
shell:
ifdef FLUTTER_CHANNEL
	-docker run --rm -it -v ${PWD}:/build --workdir /build \
		--user=root:root \
		--name flutter_$(FLUTTER_CHANNEL)_android_warmed \
		plugfox/flutter:$(FLUTTER_CHANNEL)-android-warmed /bin/bash
endif
ifdef FLUTTER_VERSION
	-docker run --rm -it -v ${PWD}:/build --workdir /build \
		--user=root:root \
		--name flutter_$(FLUTTER_VERSION)_android_warmed \
		plugfox/flutter:$(FLUTTER_VERSION)-android-warmed /bin/bash
endif

# Авторизоваться
login:
	@docker login

# Очистить неиспользуемые образы с меткой
# family=plugfox/flutter
prune:
	@docker image prune -af --filter "label=family=plugfox/flutter"


