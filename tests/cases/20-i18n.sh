#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/env.sh
source tests/lib/env.sh
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

OUT="tests/.tmp/i18n"
rm -rf "$OUT"
"$HUGO" --quiet --destination "$OUT" >/dev/null 2>&1

assert_file_exists "English home is at the site root" "$OUT/index.html"
assert_file_exists "Arabic home is under /ar/" "$OUT/ar/index.html"

assert_file_contains "English page declares lang=en" "$OUT/index.html" 'lang="en"'
assert_file_contains "Arabic page declares lang=ar" "$OUT/ar/index.html" 'lang="ar"'
assert_file_contains "Arabic page declares dir=rtl" "$OUT/ar/index.html" 'dir="rtl"'
assert_file_not_contains "English page is not RTL" "$OUT/index.html" 'dir="rtl"'

assert_file_contains "English page links its Arabic counterpart" \
  "$OUT/index.html" 'hreflang="ar"'
assert_file_contains "Arabic page links its English counterpart" \
  "$OUT/ar/index.html" 'hreflang="en"'

assert_file_contains "Arabic site title is set" "$OUT/ar/index.html" "باوندلس"

finish
