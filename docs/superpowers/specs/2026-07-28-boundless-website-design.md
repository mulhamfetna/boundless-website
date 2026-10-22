# Boundless Academic Services — Website Design

**Date:** 2026-07-28
**Status:** Approved design, pending implementation planning
**Owner:** Mulham Fetna (sole representative of the association)

---

## 1. Purpose

Build the public website for **Boundless Academic Services** — tagline *Unleash Your True Academic Potential*.

The site has two jobs, in priority order:

1. **Credibility through a documented achievements record.** Every program Boundless has run becomes a dated, evidenced page. Aggregate impact numbers are derived from those pages, not typed into a marketing slide.
2. **Reach through educational content.** Free articles across all fields Boundless works in, written to be found via search engines and quoted by generative-AI answer systems, with every contributor credited by name and role.

The crediting system is not a nicety. Boundless runs both paid and fully voluntary programs; verifiable public attribution is what protects contributors' rights and what makes volunteering worth someone's time.

## 2. Context

Boundless is an Aleppo-based association operating **project-by-project**. It accepts partnership, sponsorship and support from governmental, non-governmental, non-profit and private-sector bodies — but signs agreements **only for a specific program or set of programs**, never as an entity, and accepts no external control over the association. Projects run 3–12 months depending on program size.

Service portfolio:

- **Scholarship Mentorship** — undergraduate, high-school, in-college and graduate tracks; international olympiads; UWC; Chevening/DAAD/Erasmus/GKS and similar
- **Scientific Research** — full training curriculum with an in-house trainer team, plus research fellowship programs across applied/engineering, medical, humanities and data fields
- **Academic & Global Curricula** — SAT and other international curricula and exam preparation

Delivery formats span one-to-one mentorship, group mentorship, general sessions and workshops.

The flagship delivered program is **Scientific Research Camp II (SRC2)** — Aleppo, Apr–Jul 2026, 50 youth researchers, strategic partner SANAD, donor UNFPA Syria — with post-camp fellowship tracks in publishing support, institutional research integration, and research incubation.

Arabic is the association's primary working language.

## 3. Decisions

Recorded here so implementation never re-litigates them.

| # | Decision | Choice |
|---|---|---|
| D1 | Languages | Bilingual. **English primary at `/`**, Arabic at `/ar/` |
| D2 | Translation policy | **Everything translated, no exceptions** — enforced at build time |
| D3 | Program modelling | **Program (evergreen) + Edition (each run)**, editions nested under program |
| D4 | Unpublished programs | **Completely hidden** — not in the published output |
| D5 | Person pages | **Core team gets pages; one-off contributors credited by name**, with automatic promotion at a threshold |
| D6 | Naming consent | **Opt-out — named by default**, with a display-form escape hatch |
| D7 | Content licence | **CC BY-NC-ND 4.0 default**, per-item override field |
| D8 | Content unit | **Standalone SEO/GEO article**, not course/module/lesson |
| D9 | Clustering | **Topic hub (pillar) + cluster articles** |
| D10 | Article template | **Enforced in front matter** — build fails on omission |
| D11 | Partnership model | Published as **principles**, not as a list of refusals |
| D12 | Conversions | Partner/sponsor · Volunteer/contribute · Subscribe. **No participant applications on-site** |
| D13 | Forms | **Embedded Google Forms + mailto links** |
| D14 | Newsletter | **Collect now via Google Form**, sending tool chosen later |
| D15 | Evidence published | Hard numbers · named partners & logos · photos/media · reports, testimonials, outcomes |
| D16 | Analytics | **GA4** (consent-gated, deferred) **+ Google Search Console** |
| D17 | Build strategy | **Mature theme extended with overrides** |
| D18 | Theme | **Blowfish**, pinned as a Hugo Module |
| D19 | Authoring | **Git + markdown for now**, structured to accept a CMS later |
| D20 | Hosting | **Cloudflare Pages**, Cloudflare domain already purchased |

### Concerns raised and overridden

Recorded honestly, because they may need revisiting rather than rediscovering.

