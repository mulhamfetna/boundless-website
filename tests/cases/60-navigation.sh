#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/env.sh
source tests/lib/env.sh
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

OUT="tests/.tmp/nav"
rm -rf "$OUT"
assert_exit_code "full site builds" 0 "$HUGO" --quiet --destination "$OUT"

assert_file_exists "Arabic about page" "$OUT/about/index.html"
assert_file_exists "English about page" "$OUT/en/about/index.html"

assert_file_contains "Arabic nav shows the Arabic label" "$OUT/index.html" "من نحن"
assert_file_contains "English nav shows About" "$OUT/en/index.html" "About"

for p in src1 src2 gew; do
  assert_file_exists "Arabic project page: $p" "$OUT/projects/$p/index.html"
  assert_file_exists "English project page: $p" "$OUT/en/projects/$p/index.html"
done

assert_file_contains "tagline appears on the site" "$OUT/en/index.html" "Unleash Your TRUE Academic Potential"

assert_file_exists "sitemap generated" "$OUT/sitemap.xml"
assert_file_exists "robots.txt generated" "$OUT/robots.txt"
assert_file_exists "Arabic RSS generated" "$OUT/index.xml"
assert_file_exists "English RSS generated" "$OUT/en/index.xml"

assert_file_exists "deployment runbook exists" "docs/deployment/cloudflare-pages.md"
assert_file_contains "runbook pins the Hugo version" \
  "docs/deployment/cloudflare-pages.md" "$HUGO_VERSION"

finish
