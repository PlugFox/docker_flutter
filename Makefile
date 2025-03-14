SHELL :=/bin/bash -e -o pipefail
PWD   := $(shell pwd)

.DEFAULT_GOAL := all
.PHONY: all
all: ## build pipeline
all: generate format check test

.PHONY: ci
ci: ## CI build pipeline
ci: all

.PHONY: precommit
precommit: ## validate the branch before commit
precommit: all

.PHONY: help
help:
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# --- BUILD ---

.PHONY: build
build: ## Build images for channel or version, make build VERSION="<VERSION OR CHANNEL>"
	@echo "BUILD FLUTTER $(VERSION)"
	@docker build --compress \
		 --file ./dockerfiles/flutter.dockerfile \
		 --build-arg VERSION=$(VERSION) \
		 --tag plugfox/flutter:$(VERSION) .
#	@docker build --compress \
#		 --file ./dockerfiles/flutter_web.dockerfile \
#		 --build-arg VERSION=$(VERSION) \
#		 --tag "plugfox/flutter:$(VERSION)-web" .
#	@docker build --compress \
#		 --file ./dockerfiles/flutter_android.dockerfile \
#		 --build-arg VERSION=$(VERSION) \
#		 --tag "plugfox/flutter:$(VERSION)-android" .

.PHONY: build-arm
build-arm: ## Build arm64 images, make build-arm VERSION="<VERSION OR CHANNEL>"
	@echo "BUILD FLUTTER $(VERSION)"
	@docker buildx build --platform linux/arm64 --compress \
		 --file ./dockerfiles/flutter.dockerfile \
		 --build-arg VERSION=$(VERSION) \
		 --tag plugfox/flutter:$(VERSION) .
	@docker buildx build --platform linux/arm64 --compress \
		 --file ./dockerfiles/flutter_web.dockerfile \
		 --build-arg VERSION=$(VERSION) \
		 --tag "plugfox/flutter:$(VERSION)-web" .
	@docker buildx build --platform linux/arm64 --compress \
		 --file ./dockerfiles/flutter_android.dockerfile \
		 --build-arg VERSION=$(VERSION) \
		 --tag "plugfox/flutter:$(VERSION)-android" .

.PHONY: build-x64
build-x64: ## Build x64 images, make build-x64 VERSION="<VERSION OR CHANNEL>"
	@echo "BUILD FLUTTER $(VERSION)"
	@docker buildx build --platform linux/amd64 --compress \
		 --file ./dockerfiles/flutter.dockerfile \
		 --build-arg VERSION=$(VERSION) \
		 --tag plugfox/flutter:$(VERSION) .
	@docker buildx build --platform linux/amd64 --compress \
		 --file ./dockerfiles/flutter_web.dockerfile \
		 --build-arg VERSION=$(VERSION) \
		 --tag "plugfox/flutter:$(VERSION)-web" .
	@docker buildx build --platform linux/amd64 --compress \
		 --file ./dockerfiles/flutter_android.dockerfile \
		 --build-arg VERSION=$(VERSION) \
		 --tag "plugfox/flutter:$(VERSION)-android" .


# --- CHECK ---

.PHONY: check
check: ## Check image, make check VERSION="<VERSION OR CHANNEL>"
	@docker run --rm -it -v $(shell pwd)/tools:/home/tools --workdir /home/tools \
		--user=root:root \
		--name flutter_$(VERSION)_android \
		plugfox/flutter:$(VERSION)-android sh /home/tools/build_demo_android.sh

# --- DOCKER HUB ---

.PHONY: login
login: ## Authentication at docker registry
	@docker login

.PHONY: push
push: ## Push images to docker registry, make push VERSION="<VERSION OR CHANNEL>"
	@docker push plugfox/flutter:$(VERSION)
	@docker push plugfox/flutter:$(VERSION)-web
	@docker push plugfox/flutter:$(VERSION)-android

.PHONY: scan
scan: ## Scan images for vulnerabilities
	@docker scan plugfox/flutter:$(VERSION)
	@docker scan plugfox/flutter:$(VERSION)-web
	@docker scan plugfox/flutter:$(VERSION)-android

# --- UTILS ---

.PHONY: shell
shell: ## Get root, make shell VERSION="<VERSION OR CHANNEL>"
	@docker run --rm -it -v $(shell pwd):/build --workdir /build \
		--user=root:root \
		--name flutter_$(VERSION)-android \
		plugfox/flutter:$(VERSION)-android /bin/bash

.PHONY: prune
prune: ## Prune images
	@docker image prune -af --filter "label=family=plugfox/flutter"

.PHONY: diff
diff: ## git diff
	$(call print-target)
	@git diff --exit-code
	@RES=$$(git status --porcelain) ; if [ -n "$$RES" ]; then echo $$RES && exit 1 ; fi
