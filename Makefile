.PHONY: help

help:
	@echo You can user commands: build, push, shell
	@echo make build FLUTTER_CHANNEL="stable"
	@echo make push  FLUTTER_CHANNEL="stable"
	@echo make shell FLUTTER_CHANNEL="stable"

-include tool/makefile/*.mk