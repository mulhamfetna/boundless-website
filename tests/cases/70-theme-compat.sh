#!/usr/bin/env bash
# Regression guard for the 2026-10-23 production outage: Cloudflare built with an
# older Hugo than .hugoversion, and a direct .Language.Locale call failed every
# page. Language fields that only exist from Hugo 0.158.0 must go through the
# version-guarded partials/lang-info.html.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

LAYOUTS="themes/boundless/layouts"
assert_file_exists "version-safe language helper exists" "$LAYOUTS/partials/lang-info.html"
assert_file_contains "helper guards the newer fields by Hugo version" \
  "$LAYOUTS/partials/lang-info.html" 'ge hugo.Version "0.158.0"'

direct="$(grep -rnE '\.Language\.(Locale|Label|Direction)|site\.Language\.(Locale|Label|Direction)' "$LAYOUTS" \
  | grep -v 'partials/lang-info.html' | wc -l)"
assert_equals "no template reads locale/label/direction directly" "0" "$direct"

assert_equals "no template depends on hugo.Sites.Default" "0" \
  "$(grep -rn 'hugo.Sites.Default' "$LAYOUTS" | wc -l)"

finish