- **D2 (translate everything)** is a publishing bottleneck. Mitigated by making the gate mechanical: work in progress stays `draft: true` and is exempt, so the rule blocks publishing but never writing.
- **D7 (CC BY-NC-ND)** is the most restrictive Creative Commons licence. It forbids translation, adaptation, and use inside any paid course — including by a non-profit university — which sits in tension with "spread via free content". It does prevent commercial repackaging of the curricula. Mitigated by a per-item `license` field, so a flagship curriculum can be relicensed without a rebuild.
- **D5 (two-tier credits)** risks creating a permanent second class among volunteers. Mitigated by making the tier a **threshold, not a category** (§6.3).
- **D13 (Google Form embeds)** do not inherit the visual identity, behave poorly on mobile RTL, and set Google cookies. Mitigated by a styled container with an "open in a new tab" fallback.
- **D16 (GA4)** requires a cookie-consent banner, adds page weight, and sends visitor data to Google — relevant given part of the audience is in a sensitive context. Mitigated by consent-gating and deferred loading.

## 4. Theme selection

**Blowfish**, verified 2026-07-28:

- Explicit RTL support, documented in the README as a first-class feature
- Multilingual by design; theme UI shipped in 32 languages
- Tailwind CSS 3 — the visual identity plugs in through design tokens
- Built-in Fuse.js site search
- ~11 open issues against 2.9k stars; latest release **v2.105.0 on 2026-07-26**

Rejected: **Hextra** (no documented RTL, 85 open issues, documentation-shaped navigation), **Congo** (superseded by Blowfish, which forks it), **Hugo Blox** (heavy, historic maintenance turbulence).

Blowfish is pinned to an exact module version. Upstream releases are adopted deliberately, never automatically.

## 5. Information architecture

### 5.1 Content types

| Type | Path | Purpose |
|---|---|---|
| Service | `/services/<slug>/` | The three pillars. Top-level navigation, donor-facing overview |
| Program | `/programs/<slug>/` | Evergreen: what it is, who it serves, format, fields. Belongs to one service |
| Edition | `/programs/<slug>/<year>-<place>/` | One actual run: dates, location, partners, donor, cohort size, team, outcomes, evidence |
| Topic hub | `/topics/<slug>/` | Pillar page defining a subject and linking its whole article cluster |
| Article | `/articles/<slug>/` | The SEO/GEO atom — one topic per article |
| Person | `/people/<slug>/` | Contributor profile with auto-generated portfolio |
| Partner | `/partners/<slug>/` | Partner/donor entity, logo, editions backed |

**Article URLs are flat by design.** Clustering signal comes from internal linking and taxonomy, not URL nesting, so an article can be re-clustered later without redirects.

**Edition URLs are nested by design.** The hierarchy is stable and the URL should carry it.

### 5.2 Generated pages

Never hand-authored:

- `/achievements/` — site-wide impact totals summed from every edition
- `/archive/` — chronological record of all editions, filterable by service, field, year, partner

Documenting an edition is the only action required; the credibility surface updates itself.

### 5.3 Static pages

About · Our Partnership Principles · Join Us · Contact · Subscribe · Content & Credit Policy · Privacy

### 5.4 Taxonomies

`service` · `field` (applied-engineering, medical, humanities, data, emerging) · `audience` (high-school, undergraduate, current-student, graduate) · `format` (one-to-one, group, workshop, session) · `topic` · `contributor` · `partner`

Facet listings ("medical-field programs for graduates") are generated from these.

### 5.5 Explicitly out of scope

Participant application flows · course/module/lesson hierarchy · in-development program pages in any form · prescribed article reading order · a self-hosted CMS at launch.

## 6. Crediting system

### 6.1 Storage

Two fields kept in sync, because Hugo taxonomies cannot hold role pairs:

```yaml
credits:
  - person: mulham-fetna
    role: writer
  - person: abdul-razzaq-hammal
    role: reviewer
  - person: nadra-rabie
    role: editor
    note: "Arabic edition"
contributors: [mulham-fetna, abdul-razzaq-hammal, nadra-rabie]
```

`credits` renders the visible byline. `contributors` is the taxonomy powering portfolios. A build-time check fails if the two disagree, so they cannot drift.

