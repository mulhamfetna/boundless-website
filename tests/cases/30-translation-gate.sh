#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/env.sh
source tests/lib/env.sh
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

build_with_content() { # $1 = content dir, $2 = destination
  HUGO_CONTENTDIR="$1" "$HUGO" --quiet --destination "$2" >/dev/null 2>&1
}

rm -rf tests/.tmp/gate-orphan tests/.tmp/gate-paired

assert_exit_code "a page with no counterpart fails the build" 1 \
  build_with_content tests/fixtures/orphan tests/.tmp/gate-orphan

assert_exit_code "fully paired content builds cleanly" 0 \
  build_with_content tests/fixtures/paired tests/.tmp/gate-paired

# The error message must name the offending file, or it is useless to an author.
error_output="$(HUGO_CONTENTDIR=tests/fixtures/orphan "$HUGO" --destination tests/.tmp/gate-orphan 2>&1)"
case "$error_output" in
  *lonely*) assert_equals "the failure names the offending page" "yes" "yes" ;;
  *)        assert_equals "the failure names the offending page" "yes" "no" ;;
esac
case "$error_output" in
  *"TRANSLATION GATE"*) assert_equals "the failure is clearly labelled" "yes" "yes" ;;
  *)                    assert_equals "the failure is clearly labelled" "yes" "no" ;;
esac

# Drafts are exempt: tests/fixtures/paired contains wip.en.md with no Arabic pair.
assert_file_exists "paired build produced output" "tests/.tmp/gate-paired/index.html"

finish
