#!/usr/bin/env bash
# Verifies the toolchain matches what the plan was written against.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

hugo_version="$(hugo version 2>/dev/null)"

assert_equals "hugo version is pinned to the value in .hugoversion" \
  "$(cat .hugoversion)" \
  "$(printf '%s' "$hugo_version" | sed -n 's/^hugo v\([0-9.]*\).*/\1/p')"

case "$hugo_version" in
  *extended*) assert_equals "hugo is the extended flavour" "yes" "yes" ;;
  *)          assert_equals "hugo is the extended flavour" "yes" "no" ;;
esac

assert_file_exists "Makefile exists" "Makefile"
assert_file_contains "gitignore excludes build output" ".gitignore" "public/"

finish