### 6.2 Role vocabulary

Closed list. An unrecognised role fails the build, preventing `Reviewer` / `reviewer` / `Peer reviewer` fragmenting into three distinct roles:

`writer` · `co-writer` · `reviewer` · `scientific-reviewer` · `editor` · `translator` · `illustrator` · `data-analyst` · `researcher` · `trainer` · `program-lead` · `coordinator` · `media` · `supervisor`

Editions use the same vocabulary, so a contributor who coordinated an edition and reviewed three articles has one unified portfolio.

### 6.3 Person pages and the threshold

Core team members get a page on creation. Every other contributor is credited by name and **automatically qualifies for a page at 3 credited contributions** — a configurable value. A contribution is any credit on any content type; three article reviews, or one article plus two editions, both qualify. Below the threshold the name renders as plain text; at or above it, the same name renders as a link. No manual promotion, no permanent second tier.

A person page carries photo, role at Boundless, bio, affiliation, external links (ORCID, LinkedIn, Google Scholar), and three generated sections — **Articles**, **Programs & editions**, **Curricula contributed to** — each showing the role held.

### 6.4 Consent

Names are published by default (D6). The person record carries `display: full | initials | pseudonym | withheld`. Nobody is required to use it, but a contributor with a safety reason not to be publicly named can be honoured immediately rather than forcing an emergency change to the credit system.

### 6.5 Licensing and citation

`license: cc-by-nc-nd-4.0` is the default on every article, overridable per item. Each article renders a copy-pasteable citation block — contributors with roles, title, *Boundless Academic Services*, year, canonical URL, licence — and emits the same information as structured data, so citation managers and AI systems read the attribution too.

The crediting system and the structured-data system are the same system. Attribution is machine-verifiable, not decorative.

## 7. Build-time contract

Hugo's `errorf` fails the build; Cloudflare Pages will not deploy a failed build. The publishing standard is therefore enforced by the pipeline, not by memory.

**Every article requires:** `title`, `summary`, `answer` (one paragraph, direct), `takeaways` (3–5), `faq` (≥1 Q/A pair), `credits` (≥1 entry with role `writer`), `topic`, `license`, and a live translation in the other language.

**Every edition requires:** `service`, `program`, start and end dates, `applications: open | closed | upcoming`, and ≥1 impact number. When `open`, the edition links out to the Google Form for that cohort — the only place participant intake appears on the site.

**Every program requires:** `service`, `audience`, `format`, `status`.

**Every person requires:** `name`, `role`, `display`.

**Every non-draft page requires** its counterpart in the other language.

Failures name the file path and the missing field.

## 8. Bilingual and RTL

English at `/`, Arabic at `/ar/`. Pages pair via a shared `translationKey`, not a filename — each language gets a natural slug while Hugo still recognises them as one page.

The translation gate applies to non-draft pages only. Work in progress sits as `draft: true` and is exempt.

RTL is treated as a layout concern, not an attribute:

- Logical CSS properties throughout (`ms-`/`me-`, not `ml-`/`mr-`)
- Self-hosted **IBM Plex Sans Arabic** (SIL Open Font Licence), chosen because its Latin companion pairs cleanly for a bilingual site — no third-party font request, which is both a speed and a privacy improvement
- Locale-correct dates and numerals
- Mirrored navigation and iconography
- Every layout override verified in both directions

`hreflang` tags link each pair plus `x-default`, so search engines serve Arabic speakers the Arabic URL rather than treating the pair as duplicate content.

## 9. SEO and generative-engine optimisation

- **Answer-first rendering.** The `answer` paragraph renders in a distinct block immediately under the H1. Generative engines extract the first substantive passage that directly answers a query.
- **JSON-LD structured data.** `Organization` site-wide; `ScholarlyArticle` with real `Person` authors carrying `sameAs` ORCID links; `FAQPage` from the `faq` field; `BreadcrumbList`; `Event` for editions.
- **`llms.txt`** generated at the root — a plain-language index of what Boundless is, what the curricula cover, and how to cite the material.
- **Automatic hub↔article linking.** Hubs list their cluster; articles show their hub and siblings. Authors never have to remember to link.
- **Per-language and per-topic RSS**, sitemap with `hreflang`, canonical URLs, OpenGraph cards.
- Site search via Blowfish's Fuse.js, indexed per language.

