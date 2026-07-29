#!/usr/bin/env bash
# Verifies the toolchain matches what the plan was written against.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/env.sh
source tests/lib/env.sh
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

assert_file_exists "pinned Hugo binary is installed" "$HUGO"

hugo_version="$("$HUGO" version 2>/dev/null)"

assert_equals "hugo version matches .hugoversion" \
  "$HUGO_VERSION" \
  "$(printf '%s' "$hugo_version" | sed -n 's/^hugo v\([0-9.]*\).*/\1/p')"

case "$hugo_version" in
  *extended*) assert_equals "hugo is the extended flavour" "yes" "yes" ;;
  *)          assert_equals "hugo is the extended flavour" "yes" "no" ;;
esac

# The theme declares a supported Hugo range; running outside it is unsupported.
assert_equals "hugo is inside the theme's supported range" "" \
  "$("$HUGO" --quiet --destination tests/.tmp/toolchain 2>&1 | grep -F 'not compatible with this Hugo version')"

assert_file_exists "Makefile exists" "Makefile"
assert_file_contains "gitignore excludes build output" ".gitignore" "public/"
assert_file_contains "gitignore excludes the pinned toolchain" ".gitignore" ".tools/"

finish
