# Deploying to Cloudflare Pages

The Boundless theme lives in `themes/boundless/`, so the build needs **neither Go nor
network access**. Only Hugo is required.

## Cloudflare Pages project settings

| Setting | Value |
|---|---|
| Framework preset | None |
| Build command | `hugo --gc --minify` |
| Build output directory | `public` |
| Root directory | *(repository root)* |

Note the build command calls `hugo` directly, not `make build`. Cloudflare installs
Hugo itself from `HUGO_VERSION` below, so the project-local binary in `.tools/` — which
is gitignored and exists only on your machine — is neither present nor needed there.

## Environment variables

Set in **Settings → Environment variables**, for both Production and Preview:

| Variable | Value |
|---|---|
| `HUGO_VERSION` | `0.164.0` |
| `HUGO_ENV` | `production` |

`HUGO_VERSION` must match `.hugoversion`. When you bump one, bump the other — the
test suite asserts the runbook and the pin agree.

The theme uses the `locale` / `label` / `direction` language fields introduced in
Hugo 0.158.0, so do not set a version below that.

## Before the first deploy

1. `config/_default/hugo.toml` → `baseURL` is set to `https://boundlessacademic.com/`.
   If the domain changes, update it, including the trailing slash, or canonical URLs
   and `hreflang` tags break.
2. Run `make build` locally and confirm exit code 0.
3. Push to `main`.

## Branch previews

Cloudflare builds every branch to its own preview URL. Because the translation gate
fails the build, a branch missing a translation never produces a preview — that is
intended behaviour, not a broken pipeline.

## After the first deploy

- Verify the custom domain and that HTTPS is active.
- Verify `https://<domain>/` serves Arabic with RTL layout and `https://<domain>/en/`
  serves English. The old `/ar/` address redirects to `/`.
- Add the site to Google Search Console and submit `sitemap.xml`.

## What this runbook does NOT cover

Connecting the git remote, creating the Cloudflare Pages project, and pointing the
purchased domain at it are account-level actions performed by Mulham Fetna. Analytics
(GA4) and the consent banner land in Phase 4.
