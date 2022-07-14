.PHONY: build

# Build images for channel or version
# Running with argument FLUTTER_CHANNEL or FLUTTER_VERSION
# make build FLUTTER_CHANNEL="<КАНАЛ>" e.g. make build FLUTTER_CHANNEL="stable"
# make build FLUTTER_VERSION="<ВЕРСИЯ>" e.g. make build FLUTTER_VERSION="2.5.3"
build:
ifdef FLUTTER_CHANNEL
	@echo "BUILD FLUTTER CHANNEL $(FLUTTER_CHANNEL)"
	@docker build --no-cache --force-rm --compress \
		 --file ./dockerfiles/flutter.dockerfile \
		 --build-arg FLUTTER_CHANNEL=$(FLUTTER_CHANNEL) \
		 --tag plugfox/flutter:$(FLUTTER_CHANNEL) .
	@docker build --no-cache --force-rm --compress \
		 --file ./dockerfiles/flutter_web.dockerfile \
		 --build-arg FLUTTER_CHANNEL=$(FLUTTER_CHANNEL) \
		 --tag "plugfox/flutter:$(FLUTTER_CHANNEL)-web" .
	@docker build --no-cache --force-rm --compress \
		 --file ./dockerfiles/flutter_android.dockerfile \
		 --build-arg FLUTTER_CHANNEL=$(FLUTTER_CHANNEL) \
		 --tag "plugfox/flutter:$(FLUTTER_CHANNEL)-android" .
	@docker build --no-cache --force-rm --compress \
		 --file ./dockerfiles/flutter_android_warmed.dockerfile \
		 --build-arg FLUTTER_CHANNEL=$(FLUTTER_CHANNEL) \
		 --tag "plugfox/flutter:$(FLUTTER_CHANNEL)-android-warmed" .
endif
ifdef FLUTTER_VERSION
	@echo "BUILD FLUTTER VERSION $(FLUTTER_VERSION)"
	@docker build --no-cache --force-rm --compress \
		 --file ./dockerfiles/flutter.dockerfile \
		 --build-arg FLUTTER_VERSION=$(FLUTTER_VERSION) \
		 --tag plugfox/flutter:$(FLUTTER_VERSION) .
	@docker build --no-cache --force-rm --compress \
		 --file ./dockerfiles/flutter_web.dockerfile \
		 --build-arg FLUTTER_VERSION=$(FLUTTER_VERSION) \
		 --tag "plugfox/flutter:$(FLUTTER_VERSION)-web" .
	@docker build --no-cache --force-rm --compress \
		 --file ./dockerfiles/flutter_android.dockerfile \
		 --build-arg FLUTTER_VERSION=$(FLUTTER_VERSION) \
		 --tag "plugfox/flutter:$(FLUTTER_VERSION)-android" .
	@docker build --no-cache --force-rm --compress \
		 --file ./dockerfiles/flutter_android_warmed.dockerfile \
		 --build-arg FLUTTER_VERSION=$(FLUTTER_VERSION) \
		 --tag "plugfox/flutter:$(FLUTTER_VERSION)-android-warmed" .
endif