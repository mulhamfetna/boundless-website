#!/usr/bin/env bash
# Title workshop kit: the QR target on the closing slide of the title workshop offers the playbook and tracker in both languages.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/env.sh
source tests/lib/env.sh
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

OUT="tests/.tmp/title-kit"
rm -rf "$OUT"
assert_exit_code "full site builds" 0 "$HUGO" --quiet --destination "$OUT"
for d in "" "en/"; do
  f="$OUT/${d}title-kit/index.html"
  assert_file_exists "${d:-ar/} title-kit page exists" "$f"
  assert_file_contains "${d:-ar/} title-kit links the playbook" "$f" "/files/title-kit/Boundless-Title-Playbook.pdf"
  assert_file_contains "${d:-ar/} title-kit links the tracker" "$f" "/files/title-kit/Boundless-Title-Tracker.xlsx"
  assert_file_contains "${d:-ar/} title-kit has the WhatsApp community" "$f" "chat.whatsapp.com/K9appgmw9ZW7H362DjYca7"
  assert_file_contains "${d:-ar/} title-kit has the email for feedback" "$f" "mailto:contact@boundlessacademic.com"
  assert_file_not_contains "${d:-ar/} title-kit carries no GEW hashtags" "$f" "#GEWSyria"
done
assert_file_contains "pb101 keeps its GEW hashtags" "$OUT/pb101/index.html" "#GEWSyria"
for x in Boundless-Title-Playbook.pdf Boundless-Title-Tracker.xlsx; do
  assert_file_exists "kit file $x is published" "$OUT/files/title-kit/$x"
done
finish
