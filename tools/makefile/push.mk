.PHONY: push

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