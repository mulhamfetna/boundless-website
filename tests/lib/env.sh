#!/usr/bin/env bash
# Resolves the pinned Hugo binary for test cases.
#
# Tests must exercise the same Hugo the Makefile and Cloudflare use, never
# whatever happens to be on PATH. Sourced from the repository root.
HUGO_VERSION="$(cat .hugoversion)"
HUGO="${HUGO:-.tools/hugo-${HUGO_VERSION}/hugo}"
export HUGO HUGO_VERSION
