APP := colourd
BUILD_DIR := .build

## help: print this help message
.PHONY: help
help:
	@echo "Usage:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

## clean: delete build artefacts
.PHONY: clean
clean:
	swift package clean

## release: compile a release build of the application
.PHONY: release 
release:
	swift build --configuration release

## run: run the application
.PHONY: run
run: release 
	$(BUILD_DIR)/release/$(APP)

## universal: compiles a multiarchitecture binary for amd64 and arm64
.PHONY: universal 
universal:
	swift build --configuration release --triple arm64-apple-macosx
	swift build --configuration release --triple x86_64-apple-macosx
	lipo -create -output $(APP) $(BUILD_DIR)/arm64-apple-macosx/release/$(APP) $(BUILD_DIR)/x86_64-apple-macosx/release/$(APP)
