# Boundless Academic Services — Website

Bilingual (Arabic / English) static site for boundlessacademic.com, built with Hugo and
the in-repository **Boundless theme** (`themes/boundless/`), which implements the Boundless
visual identity v1.0.

- **Arabic** is served at `/` (right-to-left), **English** at `/en/`.
- **Design spec:** `docs/superpowers/specs/2026-07-28-boundless-website-design.md` (see its decision log)
- **Theme guide:** `themes/boundless/README.md`

## Requirements

- GNU Make, `curl`, `tar`

Hugo is **not** taken from your PATH. `make setup` downloads the exact version named
in `.hugoversion` into `.tools/` (gitignored), and every other target uses it. Pinning
the binary means you, a future volunteer, and Cloudflare all build with the identical
version.

The theme lives in this repository, so Go and network access are not needed to build.

## Commands

| Command | What it does |
|---|---|
| `make setup` | Download the pinned Hugo binary (run once; other targets do it for you) |
| `make dev` | Local dev server, drafts visible |
| `make build` | Production build into `public/` |
| `make test` | Full test suite |
| `make clean` | Remove build artefacts |

## The translation rule

Every non-draft page must exist in **both** Arabic and English. A page without its
counterpart fails the build. Work in progress belongs in `draft: true`, which is exempt.
Pages pair by file name (`src2.ar.md` / `src2.en.md`) plus a shared `translationKey`.

## Content

| Path | What it holds |
|---|---|
| `content/_index.{ar,en}.md` | Home page blocks: hero, stats, projects, band, partners |
| `content/projects/*.{ar,en}.md` | One pair per project: SRC1, SRC2, GEW |
| `content/about.{ar,en}.md` | About page |
| `config/_default/` | Site, language, menu and contact settings |
| `static/images/` | Photos and the social sharing image |

The front-matter keys for project pages are listed in `themes/boundless/README.md`.
