# Boundless Academic Services — Website

Bilingual (English / Arabic) static site built with Hugo and the Blowfish theme.

- **Design spec:** `docs/superpowers/specs/2026-07-28-boundless-website-design.md`
- **English** is served at `/`, **Arabic** at `/ar/` with RTL layout.

## Requirements

- GNU Make, `curl`, `tar`

Hugo is **not** taken from your PATH. `make setup` downloads the exact version named
in `.hugoversion` into `.tools/` (gitignored), and every other target uses it. This is
deliberate: Blowfish declares a supported Hugo range, and a distribution package drifts
independently of this repository. Pinning the binary means you, a future volunteer, and
Cloudflare all build with the identical version.

The theme is vendored in `_vendor/`, so Go and network access are not needed to build.

## Commands

| Command | What it does |
|---|---|
| `make setup` | Download the pinned Hugo binary (run once; other targets do it for you) |
| `make dev` | Local dev server, drafts visible |
| `make build` | Production build into `public/` |
| `make test` | Full test suite |
| `make clean` | Remove build artefacts |
| `make theme-update` | Deliberately update the pinned theme |

## The translation rule

Every non-draft page must exist in **both** English and Arabic. A page without its
counterpart fails the build. Work in progress belongs in `draft: true`, which is exempt.
