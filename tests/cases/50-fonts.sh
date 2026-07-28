#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/env.sh
source tests/lib/env.sh
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

OUT="tests/.tmp/fonts"
rm -rf "$OUT"
"$HUGO" --quiet --destination "$OUT" >/dev/null 2>&1

HEAD_PARTIAL="layouts/partials/extend-head-uncached.html"

for f in arabic-400 arabic-600 latin-400 latin-600; do
  path="static/fonts/ibm-plex-sans-arabic-${f}-normal.woff2"
  assert_file_exists "font present: $f" "$path"
  size=$(wc -c < "$path" 2>/dev/null || echo 0)
  if [ "$size" -gt 10000 ]; then
    assert_equals "font is a real file: $f" "big" "big"
  else
    assert_equals "font is a real file: $f" "big" "only ${size} bytes"
  fi
done

assert_file_contains "font faces are declared" "assets/css/fonts.css" "@font-face"
assert_file_contains "fonts use font-display swap" "assets/css/fonts.css" "font-display: swap"

# Global constraint: absolutely no third-party runtime requests.
assert_file_not_contains "no Google Fonts in CSS" "assets/css/fonts.css" "fonts.googleapis.com"
assert_file_not_contains "no Google Fonts in head" "$HEAD_PARTIAL" "fonts.googleapis.com"
assert_file_not_contains "no CDN reference in CSS" "assets/css/fonts.css" "jsdelivr"

assert_file_contains "Arabic font is preloaded" "$HEAD_PARTIAL" "preload"
assert_file_contains "translation gate is still wired up" \
  "$HEAD_PARTIAL" "validate-translation.html"
assert_file_contains "style bundle is still wired up" \
  "$HEAD_PARTIAL" "boundless/styles.html"

# The font faces must actually reach the page, and the files must be served.
assert_file_exists "font is published to the built site" \
  "$OUT/fonts/ibm-plex-sans-arabic-arabic-400-normal.woff2"
# Check for the actual @font-face src, not merely the family name — the family
# name also appears in the --bl-font-arabic token, which would make this vacuous.
face_found=0
for f in $(find "$OUT" -name '*.css' 2>/dev/null); do
  if grep -qF -- "/fonts/ibm-plex-sans-arabic-arabic-400-normal.woff2" "$f"; then face_found=1; break; fi
done
assert_equals "font-face src reaches the built stylesheet" "1" "$face_found"

# Each language preloads only the subset it renders.
assert_file_contains "Arabic page preloads the Arabic subset" \
  "$OUT/ar/index.html" "ibm-plex-sans-arabic-arabic-400-normal.woff2"
assert_file_not_contains "English page does not preload the Arabic subset" \
  "$OUT/index.html" "ibm-plex-sans-arabic-arabic-400-normal.woff2"

finish
