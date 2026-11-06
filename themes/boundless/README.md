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
| `image`, `imageAlt`, `corner`, `imagePos`, `imageRatio` | Main photo, the corner the Sky frame extends past, behind the photo (`bl`, `br`, `tl`, `tr`), CSS object-position and aspect ratio |
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
- The Sky frame sits behind each main photo and shows only where it extends past one corner. It never covers the picture.
- Real photos only. Replace social-media captures with camera originals under the same file names.

## Blog posts

Posts live in `content/blog/<slug>/index.{ar,en}.md` (page bundles, paired by `translationKey`).

| Key | Effect |
|---|---|
| `title`, `lead`, `description` | Headline, intro under it, meta description and card text |
| `seoTitle` | Shorter `<title>` for search results; the headline stays on the page |
| `date`, `tags` | Publication date (Levantine month names in Arabic) and tag pills |
| `stats` | Big numbers on the Ink band |
| `paper` | Name of a record in `data/papers/`: adds the published-paper block (DOI, licence, abstract, keywords, authors with departments, how to cite) and ScholarlyArticle structured data |
| `faq` | `q`/`a` pairs shown on the page and emitted as FAQPage structured data. Answers may use `<bdi>` around English inside Arabic |
| `project` | A project slug (`src1`): adds a related-project card |
| `corner`, `imageRatio`, `imagePos` | Corner the frame extends past, behind the photo (default `bl`), cover aspect ratio (default `3/4`) and CSS object-position (default `top`) |
| `imageAlt` | Alt text for `cover.jpg` (or .png/.webp) placed in the post folder. With a cover, the hero shows it in the Sky frame and it becomes the sharing image |

Every post page also emits BlogPosting structured data and `article:*` meta tags (`partials/schema-post.html`).
