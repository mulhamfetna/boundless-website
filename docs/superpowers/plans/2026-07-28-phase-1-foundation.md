# Phase 1: Foundation — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up a bilingual (English/Arabic) Hugo site on the Blowfish theme that builds reproducibly, enforces the both-languages-or-it-does-not-publish rule at build time, carries the design-token layer the visual identity will drop into, and is ready to connect to Cloudflare Pages.

**Architecture:** Hugo static site with Blowfish imported as a Hugo Module and **vendored** into `_vendor/`, so builds need neither Go nor network access and an upstream release can never break a deploy. English is the default language served at `/`; Arabic is served at `/ar/` with RTL layout. A validation partial hooked into Blowfish's `extend-head-uncached.html` extension point runs on every rendered page and calls `errorf` when a page has no counterpart translation — Hugo then exits non-zero, so Cloudflare refuses to deploy. Tests are shell scripts that build the site (optionally against fixture content directories via the `HUGO_CONTENTDIR` environment override) and assert on exit codes and generated HTML.

**Tech Stack:** Hugo 0.164.0 extended (pinned in `.tools/`) · Blowfish v2.105.0 (Hugo Module, vendored) · TOML config · Bash test harness · GNU Make · Cloudflare Pages

## Global Constraints

- **Hugo version:** 0.164.0 extended, **pinned per-project** in `.hugoversion` and installed into `.tools/` by `make setup`. Never taken from `PATH`. The extended flavour is required (Blowfish needs SCSS transpilation).
  - *Revised during execution.* The plan was originally written against the system Hugo 0.154.5. Blowfish v2.105.0 declares a supported range of 0.158.0–0.164.0, so 0.154.5 is below its minimum — it builds a trivial page but the combination is unsupported. Resolved by pinning Hugo 0.164.0 (top of the supported range, and the latest release) inside the repository rather than upgrading the system package. `tests/cases/00-toolchain.sh` asserts the compatibility warning is absent, so this cannot silently regress.
- **Blowfish version:** pinned exactly, vendored into `_vendor/`. Never `hugo mod get -u` outside a deliberate theme-update task.
- **Languages:** English `en` is `defaultContentLanguage`, served at `/` (`defaultContentLanguageInSubdir = false`). Arabic `ar` served at `/ar/`, direction RTL.
- **Translation rule:** every non-draft page of kind `page`, `section`, or `home` that has a source file MUST have a counterpart in the other language. Violations fail the build.
- **Drafts are exempt** from the translation rule (`draft: true`).
- **No third-party runtime requests.** Fonts are self-hosted. No Google Fonts, no CDN CSS or JS.
- **Organisation name:** "Boundless Academic Services" (English), "باوندلس للخدمات الأكاديمية" (Arabic).
- **Tagline:** "Unleash Your True Academic Potential".
- **Colour, type and spacing** are declared only in `assets/css/tokens.css`. No hard-coded colour values anywhere else.
- **Every test run must be non-interactive** and exit non-zero on any failure.

- **Test cases resolve Hugo through `tests/lib/env.sh`**, which exports `$HUGO`. Every case sources `env.sh` before `assert.sh` and invokes `"$HUGO"`, never bare `hugo`.

**Verified before writing this plan (do not re-litigate):**
- `errorf` in a partial causes `hugo` to exit 1 (`error building site: logged 1 error(s)`).
- `HUGO_CONTENTDIR=<dir> hugo` overrides the content directory, which is how fixture-based tests work.
- With `defaultContentLanguageInSubdir = false`, Hugo emits English at `/` and Arabic at `/ar/`, plus a redirect stub at `/en/`.
- All four font URLs in Task 6 return HTTP 200 with real file sizes.

---

### Task 1: Repository scaffolding and test harness

**Files:**
- Create: `Makefile`
- Create: `.hugoversion`
- Create: `README.md`
- Modify: `.gitignore`
- Create: `tests/run.sh`
- Create: `tests/lib/assert.sh`
- Test: `tests/cases/00-toolchain.sh`

**Interfaces:**
- Consumes: nothing.
- Produces: the assertion library every later task's tests use —
  `assert_equals <name> <expected> <actual>`,
  `assert_exit_code <name> <expected-code> <command...>`,
  `assert_file_exists <name> <path>`,
  `assert_file_contains <name> <path> <substring>`,
  `assert_file_not_contains <name> <path> <substring>`,
  and `finish` (exits with the number of failed assertions).
  Also produces `make test`, `make build`, `make dev`, `make clean`.

- [x] **Step 1: Write the failing test**

Create `tests/cases/00-toolchain.sh`:

```bash
#!/usr/bin/env bash
# Verifies the toolchain matches what the plan was written against.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

hugo_version="$(hugo version 2>/dev/null)"

assert_equals "hugo version is pinned to the value in .hugoversion" \
  "$(cat .hugoversion)" \
  "$(printf '%s' "$hugo_version" | sed -n 's/^hugo v\([0-9.]*\).*/\1/p')"

case "$hugo_version" in
  *extended*) assert_equals "hugo is the extended flavour" "yes" "yes" ;;
  *)          assert_equals "hugo is the extended flavour" "yes" "no" ;;
esac

assert_file_exists "Makefile exists" "Makefile"
assert_file_contains "gitignore excludes build output" ".gitignore" "public/"

finish
```

- [x] **Step 2: Run it to make sure it fails**

Run: `bash tests/cases/00-toolchain.sh`
Expected: FAIL — `tests/lib/assert.sh: No such file or directory`.

- [x] **Step 3: Write the assertion library**

Create `tests/lib/assert.sh`:

