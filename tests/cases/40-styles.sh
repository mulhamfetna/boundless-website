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

CSS="themes/boundless/assets/css"
assert_file_exists "design tokens are a separate file" "$CSS/tokens.css"
assert_file_exists "font faces are a separate file" "$CSS/fonts.css"
assert_file_exists "components are a separate file" "$CSS/boundless.css"

assert_file_contains "tokens declare the primary colour" "$CSS/tokens.css" "--bl-color-primary"
assert_file_contains "tokens declare the brand teal" "$CSS/tokens.css" "--bl-color-teal:#146C94"
assert_file_contains "tokens declare the Arabic font stack" "$CSS/tokens.css" "--bl-font-arabic"

# Identity lives in tokens.css only: the component sheet may not hard-code colours.
assert_equals "components hard-code no hex colours" "0" \
  "$(grep -cE '#[0-9A-Fa-f]{3,6}\b' "$CSS/boundless.css")"

# The bundle must actually reach the page.
css_found=0
for f in $(find "$OUT" -name '*.css' 2>/dev/null); do
  if grep -qF -- "--bl-color-primary" "$f"; then css_found=1; break; fi
done
assert_equals "tokens reach the built stylesheet" "1" "$css_found"
assert_file_contains "the page links one fingerprinted bundle" "$OUT/index.html" "boundless.bundle.min."

# resources.Concat does not resolve CSS imports, so an import would be a dead reference.
dead_import=0
for f in "$CSS"/*.css $(find "$OUT" -name '*.css' 2>/dev/null); do
  if grep -qE '^[[:space:]]*@import' "$f"; then dead_import=1; break; fi
done
assert_equals "no @import in source or built stylesheets" "0" "$dead_import"

finish
