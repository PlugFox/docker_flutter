PLATFORM := $(shell arch)
ifeq ($(PLATFORM),x86_64)
	GLIBC := assets/glibc/x86_64/glibc-2.29-r0.apk
	GLIBC_BIN := assets/glibc/x86_64/glibc-bin-2.29-r0.apk
else ifeq ($(PLATFORM),arm64)
	GLIBC := assets/glibc/arm/glibc-2.30-r0.apk
	GLIBC_BIN := assets/glibc/arm/glibc-bin-2.30-r0.apk
else
	GLIBC := assets/glibc/x86_64/glibc-2.29-r0.apk
	GLIBC_BIN := assets/glibc/x86_64/glibc-bin-2.29-r0.apk
endif

ifeq ($(OS),Windows_NT)
	OS := win
else
    _detected_OS := $(shell uname -s)
    ifeq ($(_detected_OS),Linux)
		OS := lin
    else ifeq ($(_detected_OS),Darwin)
		OS := mac
    endif
endif
