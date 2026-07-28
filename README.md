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
