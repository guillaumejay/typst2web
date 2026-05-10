#!/bin/bash
set -euo pipefail

echo "==> Detecting architecture..."
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)  TYPST_ARCH="x86_64-unknown-linux-musl" ;;
  aarch64) TYPST_ARCH="aarch64-unknown-linux-musl" ;;
  *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac
echo "    Architecture: $ARCH (target: $TYPST_ARCH)"

# Render mode: svg | html | both (default both)
RENDER="${RENDER:-both}"
case "$RENDER" in
  svg|html|both) ;;
  *) echo "RENDER must be one of: svg, html, both (got: $RENDER)" >&2; exit 1 ;;
esac
echo "    Render mode: $RENDER"

# Pinned Typst version — bump intentionally to upgrade
TYPST_VERSION="v0.14.2"

echo "==> Downloading Typst ${TYPST_VERSION}..."
curl -fsSL "https://github.com/typst/typst/releases/download/${TYPST_VERSION}/typst-${TYPST_ARCH}.tar.xz" \
  | tar -xJ
TYPST_BIN="./typst-${TYPST_ARCH}/typst"
chmod +x "$TYPST_BIN"
echo "    Version: $($TYPST_BIN --version)"

echo "==> Downloading fonts from Google Fonts (TTF format)..."
mkdir -p fonts
# Old User-Agent forces the legacy CSS API to return .ttf URLs instead of .woff2
UA="Mozilla/4.0"

download_family() {
  local family="$1" slug="$2" spec="$3"
  local family_enc="${family// /+}"
  local css
  css=$(curl -fsSL -A "$UA" "https://fonts.googleapis.com/css?family=${family_enc}:${spec}")

  local weight="" style="" url=""
  while IFS= read -r line; do
    case "$line" in
      *"font-weight:"*) weight=$(echo "$line" | grep -oE '[0-9]+' | head -1) ;;
      *"font-style:"*)  style=$(echo "$line"  | grep -oE '(normal|italic|oblique)' | head -1) ;;
      *"src:"*)         url=$(echo "$line"   | grep -oE 'https://[^)]+\.ttf' | head -1) ;;
      *"}"*)
        if [ -n "$url" ] && [ -n "$weight" ] && [ -n "$style" ]; then
          local out="fonts/${slug}-${weight}-${style}.ttf"
          [ -f "$out" ] || curl -fsSL -A "$UA" -o "$out" "$url"
        fi
        weight=""; style=""; url=""
        ;;
    esac
  done <<< "$css"
}

download_family "EB Garamond"    "eb-garamond"    "400,400i,500,500i,600,600i,700,700i"
download_family "Inter"          "inter"          "400,400i,500,600,700"
download_family "JetBrains Mono" "jetbrains-mono" "400,400i,500,500i,700,700i"

echo "    $(ls fonts/*.ttf | wc -l) font files ready"

echo "==> Preparing output directory..."
mkdir -p public
# Clean up previous outputs (useful locally, no-op in CI)
rm -f public/page-*.svg public/document.svg public/document.html

if [ "$RENDER" = "svg" ] || [ "$RENDER" = "both" ]; then
  echo "==> Compiling SVG..."
  # Multi-page SVG: page-1.svg, page-2.svg, ...
  "$TYPST_BIN" compile --font-path fonts document.typ "public/page-{n}.svg"
  PAGE_COUNT=$(ls public/page-*.svg 2>/dev/null | wc -l)
  echo "    $PAGE_COUNT SVG page(s) generated"
fi

if [ "$RENDER" = "html" ] || [ "$RENDER" = "both" ]; then
  echo "==> Compiling HTML..."
  # HTML export is experimental — needs --features html
  "$TYPST_BIN" compile --features html --font-path fonts document.typ public/document.html
  echo "    HTML generated: public/document.html"
fi

echo "==> Generating page manifest..."
{
  echo "{"

  echo "  \"svg\": ["
  first=1
  if [ "$RENDER" = "svg" ] || [ "$RENDER" = "both" ]; then
    for f in public/page-*.svg; do
      [ -f "$f" ] || continue
      name=$(basename "$f")
      if [ $first -eq 1 ]; then
        first=0
      else
        echo ","
      fi
      printf "    \"%s\"" "$name"
    done
    if [ $first -eq 0 ]; then echo ""; fi
  fi
  echo "  ],"

  if [ -f public/document.html ]; then
    echo "  \"html\": \"document.html\""
  else
    echo "  \"html\": null"
  fi

  echo "}"
} > public/pages.json

echo "==> Build complete!"
