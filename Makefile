-include *.mk

.PHONY: all build push shell prune scan demo

all:
	@echo Вы можете использовать: build, push, shell
	@echo make build FLUTTER_CHANNEL="stable"
	@echo make push  FLUTTER_CHANNEL="stable"
	@echo make shell FLUTTER_CHANNEL="stable"

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

# Push image
# Running with argument FLUTTER_CHANNEL or FLUTTER_VERSION
# make push FLUTTER_CHANNEL="<КАНАЛ>" e.g. make push FLUTTER_CHANNEL="stable"
# make push FLUTTER_VERSION="<ВЕРСИЯ>" e.g. make push FLUTTER_VERSION="2.5.3"
push:
ifdef FLUTTER_CHANNEL
	@echo "PUSH FLUTTER $(FLUTTER_CHANNEL)"
	@docker push plugfox/flutter:$(FLUTTER_CHANNEL)
	@docker push plugfox/flutter:$(FLUTTER_CHANNEL)-web
	@docker push plugfox/flutter:$(FLUTTER_CHANNEL)-android
	@docker push plugfox/flutter:$(FLUTTER_CHANNEL)-android-warmed
endif
ifdef FLUTTER_VERSION
	@echo "PUSH FLUTTER $(FLUTTER_VERSION)"
	@docker push plugfox/flutter:$(FLUTTER_VERSION)
	@docker push plugfox/flutter:$(FLUTTER_VERSION)-web
	@docker push plugfox/flutter:$(FLUTTER_VERSION)-android
	@docker push plugfox/flutter:$(FLUTTER_VERSION)-android-warmed
endif

# Get root
# Running with argument FLUTTER_CHANNEL or FLUTTER_VERSION
# make shell FLUTTER_CHANNEL="<КАНАЛ>" e.g. make shell FLUTTER_CHANNEL="stable"
# make shell FLUTTER_VERSION="<ВЕРСИЯ>" e.g. make shell FLUTTER_VERSION="2.5.3"
shell:
ifdef FLUTTER_CHANNEL
	@docker run --rm -it -v $(shell pwd):/home --workdir /home \
		--user=root:root \
		--name flutter_$(FLUTTER_CHANNEL)_android_warmed \
		plugfox/flutter:$(FLUTTER_CHANNEL)-android-warmed /bin/bash
endif
ifdef FLUTTER_VERSION
	@docker run --rm -it -v $(shell pwd):/home --workdir /home \
		--user=root:root \
		--name flutter_$(FLUTTER_VERSION)_android_warmed \
		plugfox/flutter:$(FLUTTER_VERSION)-android-warmed /bin/bash
endif

# Authentication at docker registry
login:
	@docker login

# Clear all
# family=plugfox/flutter
prune:
	@docker image prune -af --filter "label=family=plugfox/flutter"

# Scan images
# Running with argument FLUTTER_CHANNEL or FLUTTER_VERSION
# make scan FLUTTER_CHANNEL="<КАНАЛ>" e.g. make scan FLUTTER_CHANNEL="stable"
# make scan FLUTTER_VERSION="<ВЕРСИЯ>" e.g. make scan FLUTTER_VERSION="2.5.3"
scan:
ifdef FLUTTER_CHANNEL
	@docker scan plugfox/flutter:$(FLUTTER_CHANNEL)-android-warmed
endif
ifdef FLUTTER_VERSION
	@docker scan plugfox/flutter:$(FLUTTER_VERSION)-android-warmed
endif

# Check image
# Running with argument FLUTTER_CHANNEL or FLUTTER_VERSION
# make demo FLUTTER_CHANNEL="<КАНАЛ>" e.g. make demo FLUTTER_CHANNEL="stable"
# make demo FLUTTER_VERSION="<ВЕРСИЯ>" e.g. make demo FLUTTER_VERSION="2.5.3"
demo:
ifdef FLUTTER_CHANNEL
	@docker run --rm -it -v $(shell pwd)/tools:/home/tools --workdir /home/tools \
		--user=root:root \
		--name flutter_$(FLUTTER_CHANNEL)_android_warmed \
		plugfox/flutter:$(FLUTTER_CHANNEL)-android-warmed sh /home/tools/build_demo_android.sh
endif
ifdef FLUTTER_VERSION
	@docker run --rm -it -v $(shell pwd)/tools:/home/tools --workdir /home/tools \
		--user=root:root \
		--name flutter_$(FLUTTER_VERSION)_android_warmed \
		plugfox/flutter:$(FLUTTER_VERSION)-android-warmed sh /home/tools/build_demo_android.sh
endif
