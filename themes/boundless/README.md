# Boundless theme

Arabic-first Hugo theme for boundlessacademic.com, built on the Boundless visual identity v1.0: three grounds (Paper, Ink, Teal), Thmanyah Serif Display and Thmanyah Sans, the Sky photo-frame device, and Sun used once per page.

Requires Hugo 0.158.0 or newer (uses the `locale`, `label` and `direction` language fields). No modules, no JavaScript framework, no external requests.

## Files

| Path | What it holds |
|---|---|
| `assets/css/tokens.css` | Every colour, font, space and radius. The only place identity values live |
| `assets/css/fonts.css` | Self-hosted Thmanyah font faces |
| `assets/css/boundless.css` | Components and layout; uses tokens only |
| `layouts/partials/styles.html` | Bundles the three sheets into one fingerprinted file |
| `layouts/partials/hooks/head-start.html` | Empty hook the site overrides for per-page checks |
| `layouts/index.html` | Home page built from front-matter blocks |
| `layouts/projects/single.html` | Project page |
| `static/brand/` | Logo SVGs |
| `static/fonts/` | Thmanyah WOFF2 files and licence |

A site overrides any of these by placing a file at the same path in its own folder.

## Home page front matter

`hero` (tag, title, mark, lead, buttons, image, imageAlt, corner) · `stats.items` (value, label) · `projects` (title, lead) · `band` (label, title, bullets, button, image) · `partners` (title, items: name, role). Each block shows only if present.

## Project page front matter

| Key | Effect |
|---|---|
| `title`, `code`, `weight` | Page title, short code tag (SRC3), order in lists |
| `status` | `completed`, `running`, `open` or `upcoming` |
| `mark` | The phrase in the title that gets the Sun hand underline. Leave it out when the page has `register` (Sun once per page) |
| `summary`, `lead` | Card text and the intro under the title |
| `image`, `imageAlt`, `corner`, `imagePos`, `imageRatio` | Main photo, the corner the Sky frame crosses (`bl`, `br`, `tl`, `tr`, away from faces), CSS object-position and aspect ratio |
| `fill` | With no photo, a solid `sky` or `teal` square shows the project code |
| `facts` | Label and value rows under the title |
| `stats` | Big numbers on the Ink band |
| `steps`, `stepsTitle` | Numbered stage cards |
| `gallery` | Photos with alt text and captions |
| `partners` | Names and roles on the Teal band |
| `register` | `{ url, label }`: the Sun registration button |

## Brand rules the theme enforces by design

- One ground per section; Ink for numbers, Teal for partners and the camp band.
- Sun once per page: the hand underline or the registration button.
- The Sky frame crosses one corner of each main photo and turns ink inside it.
- Real photos only. Replace social-media captures with camera originals under the same file names.
