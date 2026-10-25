#!/usr/bin/env bash
# Links page: the QR target printed on the notebook lists every channel in both languages.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/env.sh
source tests/lib/env.sh
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

OUT="tests/.tmp/links"
rm -rf "$OUT"
assert_exit_code "full site builds" 0 "$HUGO" --quiet --destination "$OUT"
for d in "" "en/"; do
  f="$OUT/${d}links/index.html"
  assert_file_exists "${d:-ar/} links page exists" "$f"
  assert_file_contains "${d:-ar/} links page has the WhatsApp community" "$f" "chat.whatsapp.com/K9appgmw9ZW7H362DjYca7"
  assert_file_contains "${d:-ar/} links page has Instagram" "$f" "instagram.com/boundless.academics"
  assert_file_contains "${d:-ar/} links page has Facebook" "$f" "facebook.com/share/19g1TDgEC2"
  assert_file_contains "${d:-ar/} links page has the paper DOI" "$f" "10.1016/j.hybadv.2026.100657"
done
finish
