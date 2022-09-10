.PHONY: shell

# Get root
# Running with VERSION argument
# make shell VERSION="<VERSION OR CHANNEL>" e.g. make shell VERSION="stable"
shell:
	@docker run --rm -it -v $(shell pwd):/build --workdir /build \
		--user=root:root \
		--name flutter_$(VERSION)-android \
		plugfox/flutter:$(VERSION)-android /bin/bash