```bash
#!/usr/bin/env bash
# Minimal assertion helpers. Each case script sources this, runs assertions,
# and ends with `finish`, which exits with the count of failures.
ASSERT_FAILURES=0
ASSERT_TOTAL=0

_assert_pass() {
  ASSERT_TOTAL=$((ASSERT_TOTAL + 1))
  printf '  \033[32m✓\033[0m %s\n' "$1"
}

_assert_fail() {
  ASSERT_TOTAL=$((ASSERT_TOTAL + 1))
  ASSERT_FAILURES=$((ASSERT_FAILURES + 1))
  printf '  \033[31m✗\033[0m %s\n' "$1"
  printf '      %s\n' "$2"
}

assert_equals() {
  local name="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    _assert_pass "$name"
  else
    _assert_fail "$name" "expected [$expected] but got [$actual]"
  fi
}

assert_exit_code() {
  local name="$1" expected="$2"; shift 2
  "$@" >/dev/null 2>&1
  local actual=$?
  if [ "$expected" -eq "$actual" ]; then
    _assert_pass "$name"
  else
    _assert_fail "$name" "expected exit $expected but got $actual from: $*"
  fi
}

assert_file_exists() {
  local name="$1" path="$2"
  if [ -f "$path" ]; then
    _assert_pass "$name"
  else
    _assert_fail "$name" "file not found: $path"
  fi
}

assert_file_contains() {
  local name="$1" path="$2" needle="$3"
  if [ ! -f "$path" ]; then
    _assert_fail "$name" "file not found: $path"
  elif grep -qF -- "$needle" "$path"; then
    _assert_pass "$name"
  else
    _assert_fail "$name" "[$needle] not found in $path"
  fi
}

assert_file_not_contains() {
  local name="$1" path="$2" needle="$3"
  if [ ! -f "$path" ]; then
    _assert_fail "$name" "file not found: $path"
  elif grep -qF -- "$needle" "$path"; then
    _assert_fail "$name" "[$needle] unexpectedly present in $path"
  else
    _assert_pass "$name"
  fi
}

finish() {
  printf '  %d assertion(s), %d failure(s)\n' "$ASSERT_TOTAL" "$ASSERT_FAILURES"
  exit "$ASSERT_FAILURES"
}
```

- [x] **Step 4: Write the test runner**

Create `tests/run.sh`:

```bash
#!/usr/bin/env bash
# Runs every case in tests/cases/ in filename order.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

failed_cases=0
for case_file in tests/cases/*.sh; do
  [ -f "$case_file" ] || continue
  printf '\n▸ %s\n' "$(basename "$case_file")"
  if ! bash "$case_file"; then
    failed_cases=$((failed_cases + 1))
  fi
done

printf '\n'
if [ "$failed_cases" -eq 0 ]; then
  printf '\033[32mAll test cases passed.\033[0m\n'
  exit 0
fi
printf '\033[31m%d test case(s) failed.\033[0m\n' "$failed_cases"
exit 1
```

- [x] **Step 5: Write the version pin, Makefile, README and gitignore**

Create `.hugoversion` containing exactly one line:

```
0.154.5
```

Create `Makefile`:

```make
.DEFAULT_GOAL := help
HUGO ?= hugo

.PHONY: help dev build test clean theme-update

help: ## Show available targets
	@grep -E '^[a-z-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

dev: ## Run the local development server (drafts visible)
	$(HUGO) server --buildDrafts --navigateToChanged

build: ## Production build into public/
	$(HUGO) --gc --minify

test: ## Run the full test suite
	@bash tests/run.sh

clean: ## Remove build artefacts
	rm -rf public resources .hugo_build.lock

theme-update: ## Deliberately update and re-vendor the Blowfish theme
	$(HUGO) mod get -u github.com/nunocoracao/blowfish/v2
	$(HUGO) mod vendor
	@echo "Theme updated. Run 'make test' before committing."
```

Note: Makefile recipe lines must be indented with a TAB, not spaces.

Create `README.md`:

```markdown
# Boundless Academic Services — Website

Bilingual (English / Arabic) static site built with Hugo and the Blowfish theme.

- **Design spec:** `docs/superpowers/specs/2026-07-28-boundless-website-design.md`
- **English** is served at `/`, **Arabic** at `/ar/` with RTL layout.

## Requirements

- Hugo **extended** — exact version in `.hugoversion`
- GNU Make

The theme is vendored in `_vendor/`, so Go and network access are not needed to build.

## Commands

| Command | What it does |
|---|---|
| `make dev` | Local dev server, drafts visible |
| `make build` | Production build into `public/` |
| `make test` | Full test suite |
| `make clean` | Remove build artefacts |
| `make theme-update` | Deliberately update the pinned theme |

## The translation rule

Every non-draft page must exist in **both** English and Arabic. A page without its
counterpart fails the build. Work in progress belongs in `draft: true`, which is exempt.
```

Replace `.gitignore` with:

```
public/
resources/_gen/
.hugo_build.lock
node_modules/
.DS_Store
tests/.tmp/
```

- [x] **Step 6: Run the test to verify it passes**

Run: `make test`
Expected: PASS — `00-toolchain.sh` reports 4 assertions, 0 failures.

- [x] **Step 7: Commit**

```bash
chmod +x tests/run.sh tests/lib/assert.sh tests/cases/00-toolchain.sh
git add Makefile .hugoversion README.md .gitignore tests/
git commit -m "chore: add repo scaffolding, Makefile and shell test harness"
```

---

### Task 2: Hugo site with Blowfish vendored

**Files:**
- Create: `hugo.toml`
- Create: `config/_default/hugo.toml`
- Create: `config/_default/module.toml`
- Create: `config/_default/params.toml`
- Create: `go.mod`, `go.sum` (generated)
- Create: `_vendor/` (generated, committed)
- Create: `content/_index.en.md`
- Test: `tests/cases/10-build.sh`

**Interfaces:**
- Consumes: `tests/lib/assert.sh` from Task 1.
- Produces: a buildable site. Config lives in `config/_default/`; later tasks add `languages.*.toml` and `menus.*.toml` beside it. Blowfish is importable at module path `github.com/nunocoracao/blowfish/v2`.

- [x] **Step 1: Write the failing test**

Create `tests/cases/10-build.sh`:

```bash
#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

OUT="tests/.tmp/build"
rm -rf "$OUT"

assert_exit_code "site builds cleanly" 0 hugo --quiet --destination "$OUT"
assert_file_exists "home page generated" "$OUT/index.html"
assert_file_exists "theme is vendored (no network needed)" "_vendor/modules.txt"
assert_file_contains "Blowfish is the pinned theme" "go.mod" "github.com/nunocoracao/blowfish/v2"
assert_file_contains "site title renders" "$OUT/index.html" "Boundless Academic Services"

finish
```

- [x] **Step 2: Run it to make sure it fails**

Run: `bash tests/cases/10-build.sh`
Expected: FAIL — no `go.mod`, no config, build errors.

- [x] **Step 3: Initialise the Hugo module and fetch the theme**

```bash
hugo mod init github.com/mulhamfetna/boundless-website
hugo mod get github.com/nunocoracao/blowfish/v2@v2.105.0
```

