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

# Second post: SRC2 training graduation.
P2="blog/src2-training-graduation/index.html"
for d in "" "en/"; do
  f="$OUT/${d}$P2"
  assert_file_exists "${d:-ar/} SRC2 graduation post" "$f"
  assert_file_contains "${d:-ar/} SRC2 post carries BlogPosting data" "$f" '"@type":"BlogPosting"'
  assert_file_contains "${d:-ar/} SRC2 post has a cover image" "$f" 'src2-training-graduation/cover.jpg'
done
assert_file_contains "SRC2 post names UNFPA as funder (Arabic)" "$OUT/$P2" "صندوق الأمم المتحدة للسكان"
assert_file_not_contains "SRC2 post does not name UNDP as funder" "$OUT/$P2" "الإنمائي"
assert_file_contains "English SRC2 post names UNFPA" "$OUT/en/$P2" "UNFPA Syria"

# Third post: SRC1 camp closing (13 Feb 2026).
P3="blog/src1-camp-closing/index.html"
for d in "" "en/"; do
  f="$OUT/${d}$P3"
  assert_file_exists "${d:-ar/} SRC1 closing post" "$f"
  assert_file_contains "${d:-ar/} SRC1 post carries BlogPosting data" "$f" '"@type":"BlogPosting"'
  assert_file_contains "${d:-ar/} SRC1 post has a cover image" "$f" 'src1-camp-closing/cover.jpg'
  assert_file_contains "${d:-ar/} SRC1 post is dated 13 Feb 2026" "$f" '2026-02-13'
done
assert_file_contains "SRC1 post uses the brand spelling of the founder's name" "$OUT/$P3" "م. ملهم فتنة"

# Fourth post: Mais Markabi's SAMS 24 poster (13 Nov 2026), rendered through the poster record.
P4="blog/sams24-self-medication-poster/index.html"
for d in "" "en/"; do
  f="$OUT/${d}$P4"
  assert_file_exists "${d:-ar/} SAMS poster post" "$f"
  assert_file_contains "${d:-ar/} poster post carries BlogPosting data" "$f" '"@type":"BlogPosting"'
  assert_file_contains "${d:-ar/} poster post carries ScholarlyArticle data" "$f" '"@type":"ScholarlyArticle"'
  assert_file_contains "${d:-ar/} poster post marks the work as a poster" "$f" '"genre":"Conference poster"'
  assert_file_contains "${d:-ar/} poster post carries the conference Event" "$f" '"@type":"Event"'
  assert_file_contains "${d:-ar/} poster post links the poster DOI" "$f" "https://doi.org/10.13140/RG.2.2.16539.22567"
  assert_file_contains "${d:-ar/} poster post has a cover image" "$f" 'sams24-self-medication-poster/cover.jpg'
  assert_file_contains "${d:-ar/} poster post lists the last author" "$f" "Wassim Abdelwahed"
  assert_file_contains "${d:-ar/} poster post cites it as a poster" "$f" "[Poster]"
  assert_file_contains "${d:-ar/} poster post is dated 13 Nov 2026" "$f" '2026-11-13'
  assert_file_not_contains "${d:-ar/} poster post claims no journal licence" "$f" 'open access'
done
assert_file_contains "Arabic poster post uses the brand spelling of the founder's name" "$OUT/$P4" "م. ملهم فتنة"
assert_file_contains "Arabic poster post shows the conference label" "$OUT/$P4" "المؤتمر"

# The journal post still renders as a journal article after the poster support.
assert_file_contains "journal post still shows its licence" "$OUT/$POST" 'open access'
assert_file_not_contains "journal post is not marked as a poster" "$OUT/$POST" 'Conference poster'

# Post layout: side column with contents and share links, poster thumbnail with a lightbox,
# a badge on the English card in Arabic pages, and a fourth number on the poster post.
for d in "" "en/"; do
  f="$OUT/${d}$P4"
  assert_file_contains "${d:-ar/} poster post has the side column" "$f" 'class="post-aside"'
  assert_file_contains "${d:-ar/} poster post lists its sections" "$f" 'id="TableOfContents"'
  assert_file_contains "${d:-ar/} poster post has share links" "$f" 'linkedin.com/sharing/share-offsite'
  assert_file_contains "${d:-ar/} poster post shows a poster thumbnail" "$f" 'class="poster-thumb"'
  assert_file_contains "${d:-ar/} poster post opens the poster in a lightbox" "$f" 'id="poster-full"'
  assert_file_contains "${d:-ar/} poster post shows four numbers" "$f" '84.6%'
done
assert_file_contains "Arabic poster card says the text is the original English" "$OUT/$P4" 'class="orig-badge"'
assert_file_not_contains "English poster card has no language badge" "$OUT/en/$P4" 'class="orig-badge"'
assert_file_contains "journal post also gets the side column" "$OUT/$POST" 'class="post-aside"'
assert_file_not_contains "journal post has no poster thumbnail" "$OUT/$POST" 'class="poster-thumb"'

# Poster post wording (13 Nov review): full APA author list, Arabic names and the local term
# for antibiotics in the Arabic text, and the Damascus study described as hospital-based.
for d in "" "en/"; do
  assert_file_contains "${d:-ar/} poster citation lists every author" "$OUT/${d}$P4" "Markabi, M., Buz Khalloof, A., Alammouri, J., Fetna, M., Kourany, S., Maktabi, T., Shikh Dibs, Z., &amp; Abdelwahed, W. (2026)"
done
assert_file_contains "Arabic poster post names the team in Arabic" "$OUT/$P4" "آلاء بوظ خلوف"
assert_file_contains "Arabic poster post uses the term صادات حيوية" "$OUT/$P4" "صادات حيوية"
assert_file_not_contains "Arabic poster post no longer says مضادات حيوية" "$OUT/$P4" "مضادات حيوية"
assert_file_contains "Arabic poster post calls the Damascus study hospital-based" "$OUT/$P4" "أُجريت في المشافي"
assert_file_contains "English poster post calls the Damascus study hospital-based" "$OUT/en/$P4" "hospital-based Damascus reference study"
assert_file_contains "journal post keeps its et al. citation" "$OUT/$POST" "et al. (2026)"

finish
