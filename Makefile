.DEFAULT_GOAL := help
HUGO ?= hugo

.PHONY: help dev build test clean theme-update

help: ## Show available targets
	@grep -E '^[a-z-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

dev: ## Run the local development server (drafts visible)
	$(HUGO) server --buildDrafts --navigateToChanged

build: ## Production build into public/
	$(HUGO) --gc --minify

test: ## Run the full test suite
	@bash tests/run.sh

clean: ## Remove build artefacts
	rm -rf public resources .hugo_build.lock

theme-update: ## Deliberately update and re-vendor the Blowfish theme
	$(HUGO) mod get -u github.com/nunocoracao/blowfish/v2
	$(HUGO) mod vendor
	@echo "Theme updated. Run 'make test' before committing."