If `v2.105.0` is not resolvable, run `hugo mod get github.com/nunocoracao/blowfish/v2` and record whatever exact version lands in `go.mod` — the requirement is that it is *pinned*, not that it is that specific number. Update the spec's §4 if the version differs.

- [x] **Step 4: Write the configuration**

Create `hugo.toml` (root — deliberately minimal; everything real lives in `config/_default/`):

```toml
# Root config is intentionally empty.
# Real configuration lives in config/_default/ so that per-environment
# overrides can be layered in config/production/ later.
```

Create `config/_default/hugo.toml`:

```toml
baseURL = "https://boundless.example/"
title = "Boundless Academic Services"

defaultContentLanguage = "en"
defaultContentLanguageInSubdir = false
enableRobotsTXT = true
enableGitInfo = false
summaryLength = 30

# Build must be loud about problems rather than silently shipping them.
[build]
  writeStats = true

[taxonomies]
  tag = "tags"

[markup.goldmark.renderer]
  unsafe = true

[markup.highlight]
  noClasses = false

[outputs]
  home = ["HTML", "RSS"]
  page = ["HTML"]
  section = ["HTML", "RSS"]
```

`baseURL` is a placeholder until the real Cloudflare domain is known (spec §12). Task 7 covers changing it.

Create `config/_default/module.toml`:

```toml
[[imports]]
  path = "github.com/nunocoracao/blowfish/v2"
```

Create `config/_default/params.toml`:

```toml
colorScheme = "blowfish"
defaultAppearance = "light"
autoSwitchAppearance = true

enableSearch = true
enableCodeCopy = false

mainSections = ["articles"]
robots = "index, follow"

[header]
  layout = "basic"

[footer]
  showMenu = true
  showCopyright = true
  showThemeAttribution = true
  showAppearanceSwitcher = true
  showScrollToTop = true

[homepage]
  layout = "page"
  showRecent = false

[article]
  showDate = true
  showAuthor = true
  showBreadcrumbs = true
  showTaxonomies = true
  showWordCount = false
  showReadingTime = false
  showTableOfContents = false
  showPagination = false
  showEdit = false
```

- [x] **Step 5: Write the home page content**

Create `content/_index.en.md`:

```markdown
---
title: "Boundless Academic Services"
description: "Unleash Your True Academic Potential."
translationKey: "home"
---

Boundless Academic Services works with students and researchers across scholarship
mentorship, scientific research, and global curricula.
```

English only for now. The Arabic counterpart arrives in Task 3, together with the
language configuration — a `.ar.md` file without a configured `ar` language would be
handled unpredictably by Hugo, so the two land in the same task.

- [x] **Step 6: Vendor the theme**

```bash
hugo mod vendor
```

This writes `_vendor/`, which **is committed**. From here the build needs neither Go nor network access, so an upstream release cannot break a Cloudflare deploy.

- [x] **Step 7: Run the tests to verify they pass**

Run: `make test`
Expected: PASS — both `00-toolchain.sh` and `10-build.sh` report 0 failures.

- [x] **Step 8: Commit**

```bash
git add hugo.toml config/ go.mod go.sum _vendor/ content/ tests/cases/10-build.sh
git commit -m "feat: initialise Hugo site with Blowfish pinned and vendored"
```

---

### Task 3: Bilingual routing and RTL

**Files:**
- Create: `config/_default/languages.en.toml`
- Create: `config/_default/languages.ar.toml`
- Create: `content/_index.ar.md`
- Test: `tests/cases/20-i18n.sh`

**Interfaces:**
- Consumes: the config directory from Task 2.
- Produces: two configured languages. Later tasks rely on English output at `<out>/index.html` and Arabic at `<out>/ar/index.html`.

- [x] **Step 1: Write the failing test**

Create `tests/cases/20-i18n.sh`:

```bash
#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

OUT="tests/.tmp/i18n"
rm -rf "$OUT"
hugo --quiet --destination "$OUT" >/dev/null 2>&1

assert_file_exists "English home is at the site root" "$OUT/index.html"
assert_file_exists "Arabic home is under /ar/" "$OUT/ar/index.html"

assert_file_contains "English page declares lang=en" "$OUT/index.html" 'lang="en"'
assert_file_contains "Arabic page declares lang=ar" "$OUT/ar/index.html" 'lang="ar"'
assert_file_contains "Arabic page declares dir=rtl" "$OUT/ar/index.html" 'dir="rtl"'
assert_file_not_contains "English page is not RTL" "$OUT/index.html" 'dir="rtl"'

assert_file_contains "English page links its Arabic counterpart" \
  "$OUT/index.html" 'hreflang="ar"'
assert_file_contains "Arabic page links its English counterpart" \
  "$OUT/ar/index.html" 'hreflang="en"'

assert_file_contains "Arabic site title is set" "$OUT/ar/index.html" "باوندلس"

finish
```

- [x] **Step 2: Run it to make sure it fails**

Run: `bash tests/cases/20-i18n.sh`
Expected: FAIL — no `/ar/` output exists yet.

- [x] **Step 3: Discover the theme's RTL configuration key**

Blowfish's exact key for right-to-left is a theme detail, so read it from the vendored source rather than guessing:

```bash
grep -rn 'rtl\|languageDirection\|dir=' _vendor/github.com/nunocoracao/blowfish/v2/layouts/_default/baseof.html
grep -rn 'rtl' _vendor/github.com/nunocoracao/blowfish/v2/config/_default/languages.en.toml
```

Whatever key the theme reads is the key to set in Step 4. The test in Step 1 is the arbiter: it asserts `dir="rtl"` reaches the Arabic HTML.

- [x] **Step 4: Write the language configuration**

Create `config/_default/languages.en.toml`:

```toml
languageCode = "en"
languageName = "English"
languageDirection = "ltr"
weight = 1
title = "Boundless Academic Services"

[params]
  displayName = "EN"
  isoCode = "en"
  rtl = false
  dateFormat = "2 January 2006"
  description = "Unleash Your True Academic Potential. Scholarship mentorship, scientific research training, and global curricula."

[params.author]
  name = "Boundless Academic Services"
```

Create `config/_default/languages.ar.toml`:

