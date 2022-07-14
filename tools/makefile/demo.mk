.PHONY: check

# Check image
# Running with argument FLUTTER_CHANNEL or FLUTTER_VERSION
# make demo FLUTTER_CHANNEL="<КАНАЛ>" e.g. make demo FLUTTER_CHANNEL="stable"
# make demo FLUTTER_VERSION="<ВЕРСИЯ>" e.g. make demo FLUTTER_VERSION="2.5.3"
check:
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
