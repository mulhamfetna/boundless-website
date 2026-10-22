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

FONTS="themes/boundless/static/fonts"
CSS="themes/boundless/assets/css/fonts.css"
HEAD="themes/boundless/layouts/partials/head.html"

for f in thmanyahsans-Regular thmanyahsans-Medium thmanyahsans-Bold \
         thmanyahserifdisplay-Bold thmanyahserifdisplay-Black; do
  path="$FONTS/${f}.woff2"
  assert_file_exists "font present: $f" "$path"
  size=$(wc -c < "$path" 2>/dev/null || echo 0)
  if [ "$size" -gt 10000 ]; then
    assert_equals "font is a real file: $f" "big" "big"
  else
    assert_equals "font is a real file: $f" "big" "only ${size} bytes"
  fi
done
assert_file_exists "Thmanyah licence ships with the fonts" "$FONTS/Thmanyah-LICENSE.pdf"

assert_file_contains "font faces are declared" "$CSS" "@font-face"
assert_file_contains "fonts use font-display swap" "$CSS" "font-display:swap"

# Global constraint: absolutely no third-party runtime requests.
assert_file_not_contains "no Google Fonts in CSS" "$CSS" "fonts.googleapis.com"
assert_file_not_contains "no Google Fonts in head" "$HEAD" "fonts.googleapis.com"
assert_file_not_contains "no CDN reference in CSS" "$CSS" "jsdelivr"

assert_file_contains "fonts are preloaded" "$HEAD" "preload"
assert_file_contains "translation gate is still wired up" \
  "layouts/partials/hooks/head-start.html" "validate-translation.html"
assert_file_contains "style bundle is still wired up" "$HEAD" 'partial "styles.html"'

assert_file_exists "font is published to the built site" "$OUT/fonts/thmanyahsans-Regular.woff2"
face_found=0
for f in $(find "$OUT" -name '*.css' 2>/dev/null); do
  if grep -qF -- "/fonts/thmanyahsans-Regular.woff2" "$f"; then face_found=1; break; fi
done
assert_equals "font-face src reaches the built stylesheet" "1" "$face_found"

# One family covers Arabic and Latin, so both languages preload the same face.
assert_file_contains "Arabic page preloads the body face" "$OUT/index.html" "thmanyahsans-Regular.woff2"
assert_file_contains "English page preloads the body face" "$OUT/en/index.html" "thmanyahsans-Regular.woff2"

finish