## 10. Delivery

Git repository (initialised 2026-07-28). Hugo pinned to an exact version; Blowfish pinned as a Hugo Module at `v2.105.x`. Cloudflare Pages builds from `main` with branch previews for review before publish.

The visual identity does not exist yet. All colour, type and spacing live in a single design-tokens file with a neutral academic placeholder palette; adopting the identity is one file, not a redesign.

GA4 loads deferred and only after consent, paired with a consent banner and a privacy page. Search Console is verified at launch — without it there is no way to tell whether the content strategy is working. Google Form embeds sit in styled containers with an "open in a new tab" fallback so a blocked iframe never dead-ends a visitor.

Archetypes and schemas are written CMS-shaped, so adding Sveltia at `/admin` later is configuration rather than restructuring.

## 11. Phasing

Each phase gets its own implementation plan and produces reviewable output.

1. **Foundation** — repo, Hugo + Blowfish, i18n skeleton, design tokens, Cloudflare pipeline live on a staging URL
2. **Content model** — archetypes, schema validation, taxonomies, layouts for program, edition, person, partner
3. **Content engine** — articles, topic hubs, credits rendering, citation blocks, full SEO/GEO stack
4. **Aggregation and launch** — achievements and archive generation, static pages, forms, analytics, SRC2 migrated as the first documented edition, identity applied, domain cut over

## 12. Open items

Not blocking, but needed before the phase they belong to:

- Visual identity (colours, typography, logo files) — needed by Phase 4, placeholder until then
- Domain name to configure in Cloudflare — needed by Phase 4
- Confirmed SRC2 impact numbers and donor approval to display UNFPA/SANAD names and marks — needed by Phase 4
- Participant photo consent status for media published from the SRC2 archive — needed by Phase 4
- Core team roster and who counts as core for person pages — needed by Phase 2
- Newsletter sending tool — needed before the first send, not before launch

## 13. Decision log

Changes to the decisions in §3, newest first. The original rows stay above as the record of what was decided at the time.

### 2026-10-23 — Visual identity applied, custom theme, Arabic primary

Decided by Mulham Fetna.

| # | Was | Now |
|---|---|---|
| D1 | English primary at `/`, Arabic at `/ar/` | **Arabic primary at `/`, English at `/en/`.** `/ar/` redirects to `/`. `x-default` points to the Arabic page. |
| D17 | Mature theme extended with overrides | **Custom theme in the repository** (`themes/boundless/`), built on the Boundless visual identity v1.0. |
| D18 | Blowfish, pinned as a Hugo Module | **Blowfish removed** with `go.mod`, `_vendor/` and the module import. Build needs no network. |
| §8 font | IBM Plex Sans Arabic | **Thmanyah Sans and Thmanyah Serif Display**, self-hosted, per the identity. |
| §12 | Visual identity open (G9) | **Closed.** Identity v1.0 approved October 2026; tokens in `themes/boundless/assets/css/tokens.css`. |

Kept unchanged: D2 translation gate (now wired through `layouts/partials/hooks/head-start.html`), the pinned Hugo binary, the test suite (updated to the new paths and language roots), Cloudflare Pages hosting.

**Content published ahead of the gates in the knowledge-base analysis.** The first three project pages (SRC1, SRC2, GEW) go live with trainer names, session photos and partner names, treating Boundless's own public Instagram and Facebook posts of the same material as the basis for publication. This is the owner's decision and runs ahead of gaps G1 (attribution clause), G4 (donor approval of names and marks), G5 (participant image consent) and G3 (SRC1 record). Those gaps remain open and should still be closed; if any contributor, participant or partner objects, the page is edited or set to `draft: true`.

**Not yet built from §5:** the program/edition content model, people, partners, articles, achievements and archive. The three project pages use a simpler `projects` section and move into the full model in Phase 2.
