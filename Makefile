.PHONY: help

help:
	@echo --- user commands:
	@echo - make build VERSION="stable"
	@echo - make push  VERSION="stable"
	@echo - make shell VERSION="stable"
	@echo
	@echo --- environment info:
	@echo - operating system: $(OS)
	@echo - glibc path: $(GLIBC)
	@echo - glibc-bin path: $(GLIBC_BIN)
	@echo

-include tools/makefile/*.mk