```toml
languageCode = "ar"
languageName = "العربية"
languageDirection = "rtl"
weight = 2
title = "باوندلس للخدمات الأكاديمية"

[params]
  displayName = "ع"
  isoCode = "ar"
  rtl = true
  dateFormat = "2 January 2006"
  description = "أطلق إمكاناتك الأكاديمية الحقيقية. الإرشاد إلى المنح الدراسية، والتدريب على البحث العلمي، والمناهج الدولية."

[params.author]
  name = "باوندلس للخدمات الأكاديمية"
```

If Step 3 showed the theme reads a different key, set that key too — keep both rather than removing one, since `languageDirection` is also what Hugo itself exposes.

- [x] **Step 5: Write the Arabic home page**

Create `content/_index.ar.md`:

```markdown
---
title: "باوندلس للخدمات الأكاديمية"
description: "أطلق إمكاناتك الأكاديمية الحقيقية."
translationKey: "home"
---

تعمل باوندلس للخدمات الأكاديمية مع الطلاب والباحثين في الإرشاد إلى المنح الدراسية،
والبحث العلمي، والمناهج الدولية.
```

- [x] **Step 6: Run the tests to verify they pass**

Run: `make test`
Expected: PASS. If `dir="rtl"` is missing, revisit Step 3 — do not weaken the assertion.

- [x] **Step 7: Commit**

```bash
git add config/_default/languages.en.toml config/_default/languages.ar.toml content/_index.ar.md tests/cases/20-i18n.sh
git commit -m "feat: configure English and Arabic locales with RTL support"
```

---

### Task 4: The translation gate

**Files:**
- Create: `layouts/partials/extend-head-uncached.html`
- Create: `layouts/partials/boundless/validate-translation.html`

> **Corrected during execution.** The plan originally specified `extend-head.html`. Reading the vendored theme showed Blowfish invokes that file as `partialCached "extend-head.html" .Site` (`layouts/partials/head.html:216`) — cached once per language, with `.Site` as context, so `.File`, `.Draft` and `.IsTranslated` are unavailable and per-page validation is impossible there. The theme also exposes `extend-head-uncached.html`, invoked as `partial "extend-head-uncached.html" .` with the Page context (`head.html:221`). That is the correct hook, and it is what was implemented. Tasks 4 and 6 both use it.
- Create: `tests/fixtures/orphan/_index.en.md`, `tests/fixtures/orphan/_index.ar.md`, `tests/fixtures/orphan/lonely.en.md`
- Create: `tests/fixtures/paired/_index.en.md`, `tests/fixtures/paired/_index.ar.md`, `tests/fixtures/paired/together.en.md`, `tests/fixtures/paired/together.ar.md`, `tests/fixtures/paired/wip.en.md`
- Test: `tests/cases/30-translation-gate.sh`

**Interfaces:**
- Consumes: the working bilingual build from Task 3.
- Produces: `layouts/partials/extend-head-uncached.html` — Blowfish's per-page extension point. Later tasks (font preloading, analytics) **append to this file**, they do not replace it.

- [x] **Step 1: Write the failing test**

Create `tests/cases/30-translation-gate.sh`:

```bash
#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

build_with_content() { # $1 = content dir, $2 = destination
  HUGO_CONTENTDIR="$1" hugo --quiet --destination "$2" >/dev/null 2>&1
}

rm -rf tests/.tmp/gate-orphan tests/.tmp/gate-paired

assert_exit_code "a page with no counterpart fails the build" 1 \
  build_with_content tests/fixtures/orphan tests/.tmp/gate-orphan

assert_exit_code "fully paired content builds cleanly" 0 \
  build_with_content tests/fixtures/paired tests/.tmp/gate-paired

# The error message must name the offending file, or it is useless to an author.
error_output="$(HUGO_CONTENTDIR=tests/fixtures/orphan hugo --destination tests/.tmp/gate-orphan 2>&1)"
case "$error_output" in
  *lonely*) assert_equals "the failure names the offending page" "yes" "yes" ;;
  *)        assert_equals "the failure names the offending page" "yes" "no" ;;
esac
case "$error_output" in
  *"TRANSLATION GATE"*) assert_equals "the failure is clearly labelled" "yes" "yes" ;;
  *)                    assert_equals "the failure is clearly labelled" "yes" "no" ;;
esac

# Drafts are exempt: tests/fixtures/paired contains wip.en.md with no Arabic pair.
assert_file_exists "paired build produced output" "tests/.tmp/gate-paired/index.html"

finish
```

- [x] **Step 2: Run it to make sure it fails**

Run: `bash tests/cases/30-translation-gate.sh`
Expected: FAIL — the orphan build currently exits 0, because no gate exists.

- [x] **Step 3: Write the fixtures**

`tests/fixtures/orphan/_index.en.md`:

```markdown
---
title: "Fixture Home"
translationKey: "home"
---
```

`tests/fixtures/orphan/_index.ar.md`:

```markdown
---
title: "صفحة اختبار"
translationKey: "home"
---
```

`tests/fixtures/orphan/lonely.en.md` — the page that must break the build:

```markdown
---
title: "Lonely Page"
translationKey: "lonely"
---

This page has no Arabic counterpart and must fail the build.
```

`tests/fixtures/paired/_index.en.md`:

```markdown
---
title: "Fixture Home"
translationKey: "home"
---
```

`tests/fixtures/paired/_index.ar.md`:

```markdown
---
title: "صفحة اختبار"
translationKey: "home"
---
```

`tests/fixtures/paired/together.en.md`:

```markdown
---
title: "Paired Page"
translationKey: "together"
---

This page has a counterpart.
```

`tests/fixtures/paired/together.ar.md`:

```markdown
---
title: "صفحة مقترنة"
translationKey: "together"
---

هذه الصفحة لها نظير.
```

`tests/fixtures/paired/wip.en.md` — proves drafts are exempt:

```markdown
---
title: "Work In Progress"
translationKey: "wip"
draft: true
---

Draft with no counterpart. Must NOT fail the build.
```

- [x] **Step 4: Write the validation partial**

Create `layouts/partials/boundless/validate-translation.html`:

```go-html-template
{{- /*
  Translation gate.

  Design decision D2: every non-draft page must exist in both English and Arabic.
  This partial enforces it at build time — errorf makes Hugo exit non-zero, so
  Cloudflare Pages refuses to deploy an incomplete pair.

  Scope:
    - Only pages backed by a source file. Taxonomy, term and generated pages
      have no author-written counterpart and are exempt.
    - Only kinds home, page and section.
    - Drafts are exempt, so work in progress never blocks anyone.

  To publish a page, add its counterpart. To stop the error while writing,
  set draft: true.
*/ -}}
{{- if and .File (not .Draft) (in (slice "home" "page" "section") .Kind) -}}
  {{- if not .IsTranslated -}}
    {{- $other := "ar" -}}
    {{- if eq .Lang "ar" -}}{{- $other = "en" -}}{{- end -}}
    {{- errorf "TRANSLATION GATE: %q [%s] has no %s counterpart. Create the %s translation, or set draft: true while it is unfinished. Source: %s" .Path .Lang $other $other .File.Path -}}
  {{- end -}}
{{- end -}}
```

- [x] **Step 5: Hook it into every page**

Create `layouts/partials/extend-head-uncached.html`:

```go-html-template
{{- /*
  Blowfish renders this partial inside <head> on every page, which makes it the
  cheapest hook that runs exactly once per rendered page.

  Later tasks APPEND to this file. Do not replace its contents.
*/ -}}
{{- partial "boundless/validate-translation.html" . -}}
```

- [x] **Step 6: Run the tests to verify they pass**

Run: `make test`
Expected: PASS — the orphan fixture exits 1 with a message naming `lonely`, and the paired fixture (draft included) exits 0.

- [x] **Step 7: Verify the gate against the real site**

Run: `make build`
Expected: exit 0. If it fails, a real page is missing its counterpart — add it rather than loosening the gate.

- [x] **Step 8: Commit**

```bash
git add layouts/ tests/fixtures/ tests/cases/30-translation-gate.sh
git commit -m "feat: fail the build when a page is missing its translation"
```

---

### Task 5: Design tokens and RTL stylesheet

**Files:**
- Create: `assets/css/tokens.css`
- Create: `assets/css/rtl.css`
- Create: `assets/css/custom.css`
- Create: `layouts/partials/boundless/styles.html`
- Modify: `layouts/partials/extend-head-uncached.html`
- Test: `tests/cases/40-styles.sh`

> **Corrected during execution.** The plan had `custom.css` pull in the other files with CSS `@import`. That silently does not work: Blowfish loads `custom.css` through `resources.Concat` (`head.html:123`), which joins files byte-for-byte without resolving imports, so the import survived into the bundle as a dead reference — landing mid-bundle, where `@import` is invalid regardless. Tokens never reached the page and no error was raised. Replaced with `layouts/partials/boundless/styles.html`, which concatenates `fonts.css` + `tokens.css` + `rtl.css` explicitly through Hugo and emits one fingerprinted `<link>`. `custom.css` remains the theme's extension point for component overrides. `40-styles.sh` now asserts no `@import` survives into any built stylesheet — a guard verified to fail against a deliberately injected import.

**Interfaces:**
- Consumes: the working build from Task 4.
- Produces: the token contract every later phase styles against —
  `--bl-color-primary`, `--bl-color-primary-dark`, `--bl-color-accent`,
  `--bl-color-ink`, `--bl-color-muted`, `--bl-color-surface`, `--bl-color-border`,
  `--bl-font-sans`, `--bl-font-arabic`,
  `--bl-space-1` … `--bl-space-6`, `--bl-radius`, `--bl-measure`.
  Applying the real visual identity later means editing **only** `tokens.css`.

- [x] **Step 1: Write the failing test**

Create `tests/cases/40-styles.sh`:

```bash
#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

OUT="tests/.tmp/styles"
rm -rf "$OUT"
hugo --quiet --destination "$OUT" >/dev/null 2>&1

assert_file_exists "custom stylesheet is authored" "assets/css/custom.css"
assert_file_exists "design tokens are a separate file" "assets/css/tokens.css"
assert_file_exists "RTL corrections are a separate file" "assets/css/rtl.css"

assert_file_contains "tokens declare the primary colour" \
  "assets/css/tokens.css" "--bl-color-primary"
assert_file_contains "tokens declare the Arabic font stack" \
  "assets/css/tokens.css" "--bl-font-arabic"

# Identity lives in tokens.css only.
assert_file_not_contains "rtl.css hard-codes no hex colours" "assets/css/rtl.css" "#"

# The theme must actually pick the custom CSS up.
css_found=0
for f in $(find "$OUT" -name '*.css' 2>/dev/null); do
  if grep -qF -- "--bl-color-primary" "$f"; then css_found=1; break; fi
done
assert_equals "tokens reach the built stylesheet" "1" "$css_found"

finish
```

- [x] **Step 2: Run it to make sure it fails**

Run: `bash tests/cases/40-styles.sh`
Expected: FAIL — none of the stylesheets exist.

- [x] **Step 3: Write the design tokens**

Create `assets/css/tokens.css`:

```css
/*
  Design tokens — the ONLY place colour, type and spacing are declared.

  The Boundless visual identity does not exist yet (spec §12). These values are a
  deliberately neutral academic placeholder. When the identity arrives, this file
  is the only file that changes.

  Do not hard-code a colour, font or spacing value anywhere else in the project.
*/
:root {
  /* Colour */
  --bl-color-primary: #1f4e5f;
  --bl-color-primary-dark: #143844;
  --bl-color-accent: #c9832b;
  --bl-color-ink: #1a1a1a;
  --bl-color-muted: #5a6672;
  --bl-color-surface: #ffffff;
  --bl-color-border: #e2e6ea;

  /* Type */
  --bl-font-sans: "IBM Plex Sans", ui-sans-serif, system-ui, sans-serif;
  --bl-font-arabic: "IBM Plex Sans Arabic", "Noto Kufi Arabic", sans-serif;

  /* Spacing */
  --bl-space-1: 0.25rem;
  --bl-space-2: 0.5rem;
  --bl-space-3: 1rem;
  --bl-space-4: 1.5rem;
  --bl-space-5: 2.5rem;
  --bl-space-6: 4rem;

  /* Shape and measure */
  --bl-radius: 0.375rem;
  --bl-measure: 68ch;
}

@media (prefers-color-scheme: dark) {
  :root {
    --bl-color-ink: #ececec;
    --bl-color-muted: #a3adb8;
    --bl-color-surface: #14181c;
    --bl-color-border: #2b3238;
  }
}
```

- [x] **Step 4: Write the RTL stylesheet**

Create `assets/css/rtl.css`:

