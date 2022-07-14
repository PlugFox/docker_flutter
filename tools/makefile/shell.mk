.PHONY: shell

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