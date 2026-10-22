.DEFAULT_GOAL := help

# Hugo is pinned per-project, not taken from PATH. See scripts/install-hugo.sh
# for why. Override with `make HUGO=/path/to/hugo <target>` if you must.
HUGO_VERSION := $(shell cat .hugoversion)
HUGO_BIN := .tools/hugo-$(HUGO_VERSION)/hugo
HUGO ?= $(HUGO_BIN)

.PHONY: help setup dev build test clean

help: ## Show available targets
	@grep -E '^[a-z-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

setup: $(HUGO_BIN) ## Download the pinned Hugo binary into .tools/

$(HUGO_BIN):
	@bash scripts/install-hugo.sh

dev: setup ## Run the local development server (drafts visible)
	$(HUGO) server --buildDrafts --navigateToChanged

build: setup ## Production build into public/
	$(HUGO) --gc --minify

test: setup ## Run the full test suite
	@bash tests/run.sh

clean: ## Remove build artefacts (keeps the pinned Hugo binary)
	rm -rf public resources .hugo_build.lock tests/.tmp
