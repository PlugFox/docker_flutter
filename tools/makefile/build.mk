.PHONY: build

# Build images for channel or version
# Running with VERSION argument
# make build VERSION="<VERSION OR CHANNEL>" e.g. make build VERSION="stable"
build:
	@echo "BUILD FLUTTER $(VERSION)"
	@docker build --compress \
		 --file ./dockerfiles/flutter.dockerfile \
		 --build-arg VERSION=$(VERSION) \
		 --tag plugfox/flutter:$(VERSION) .
	@docker build --compress \
		 --file ./dockerfiles/flutter_web.dockerfile \
		 --build-arg VERSION=$(VERSION) \
		 --tag "plugfox/flutter:$(VERSION)-web" .
	@docker build --compress \
		 --file ./dockerfiles/flutter_android.dockerfile \
		 --build-arg VERSION=$(VERSION) \
		 --tag "plugfox/flutter:$(VERSION)-android" .