```css
/*
  Right-to-left corrections.

  Rule: use CSS logical properties everywhere so a single declaration serves both
  directions. This file holds only the cases logical properties cannot express —
  mirrored glyphs and directional punctuation.
*/
[dir="rtl"] {
  font-family: var(--bl-font-arabic);
  letter-spacing: 0;
}

[dir="rtl"] .prose {
  text-align: start;
}

/* Arabic numerals in a bilingual context read better as Western digits. */
[dir="rtl"] time,
[dir="rtl"] .bl-number {
  font-feature-settings: "lnum" 1;
  direction: ltr;
  unicode-bidi: embed;
}

/* Glyphs whose meaning is directional must mirror. */
[dir="rtl"] .bl-icon-arrow {
  transform: scaleX(-1);
}

/* Code and identifiers stay LTR even inside Arabic prose. */
[dir="rtl"] code,
[dir="rtl"] pre,
[dir="rtl"] samp {
  direction: ltr;
  text-align: left;
  unicode-bidi: embed;
}
```

- [x] **Step 5: Write the entry stylesheet**

Create `assets/css/custom.css`:

```css
/*
  Blowfish loads assets/css/custom.css automatically, after its own styles.
  Keep this file as an index — real declarations belong in tokens.css, rtl.css,
  or a future component file.
*/
@import "tokens.css";
@import "rtl.css";

body {
  font-family: var(--bl-font-sans);
  color: var(--bl-color-ink);
}

.bl-measure {
  max-width: var(--bl-measure);
}
```

- [x] **Step 6: Run the tests to verify they pass**

Run: `make test`
Expected: PASS. If "tokens reach the built stylesheet" fails, Blowfish is not picking `custom.css` up — check the vendored theme for the expected filename with:
`grep -rn "custom.css" _vendor/github.com/nunocoracao/blowfish/v2/layouts/`

- [x] **Step 7: Commit**

```bash
git add assets/ tests/cases/40-styles.sh
git commit -m "feat: add design tokens and RTL stylesheet"
```

---

### Task 6: Self-hosted fonts

**Files:**
- Create: `static/fonts/ibm-plex-sans-arabic-arabic-400-normal.woff2`
- Create: `static/fonts/ibm-plex-sans-arabic-arabic-600-normal.woff2`
- Create: `static/fonts/ibm-plex-sans-arabic-latin-400-normal.woff2`
- Create: `static/fonts/ibm-plex-sans-arabic-latin-600-normal.woff2`
- Create: `assets/css/fonts.css`
- Modify: `assets/css/custom.css`
- Modify: `layouts/partials/extend-head-uncached.html`
- Test: `tests/cases/50-fonts.sh`

**Interfaces:**
- Consumes: `assets/css/custom.css` and `layouts/partials/extend-head-uncached.html` from Tasks 4 and 5.
- Produces: font families `IBM Plex Sans Arabic` and `IBM Plex Sans`, matching the `--bl-font-sans` / `--bl-font-arabic` tokens.

- [x] **Step 1: Write the failing test**

Create `tests/cases/50-fonts.sh`:

```bash
#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

OUT="tests/.tmp/fonts"
rm -rf "$OUT"
hugo --quiet --destination "$OUT" >/dev/null 2>&1

for f in arabic-400 arabic-600 latin-400 latin-600; do
  path="static/fonts/ibm-plex-sans-arabic-${f}-normal.woff2"
  assert_file_exists "font present: $f" "$path"
  size=$(wc -c < "$path" 2>/dev/null || echo 0)
  if [ "$size" -gt 10000 ]; then
    assert_equals "font is a real file: $f" "big" "big"
  else
    assert_equals "font is a real file: $f" "big" "only ${size} bytes"
  fi
done

assert_file_contains "font faces are declared" "assets/css/fonts.css" "@font-face"
assert_file_contains "fonts use font-display swap" "assets/css/fonts.css" "font-display: swap"

# Global constraint: absolutely no third-party runtime requests.
assert_file_not_contains "no Google Fonts in CSS" "assets/css/fonts.css" "fonts.googleapis.com"
assert_file_not_contains "no Google Fonts in head" "layouts/partials/extend-head-uncached.html" "fonts.googleapis.com"
assert_file_not_contains "no CDN reference in CSS" "assets/css/fonts.css" "jsdelivr"

assert_file_contains "Arabic font is preloaded" "layouts/partials/extend-head-uncached.html" "preload"
assert_file_contains "translation gate is still wired up" \
  "layouts/partials/extend-head-uncached.html" "validate-translation.html"

finish
```

- [x] **Step 2: Run it to make sure it fails**

Run: `bash tests/cases/50-fonts.sh`
Expected: FAIL — no fonts, no `fonts.css`.

- [x] **Step 3: Download the fonts**

These four URLs were verified to return HTTP 200 with real payloads:

```bash
mkdir -p static/fonts
base="https://cdn.jsdelivr.net/npm/@fontsource/ibm-plex-sans-arabic@5/files"
for f in arabic-400 arabic-600 latin-400 latin-600; do
  curl -fsSL "$base/ibm-plex-sans-arabic-${f}-normal.woff2" \
    -o "static/fonts/ibm-plex-sans-arabic-${f}-normal.woff2"
done
ls -l static/fonts/
```

Each file should be roughly 19–46 KB. The files are committed to the repository — the CDN is a one-time source, never a runtime dependency.

IBM Plex is licensed under the SIL Open Font License, which permits redistribution.

- [x] **Step 4: Write the font declarations**

Create `assets/css/fonts.css`:

```css
/*
  Self-hosted IBM Plex Sans Arabic (SIL Open Font License).

  Self-hosted deliberately: no third-party request means faster first paint and
  no font provider learning who reads this site. Global constraint — never
  replace these with a hosted font service.

  The latin subset is the Latin companion, so English and Arabic pages share one
  typographic voice.
*/
@font-face {
  font-family: "IBM Plex Sans Arabic";
  font-style: normal;
  font-weight: 400;
  font-display: swap;
  src: url("/fonts/ibm-plex-sans-arabic-arabic-400-normal.woff2") format("woff2");
  unicode-range: U+0600-06FF, U+0750-077F, U+08A0-08FF, U+FB50-FDFF, U+FE70-FEFF;
}

@font-face {
  font-family: "IBM Plex Sans Arabic";
  font-style: normal;
  font-weight: 600;
  font-display: swap;
  src: url("/fonts/ibm-plex-sans-arabic-arabic-600-normal.woff2") format("woff2");
  unicode-range: U+0600-06FF, U+0750-077F, U+08A0-08FF, U+FB50-FDFF, U+FE70-FEFF;
}

@font-face {
  font-family: "IBM Plex Sans";
  font-style: normal;
  font-weight: 400;
  font-display: swap;
  src: url("/fonts/ibm-plex-sans-arabic-latin-400-normal.woff2") format("woff2");
  unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+2000-206F, U+2122, U+2212;
}

@font-face {
  font-family: "IBM Plex Sans";
  font-style: normal;
  font-weight: 600;
  font-display: swap;
  src: url("/fonts/ibm-plex-sans-arabic-latin-600-normal.woff2") format("woff2");
  unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+2000-206F, U+2122, U+2212;
}
```

