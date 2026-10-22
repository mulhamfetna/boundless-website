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

# Arabic is primary at the root; English under /en/ (decision log 2026-10-23, supersedes D1).
assert_file_exists "Arabic home is at the site root" "$OUT/index.html"
assert_file_exists "English home is under /en/" "$OUT/en/index.html"

assert_file_contains "Arabic page declares lang=ar" "$OUT/index.html" 'lang="ar"'
assert_file_contains "English page declares lang=en" "$OUT/en/index.html" 'lang="en"'
assert_file_contains "Arabic page declares dir=rtl" "$OUT/index.html" 'dir="rtl"'
assert_file_not_contains "English page is not RTL" "$OUT/en/index.html" 'dir="rtl"'

assert_file_contains "Arabic page links its English counterpart" \
  "$OUT/index.html" 'hreflang="en"'
assert_file_contains "English page links its Arabic counterpart" \
  "$OUT/en/index.html" 'hreflang="ar"'
assert_file_contains "x-default points search engines to the Arabic page" \
  "$OUT/en/index.html" 'hreflang="x-default" href="https://boundlessacademic.com/"'

assert_file_contains "Arabic site title is set" "$OUT/index.html" "باوندلس"

finish
