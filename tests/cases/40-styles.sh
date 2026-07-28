#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/env.sh
source tests/lib/env.sh
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

OUT="tests/.tmp/styles"
rm -rf "$OUT"
"$HUGO" --quiet --destination "$OUT" >/dev/null 2>&1

assert_file_exists "custom stylesheet is authored" "assets/css/custom.css"
assert_file_exists "design tokens are a separate file" "assets/css/tokens.css"
assert_file_exists "RTL corrections are a separate file" "assets/css/rtl.css"

assert_file_contains "tokens declare the primary colour" \
  "assets/css/tokens.css" "--bl-color-primary"
assert_file_contains "tokens declare the Arabic font stack" \
  "assets/css/tokens.css" "--bl-font-arabic"

# Identity lives in tokens.css only.
assert_file_not_contains "rtl.css hard-codes no hex colours" "assets/css/rtl.css" "#"

# The theme must actually pick the custom CSS up.
css_found=0
for f in $(find "$OUT" -name '*.css' 2>/dev/null); do
  if grep -qF -- "--bl-color-primary" "$f"; then css_found=1; break; fi
done
assert_equals "tokens reach the built stylesheet" "1" "$css_found"

# Regression guard: Hugo's resources.Concat joins files byte-for-byte and does NOT
# resolve CSS @import. An @import in a bundled stylesheet is a silently dead
# reference. Tokens must be bundled by boundless/styles.html, never imported.
# Line-anchored: an actual import statement, not the word inside an explanatory comment.
assert_equals "custom.css contains no @import statement" "0" \
  "$(grep -cE '^[[:space:]]*@import' assets/css/custom.css)"
dead_import=0
for f in $(find "$OUT" -name '*.css' 2>/dev/null); do
  if grep -qF -- "@import" "$f"; then dead_import=1; break; fi
done
assert_equals "no @import survives into any built stylesheet" "0" "$dead_import"

finish
