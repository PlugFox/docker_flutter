.PHONY: check

# Check image
# Running with VERSION argument
# make check VERSION="<VERSION OR CHANNEL>" e.g. make check VERSION="stable"
check:
	@docker run --rm -it -v $(shell pwd)/tools:/home/tools --workdir /home/tools \
		--user=root:root \
		--name flutter_$(VERSION)_android \
		plugfox/flutter:$(VERSION)-android sh /home/tools/build_demo_android.sh
