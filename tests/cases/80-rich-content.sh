#!/usr/bin/env bash
# Rich content: trainer, fellowship and attribution sections render on project pages.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/env.sh
source tests/lib/env.sh
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

OUT="tests/.tmp/rich"
rm -rf "$OUT"
assert_exit_code "full site builds" 0 "$HUGO" --quiet --destination "$OUT"

for d in "" "en/"; do
  assert_file_contains "${d:-ar/} SRC1 shows trainers" "$OUT/${d}projects/src1/index.html" 'class="people"'
  assert_file_contains "${d:-ar/} SRC2 shows fellowship tracks" "$OUT/${d}projects/src2/index.html" 'class="features"'
  assert_file_contains "${d:-ar/} SRC1 carries the donor attribution" "$OUT/${d}projects/src1/index.html" 'class="attribution"'
  assert_file_contains "${d:-ar/} GEW carries the required attribution" "$OUT/${d}projects/gew/index.html" 'class="attribution"'
done

assert_file_contains "GEW uses the official Arabic name" "$OUT/projects/gew/index.html" "الأسبوع العالمي لريادة الأعمال"
assert_file_contains "GEW shows the 2026 dates" "$OUT/en/projects/gew/index.html" "1–5 November 2026"
assert_file_not_contains "SRC2 no longer lists UNFPA as donor (unconfirmed)" "$OUT/en/projects/src2/index.html" "UNFPA"

finish
