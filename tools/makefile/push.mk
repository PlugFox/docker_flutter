.PHONY: push

# Push image
# Running with VERSION argument
# make push VERSION="<VERSION OR CHANNEL>" e.g. make push VERSION="stable"
push:
	@echo "PUSH FLUTTER $(VERSION)"
	@docker push zsdima/flutter:$(VERSION)
	@docker push zsdima/flutter:$(VERSION)-web
	@docker push zsdima/flutter:$(VERSION)-android