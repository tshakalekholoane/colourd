APP := colourd
BUILD_DIR := $(PWD)/.build
PARAMS := dev.tshaka.colourd.plist
TARGET_DIR := /usr/local/bin

## help: print this help message
.PHONY: help
help:
	@echo "Usage:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

## clean: delete build artefacts
.PHONY: clean
clean:
	swift package clean

## install: build and install the daemon
.PHONY: install
install: release load link

## link: create a symbolic link in /usr/local/bin
.PHONY: link
link:
	ln -sf $(BUILD_DIR)/release/$(APP) $(TARGET_DIR)/$(APP)

## load: load the parameters
.PHONY: load
load:
	cp -f $(PWD)/$(PARAMS) $(HOME)/Library/LaunchAgents/$(PARAMS)

## release: compile a release build of the application
.PHONY: release
release:
	swift build --configuration release

## run: run the daemon
.PHONY: run
run: release 
	$(BUILD_DIR)/release/$(APP)

## universal: compiles a multiarchitecture binary for amd64 and arm64
.PHONY: universal 
universal:
	swift build --configuration release --triple arm64-apple-macosx
	swift build --configuration release --triple x86_64-apple-macosx
	lipo -create -output $(APP) $(BUILD_DIR)/arm64-apple-macosx/release/$(APP) $(BUILD_DIR)/x86_64-apple-macosx/release/$(APP)

## unlink: remove the symobolic link in /usr/local/bin
.PHONY: unlink
unlink:
	rm -f $(TARGET_DIR)/$(APP)
