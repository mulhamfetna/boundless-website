#!/usr/bin/env bash
# GEW Syria 2026 project page: the week is over, so the page shows what Boundless delivered.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/env.sh
source tests/lib/env.sh
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

OUT="tests/.tmp/gew"
rm -rf "$OUT"
assert_exit_code "full site builds" 0 "$HUGO" --quiet --destination "$OUT"
AR="$OUT/projects/gew/index.html"
EN="$OUT/en/projects/gew/index.html"
assert_file_exists "ar GEW page exists" "$AR"
assert_file_exists "en GEW page exists" "$EN"
assert_file_contains "ar GEW is marked completed" "$AR" "منتهٍ"
assert_file_not_contains "ar GEW no longer says events are announced soon" "$AR" "نعلن هنا عن فعالياتنا"
assert_file_contains "ar GEW lists the Day 3 workshop" "$AR" "من الفكرة إلى الفريق"
assert_file_contains "ar GEW names Nael Rihawi" "$AR" "نائل ريحاوي"
assert_file_contains "ar GEW credits the students union" "$AR" "الاتحاد الوطني لطلبة سوريا"
assert_file_contains "ar GEW links the PB101 kit" "$AR" 'href="/pb101/"'
assert_file_contains "en GEW lists the Day 3 workshop" "$EN" "From Idea to Team"
assert_file_contains "en GEW links the PB101 kit" "$EN" 'href="/en/pb101/"'
for i in hero-rihawi gallery-opening gallery-pitch gallery-day2-room gallery-day2-fetna gallery-day2-exercise gallery-day3-audience gallery-day3-qa gallery-day3-rihawi-fetna; do
  assert_file_exists "GEW image $i is published" "$OUT/images/gew-$i.jpg"
done
finish