- [x] **Step 5: Import the fonts and preload the critical ones**

Edit `assets/css/custom.css` — add `@import "fonts.css";` as the **first** import, above `tokens.css`:

```css
@import "fonts.css";
@import "tokens.css";
@import "rtl.css";
```

Replace `layouts/partials/extend-head-uncached.html` with the following. It keeps the translation gate and adds language-aware preloading — each locale preloads only the subset it actually renders:

```go-html-template
{{- /*
  Runs inside <head> on every page.

  1. Translation gate (design decision D2).
  2. Font preloading — each language preloads only the subset it renders, so an
     English visitor never downloads the Arabic face and vice versa.

  Later tasks append below. Do not remove what is already here.
*/ -}}
{{- partial "boundless/validate-translation.html" . -}}

{{- if eq .Lang "ar" -}}
  <link rel="preload" href="/fonts/ibm-plex-sans-arabic-arabic-400-normal.woff2" as="font" type="font/woff2" crossorigin>
{{- else -}}
  <link rel="preload" href="/fonts/ibm-plex-sans-arabic-latin-400-normal.woff2" as="font" type="font/woff2" crossorigin>
{{- end -}}
```

- [x] **Step 6: Run the tests to verify they pass**

Run: `make test`
Expected: PASS — all five case files, 0 failures.

- [x] **Step 7: Commit**

```bash
git add static/fonts/ assets/css/fonts.css assets/css/custom.css layouts/partials/extend-head-uncached.html tests/cases/50-fonts.sh
git commit -m "feat: self-host IBM Plex Sans Arabic with per-language preloading"
```

---

### Task 7: Navigation, About page, and Cloudflare Pages readiness

**Files:**
- Create: `config/_default/menus.en.toml`
- Create: `config/_default/menus.ar.toml`
- Create: `i18n/en.toml`
- Create: `i18n/ar.toml`
- Create: `content/about.en.md`, `content/about.ar.md`
- Create: `docs/deployment/cloudflare-pages.md`
- Test: `tests/cases/60-navigation.sh`

**Interfaces:**
- Consumes: everything from Tasks 1–6.
- Produces: a navigable bilingual site and a deployment runbook. Phase 2 adds `programs`, `people` and `partners` sections to these menus.

- [x] **Step 1: Write the failing test**

Create `tests/cases/60-navigation.sh`:

```bash
#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
# shellcheck source=../lib/assert.sh
source tests/lib/assert.sh

OUT="tests/.tmp/nav"
rm -rf "$OUT"
assert_exit_code "full site builds" 0 hugo --quiet --destination "$OUT"

assert_file_exists "English about page" "$OUT/about/index.html"
assert_file_exists "Arabic about page" "$OUT/ar/about/index.html"

assert_file_contains "English nav shows About" "$OUT/index.html" "About"
assert_file_contains "Arabic nav shows the Arabic label" "$OUT/ar/index.html" "من نحن"

assert_file_contains "tagline appears in English" "$OUT/index.html" "Unleash Your True Academic Potential"

assert_file_exists "sitemap generated" "$OUT/sitemap.xml"
assert_file_exists "robots.txt generated" "$OUT/robots.txt"
assert_file_exists "English RSS generated" "$OUT/index.xml"

assert_file_exists "deployment runbook exists" "docs/deployment/cloudflare-pages.md"
assert_file_contains "runbook pins the Hugo version" \
  "docs/deployment/cloudflare-pages.md" "$(cat .hugoversion)"

finish
```

- [x] **Step 2: Run it to make sure it fails**

Run: `bash tests/cases/60-navigation.sh`
Expected: FAIL — no about pages, no menus, no runbook.

- [x] **Step 3: Write the menus**

Create `config/_default/menus.en.toml`:

```toml
[[main]]
  name = "About"
  pageRef = "/about"
  weight = 10

[[footer]]
  name = "About"
  pageRef = "/about"
  weight = 10
```

Create `config/_default/menus.ar.toml`:

```toml
[[main]]
  name = "من نحن"
  pageRef = "/about"
  weight = 10

[[footer]]
  name = "من نحن"
  pageRef = "/about"
  weight = 10
```

- [x] **Step 4: Write the UI string tables**

Create `i18n/en.toml`:

```toml
[tagline]
other = "Unleash Your True Academic Potential"

[org_name]
other = "Boundless Academic Services"

[credits_heading]
other = "Credits"

[role_writer]
other = "Writer"

[role_reviewer]
other = "Reviewer"

[role_editor]
other = "Editor"

[role_translator]
other = "Translator"
```

Create `i18n/ar.toml`:

```toml
[tagline]
other = "أطلق إمكاناتك الأكاديمية الحقيقية"

[org_name]
other = "باوندلس للخدمات الأكاديمية"

[credits_heading]
other = "فريق العمل"

[role_writer]
other = "كاتب"

[role_reviewer]
other = "مُراجِع"

[role_editor]
other = "محرّر"

[role_translator]
other = "مترجم"
```

The role strings are seeded here because Phase 3 renders credits from them; adding them now keeps the two locale files symmetrical from the start.

- [x] **Step 5: Write the About page in both languages**

Create `content/about.en.md`:

```markdown
---
title: "About Boundless"
description: "Who we are and how we work."
translationKey: "about"
---

**Boundless Academic Services** helps students and researchers unleash their true
academic potential.

We work across three areas:

- **Scholarship Mentorship** — for high-school students, undergraduates, students
  already in university, and graduates.
- **Scientific Research** — a full training curriculum delivered by our own trainer
  team, alongside research fellowship programmes across applied, medical,
  humanities, and data fields.
- **Academic & Global Curricula** — SAT and other international curricula and exam
  preparation.

Our programmes run from one-to-one mentorship through group mentorship, general
sessions, and workshops. Some are paid; others are delivered entirely by volunteers,
free of charge.

We operate project by project, in partnership with governmental, non-governmental,
non-profit, and private-sector bodies.
```

