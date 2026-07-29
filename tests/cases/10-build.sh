#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/env.sh
source tests/lib/env.sh
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

OUT="tests/.tmp/build"
rm -rf "$OUT"

assert_exit_code "site builds cleanly" 0 "$HUGO" --quiet --destination "$OUT"
assert_file_exists "home page generated" "$OUT/index.html"
assert_file_exists "theme is vendored (no network needed)" "_vendor/modules.txt"
assert_file_contains "Blowfish is the pinned theme" "go.mod" "github.com/nunocoracao/blowfish/v2"
assert_file_contains "site title renders" "$OUT/index.html" "Boundless Academic Services"

finish
