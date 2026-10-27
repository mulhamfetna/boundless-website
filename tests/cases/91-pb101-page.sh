#!/usr/bin/env bash
# PB101 kit page: the QR target on the GEW Syria slides offers every kit file in both languages.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/env.sh
source tests/lib/env.sh
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

OUT="tests/.tmp/pb101"
rm -rf "$OUT"
assert_exit_code "full site builds" 0 "$HUGO" --quiet --destination "$OUT"
for d in "" "en/"; do
  f="$OUT/${d}pb101/index.html"
  assert_file_exists "${d:-ar/} pb101 page exists" "$f"
  assert_file_contains "${d:-ar/} pb101 links the workbook" "$f" "/files/pb101/PB101-Brand-Sprint-Workbook.pdf"
  assert_file_contains "${d:-ar/} pb101 links the tracker" "$f" "/files/pb101/PB101-Tracker.xlsx"
  assert_file_contains "${d:-ar/} pb101 shows the level-4 badge" "$f" "PB101-badge-level-4-fundable.png"
  assert_file_contains "${d:-ar/} pb101 has the WhatsApp community" "$f" "chat.whatsapp.com/K9appgmw9ZW7H362DjYca7"
  assert_file_contains "${d:-ar/} pb101 has the email opt-in" "$f" "mailto:contact@boundlessacademic.com"
  assert_file_contains "${d:-ar/} pb101 carries the GEW attribution" "$f" "GEN"
done
for x in PB101-Brand-Sprint-Workbook.pdf PB101-Tracker.xlsx PB101-badge-level-1-visible.png PB101-badge-level-2-credible.png PB101-badge-level-3-connected.png PB101-badge-level-4-fundable.png; do
  assert_file_exists "kit file $x is published" "$OUT/files/pb101/$x"
done
finish