Create `content/about.ar.md`:

```markdown
---
title: "من نحن"
description: "من نحن وكيف نعمل."
translationKey: "about"
---

تساعد **باوندلس للخدمات الأكاديمية** الطلاب والباحثين على إطلاق إمكاناتهم الأكاديمية
الحقيقية.

نعمل في ثلاثة مجالات:

- **الإرشاد إلى المنح الدراسية** — لطلاب المرحلة الثانوية، وطلاب البكالوريوس،
  والطلاب المسجّلين في الجامعة، وطلاب الدراسات العليا.
- **البحث العلمي** — منهج تدريبي متكامل يقدّمه فريق المدربين لدينا، إلى جانب برامج
  زمالة بحثية في المجالات التطبيقية والطبية والإنسانية والبيانات.
- **المناهج الأكاديمية والدولية** — اختبار SAT وغيره من المناهج الدولية والتحضير
  للاختبارات.

تمتد برامجنا من الإرشاد الفردي إلى الإرشاد الجماعي والجلسات العامة وورش العمل.
بعضها مدفوع، وبعضها الآخر يقدّمه متطوعون بالكامل ومجاناً.

نعمل وفق نموذج قائم على المشاريع، بالشراكة مع جهات حكومية وغير حكومية ومنظمات غير
ربحية والقطاع الخاص.
```

- [x] **Step 6: Write the deployment runbook**

Create `docs/deployment/cloudflare-pages.md`:

```markdown
# Deploying to Cloudflare Pages

The theme is vendored in `_vendor/`, so the build needs **neither Go nor network
access**. Only Hugo is required.

## Cloudflare Pages project settings

| Setting | Value |
|---|---|
| Framework preset | None |
| Build command | `hugo --gc --minify` |
| Build output directory | `public` |
| Root directory | *(repository root)* |

## Environment variables

Set in **Settings → Environment variables**, for both Production and Preview:

| Variable | Value |
|---|---|
| `HUGO_VERSION` | `0.154.5` |
| `HUGO_ENV` | `production` |

`HUGO_VERSION` must match `.hugoversion`. When you bump one, bump the other — the
test suite asserts the runbook and the pin agree.

## Before the first deploy

1. Set the real domain in `config/_default/hugo.toml` → `baseURL`, including the
   trailing slash. The placeholder `https://boundless.example/` produces broken
   canonical URLs and `hreflang` tags in production.
2. Run `make build` locally and confirm exit code 0.
3. Push to `main`.

## Branch previews

Cloudflare builds every branch to its own preview URL. Because the translation gate
fails the build, a branch missing a translation never produces a preview — that is
intended behaviour, not a broken pipeline.

## After the first deploy

- Verify the custom domain and that HTTPS is active.
- Verify `https://<domain>/` serves English and `https://<domain>/ar/` serves Arabic
  with RTL layout.
- Add the site to Google Search Console and submit `sitemap.xml`.

## What this runbook does NOT cover

Connecting the git remote, creating the Cloudflare Pages project, and pointing the
purchased domain at it are account-level actions performed by Mulham Fetna. Analytics
(GA4) and the consent banner land in Phase 4.
```

- [x] **Step 7: Extend the gate fixtures so the new menu references resolve**

The menus added in Step 3 use `pageRef = "/about"`. The Task 4 gate tests build against
fixture content directories, where no `about` page exists, so the reference would
dangle. Add the page to both fixtures.

Create `tests/fixtures/paired/about.en.md`:

```markdown
---
title: "About"
translationKey: "about"
---

Fixture about page.
```

Create `tests/fixtures/paired/about.ar.md`:

```markdown
---
title: "من نحن"
translationKey: "about"
---

صفحة اختبار.
```

Create `tests/fixtures/orphan/about.en.md`:

```markdown
---
title: "About"
translationKey: "about"
---

Fixture about page.
```

Create `tests/fixtures/orphan/about.ar.md`:

```markdown
---
title: "من نحن"
translationKey: "about"
---

صفحة اختبار.
```

The orphan fixture still fails the build, because `lonely.en.md` remains unpaired —
which is the whole point of that fixture.

- [x] **Step 8: Run the tests to verify they pass**

Run: `make test`
Expected: PASS — six case files, 0 failures. Pay particular attention to
`30-translation-gate.sh`: if the paired fixture now fails, the menu reference is still
dangling and needs the fixture page it points at.

- [x] **Step 9: Review the site by eye, in both directions**

Run: `make dev`
Open `http://localhost:1313/` and `http://localhost:1313/ar/`.

Confirm: Arabic text flows right-to-left, navigation mirrors, the language switcher moves between the pair, and no network request goes to a third-party domain (check the browser's network tab — every request should be same-origin).

- [x] **Step 10: Commit**

```bash
git add config/_default/menus.en.toml config/_default/menus.ar.toml i18n/ content/about.en.md content/about.ar.md docs/deployment/ tests/fixtures/ tests/cases/60-navigation.sh
git commit -m "feat: add bilingual navigation, About page and Cloudflare runbook"
```

---

## Phase 1 Definition of Done

- [x] `make test` passes — six case files, zero failures
- [x] `make build` exits 0 and produces `public/`
- [x] English at `/`, Arabic at `/ar/` with `dir="rtl"` and reciprocal `hreflang`
- [x] A page missing its counterpart fails the build with a message naming the file
- [x] Drafts are exempt from the gate
- [x] Zero third-party runtime requests
- [x] Colour, type and spacing live only in `assets/css/tokens.css`
- [x] Blowfish pinned and vendored; builds need neither Go nor network
- [x] Deployment runbook written and version-consistent with `.hugoversion`

## Explicitly deferred to later phases

Programs, editions, people, partners, articles, topic hubs (Phase 2–3) · the credit
system and citation blocks (Phase 3) · schema validation beyond the translation gate
(Phase 2) · JSON-LD, `llms.txt`, answer-first rendering (Phase 3) · achievements and
archive generation, Google Form embeds, GA4 and the consent banner, SRC2 content
migration, the real visual identity, domain cutover (Phase 4).
