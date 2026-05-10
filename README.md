# typst2web

Static site that renders a [Typst](https://typst.app/) document as SVG and/or HTML and displays it in a web page. Deployable as-is on **Vercel** or **Cloudflare Pages**.

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/guillaumejay/typst2web) [![Deploy to Cloudflare](https://deploy.workers.cloudflare.com/button)](https://deploy.workers.cloudflare.com/?url=https://github.com/guillaumejay/typst2web)

One click to clone + deploy on either platform. Note: both buttons create an **independent copy** of this repo in your GitHub account — not a GitHub fork, so there's no upstream link or "Sync fork" relationship.

## How it works

1. On every `git push`, the platform (Vercel or Cloudflare) spins up a Linux container
2. The `build.sh` script downloads the Typst binary and compiles `document.typ` to SVG
3. The `public/` directory (with `index.html` + the SVGs) is served on the CDN
4. The home page dynamically loads every page of the document

## Usage

### 1. Clone and customize

```bash
git clone <this-repo> my-site
cd my-site
# Edit document.typ with your content
```

### 2. Deploy on Vercel

- Go to [vercel.com/new](https://vercel.com/new)
- Import the repo
- Vercel reads `vercel.json` automatically — nothing to configure
- Click **Deploy**

### 3. Deploy on Cloudflare Pages

- Go to [dash.cloudflare.com](https://dash.cloudflare.com) → Workers & Pages → Create → Pages → Connect to Git
- Select the repo
- Configure:
  - **Build command**: `bash build.sh`
  - **Build output directory**: `public`
- Click **Save and Deploy**

The same repo can be deployed to **both platforms in parallel** without conflict.

## Local testing

If you have Typst installed locally:

```bash
bash build.sh
# Then serve the public/ directory
python3 -m http.server -d public 8000
# Open http://localhost:8000
```

Otherwise, just push and check the result on the preview URL.

## Structure

```
.
├── document.typ       # your Typst content (edit this)
├── build.sh           # downloads Typst + fonts and compiles
├── public/
│   └── index.html     # display page (loads SVGs dynamically)
├── vercel.json        # Vercel config
├── wrangler.toml      # Cloudflare config (optional)
└── package.json
```

## Render mode

`build.sh` reads the `RENDER` environment variable to decide which format(s) to produce:

```bash
bash build.sh                # default: both (SVG + HTML)
RENDER=svg  bash build.sh    # SVG only (multi-page)
RENDER=html bash build.sh    # HTML only (single file, experimental)
RENDER=both bash build.sh    # explicit both
```

When both formats are available, `public/index.html` shows a **SVG / HTML toggle** in the header. Otherwise the available format is displayed directly. On Vercel / Cloudflare Pages, set `RENDER` in the build settings → Environment Variables to override the default.

The HTML view is rendered inline with **Shadow DOM** so the Typst-emitted CSS does not leak into the surrounding page.

## Customization

- **Web page styling**: edit the `<style>` block in `public/index.html`
- **Output format**: see "Render mode" above, or replace `page-{n}.svg` with `document.pdf` in `build.sh` if you prefer an embedded PDF

## Fonts

Fonts are **not stored in the repo** — `build.sh` downloads them from the [Google Fonts](https://fonts.google.com/) CSS API on every build. The legacy CSS endpoint returns `.ttf` URLs when called with an old `User-Agent`, which is exactly what Typst needs. This keeps the repo small (~30 KB) while still using custom typefaces. All three fonts are under the [SIL Open Font License](https://openfontlicense.org/):

- **[EB Garamond](https://fonts.google.com/specimen/EB+Garamond)** — classic serif for body text
- **[Inter](https://fonts.google.com/specimen/Inter)** — modern sans-serif for headings and UI
- **[JetBrains Mono](https://fonts.google.com/specimen/JetBrains+Mono)** — monospace for code

Files land in `fonts/` (gitignored) during the build, and `--font-path fonts` is passed to Typst so it can find them.

### Adding a font

1. Find the font on [Google Fonts](https://fonts.google.com/) and note its family name
2. Add an entry to the `families` list in `build.sh` with the desired weight/style spec (e.g. `400,400i,700`)
3. Use the family name in `document.typ`: `#set text(font: "Font Family Name")`

### Using only Typst's default fonts

Remove the font-download block and the `--font-path fonts` flag from `build.sh`.
