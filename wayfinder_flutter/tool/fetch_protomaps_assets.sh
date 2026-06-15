#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SPRITE_DIR="$ROOT/assets/protomaps/sprites/v4/light"
FONT_DIR="$ROOT/assets/protomaps/fonts"

mkdir -p "$SPRITE_DIR" "$FONT_DIR"

curl -fsSL "https://protomaps.github.io/basemaps-assets/sprites/v4/light@2x.json" \
  -o "$SPRITE_DIR/light@2x.json"
curl -fsSL "https://protomaps.github.io/basemaps-assets/sprites/v4/light@2x.png" \
  -o "$SPRITE_DIR/light@2x.png"

BASE="https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSans"
curl -fsSL "$BASE/NotoSans-Regular.ttf" -o "$FONT_DIR/NotoSans-Regular.ttf"
curl -fsSL "$BASE/NotoSans-Italic.ttf" -o "$FONT_DIR/NotoSans-Italic.ttf"
curl -fsSL "$BASE/NotoSans-Medium.ttf" -o "$FONT_DIR/NotoSans-Medium.ttf"

echo "Protomaps offline assets refreshed."
