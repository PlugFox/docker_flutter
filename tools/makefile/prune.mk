.PHONY: prune

# Clear all
# family=plugfox/flutter
prune:
	@docker image prune -af --filter "label=family=zsdima/flutter"