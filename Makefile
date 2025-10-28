SHELL := /bin/bash
.DEFAULT_GOAL := help

WORKSPACE := $(shell ls -1 *.xcworkspace 2>/dev/null | head -n1)
PROJECT := $(shell ls -1 *.xcodeproj 2>/dev/null | head -n1)
CONTAINER_FLAG := $(if $(WORKSPACE),-workspace $(WORKSPACE),-project $(PROJECT))

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | sed 's/:.*##/: /' | column -s ': ' -t

.PHONY: bootstrap
bootstrap: ## Resolve packages and run preflight checks
	bash scripts/preflight.sh
	@if [ -n "$(WORKSPACE)" ]; then \
		xcodebuild -resolvePackageDependencies -workspace "$(WORKSPACE)"; \
	else \
		xcodebuild -resolvePackageDependencies -project "$(PROJECT)"; \
	fi

.PHONY: build
build: ## Build all schemes (auto-discovered)
	chmod +x scripts/build_all.sh
	./scripts/build_all.sh

.PHONY: test
test: ## Test all schemes (auto-discovered)
	chmod +x scripts/test_all.sh
	./scripts/test_all.sh

.PHONY: regulated
regulated: ## Build & test using Regulated configuration where applicable
	CONFIGURATION=Regulated make build test
