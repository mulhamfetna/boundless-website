#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/env.sh
source tests/lib/env.sh
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

OUT="tests/.tmp/build"
rm -rf "$OUT"

assert_exit_code "site builds cleanly" 0 "$HUGO" --quiet --destination "$OUT"
assert_file_exists "home page generated" "$OUT/index.html"
assert_file_exists "the Boundless theme lives in the repository (no network needed)" "themes/boundless/theme.toml"
assert_file_contains "the site uses the Boundless theme" "config/_default/hugo.toml" 'theme = "boundless"'
assert_equals "no Hugo Module imports (nothing fetched at build time)" "absent" \
  "$([ -f config/_default/module.toml ] || [ -f go.mod ] && echo present || echo absent)"
assert_file_contains "Arabic site title renders" "$OUT/index.html" "باوندلس"
assert_file_contains "English site title renders" "$OUT/en/index.html" "Boundless"

# Regression guard: hugo_stats.json is a Tailwind class manifest emitted by
# build.writeStats. The theme ships precompiled CSS and never reads it, so it was
# pure churn in git — a file whose contents changed with whatever was last built.
assert_equals "build emits no hugo_stats.json artefact" "absent" \
  "$([ -f hugo_stats.json ] && echo present || echo absent)"

finish
