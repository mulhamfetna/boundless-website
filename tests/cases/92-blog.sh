#!/usr/bin/env bash
# Blog: the section, the first post (the SRC1 paper), its paper block and structured data.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/env.sh
source tests/lib/env.sh
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

OUT="tests/.tmp/blog"
rm -rf "$OUT"
assert_exit_code "full site builds" 0 "$HUGO" --quiet --destination "$OUT"

POST="blog/hap-scaffold-hybrid-advances/index.html"
assert_file_exists "Arabic blog list" "$OUT/blog/index.html"
assert_file_exists "English blog list" "$OUT/en/blog/index.html"
assert_file_exists "Arabic post" "$OUT/$POST"
assert_file_exists "English post" "$OUT/en/$POST"
assert_file_contains "Arabic nav shows the blog" "$OUT/index.html" "المدونة"
assert_file_contains "English nav shows the blog" "$OUT/en/index.html" "Blog"

for d in "" "en/"; do
  f="$OUT/${d}$POST"
  assert_file_contains "${d:-ar/} post links the DOI" "$f" "https://doi.org/10.1016/j.hybadv.2026.100657"
  assert_file_contains "${d:-ar/} post carries ScholarlyArticle data" "$f" '"@type":"ScholarlyArticle"'
  assert_file_contains "${d:-ar/} post carries BlogPosting data" "$f" '"@type":"BlogPosting"'
  assert_file_contains "${d:-ar/} post carries FAQPage data" "$f" '"@type":"FAQPage"'
  assert_file_contains "${d:-ar/} post shows the abstract" "$f" 'class="abstract"'
  assert_file_contains "${d:-ar/} post lists all published authors" "$f" "Ola Alaa Hamad"
  assert_file_contains "${d:-ar/} post states Q2" "$f" "Q2"
  assert_file_not_contains "${d:-ar/} post does not claim Q1" "$f" "Q1"
done
assert_file_contains "Arabic post uses the brand spelling of the founder's name" "$OUT/$POST" "ملهم فتنة"
assert_file_not_contains "Arabic post has no old spelling of the founder's name" "$OUT/$POST" "ملهم فتنه"

finish
