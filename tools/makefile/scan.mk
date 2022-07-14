.PHONY: scan

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