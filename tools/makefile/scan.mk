.PHONY: scan

# Scan images
# Running with VERSION argument
# make scan VERSION="<VERSION OR CHANNEL>" e.g. make scan VERSION="stable"
scan:
	@docker scan plugfox/flutter:$(VERSION)-android