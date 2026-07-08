#!/usr/bin/env node
/**
 * Remove baked-in light backgrounds from marker SVG assets.
 *
 * - Vector SVGs: strips the full-canvas background path (e.g. fill="#f8f8f8").
 * - Raster-wrapped SVGs: makes near-white PNG pixels transparent.
 *
 * Usage:
 *   npm install --prefix scripts
 *   node scripts/strip_marker_svg_backgrounds.mjs
 */

import { readFileSync, readdirSync, statSync, writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const scriptDir = dirname(fileURLToPath(import.meta.url));
const require = createRequire(join(scriptDir, 'package.json'));
const { PNG } = require('pngjs');

const markersDir = join(scriptDir, '../wayfinder_flutter/assets/markers');
const pinFileName = 'marker_pin.svg';

const BACKGROUND_PATH_RE =
  /<path\s+(?:fill="([^"]+)"\s+d="M0 0h[\d.]+v[\d.]+H0z"|d="M0 0h[\d.]+v[\d.]+H0z"\s+fill="([^"]+)")\s*\/>/gi;

const EMBEDDED_PNG_RE =
  /(<svg[^>]*>)\s*<image[^>]*href="data:image\/png;base64,([^"]+)"[^>]*\/>\s*(<\/svg>)/s;

function isLightBackgroundFill(fill) {
  if (!fill) {
    return false;
  }
  const normalized = fill.trim().toLowerCase();
  if (normalized === 'white' || normalized === 'none' || normalized === 'transparent') {
    return normalized === 'white';
  }
  const match = normalized.match(/^#([0-9a-f]{3,8})$/);
  if (!match) {
    return false;
  }
  let hex = match[1];
  if (hex.length === 3) {
    hex = hex.split('').map((ch) => ch + ch).join('');
  }
  if (hex.length !== 6) {
    return false;
  }
  const r = Number.parseInt(hex.slice(0, 2), 16);
  const g = Number.parseInt(hex.slice(2, 4), 16);
  const b = Number.parseInt(hex.slice(4, 6), 16);
  const min = Math.min(r, g, b);
  const max = Math.max(r, g, b);
  return min >= 235 && (max - min) <= 24;
}

function stripVectorBackground(svg) {
  let removed = false;
  const updated = svg.replace(BACKGROUND_PATH_RE, (match, fillA, fillB) => {
    const fill = fillA ?? fillB;
    if (!isLightBackgroundFill(fill)) {
      return match;
    }
    removed = true;
    return '';
  });
  return { svg: updated, removed };
}

async function stripRasterBackground(svg) {
  const match = svg.match(EMBEDDED_PNG_RE);
  if (!match) {
    return { svg, removed: false };
  }

  const [, openTag, base64, closeTag] = match;
  const png = PNG.sync.read(Buffer.from(base64, 'base64'));
  let changedPixels = 0;

  for (let y = 0; y < png.height; y += 1) {
    for (let x = 0; x < png.width; x += 1) {
      const idx = (png.width * y + x) << 2;
      const r = png.data[idx];
      const g = png.data[idx + 1];
      const b = png.data[idx + 2];
      const min = Math.min(r, g, b);
      const max = Math.max(r, g, b);
      if (min >= 235 && (max - min) <= 24) {
        if (png.data[idx + 3] !== 0) {
          changedPixels += 1;
        }
        png.data[idx + 3] = 0;
      }
    }
  }

  if (changedPixels === 0) {
    return { svg, removed: false };
  }

  const transparentPng = PNG.sync.write(png);
  const wrapped =
    `${openTag}\n` +
    `  <image width="${png.width}" height="${png.height}" ` +
    `href="data:image/png;base64,${transparentPng.toString('base64')}"/>\n` +
    `${closeTag}\n`;

  return { svg: wrapped, removed: true };
}

function formatBytes(bytes) {
  if (bytes < 1024) {
    return `${bytes} B`;
  }
  if (bytes < 1024 * 1024) {
    return `${(bytes / 1024).toFixed(1)} KiB`;
  }
  return `${(bytes / (1024 * 1024)).toFixed(2)} MiB`;
}

const files = readdirSync(markersDir)
  .filter((name) => name.endsWith('.svg'))
  .sort();

let changed = 0;

for (const [index, fileName] of files.entries()) {
  if (fileName === pinFileName) {
    continue;
  }

  const path = join(markersDir, fileName);
  const original = readFileSync(path, 'utf8');
  const originalBytes = statSync(path).size;

  let result;
  if (original.includes('href="data:image/png;base64,')) {
    result = await stripRasterBackground(original);
  } else {
    result = stripVectorBackground(original);
  }

  if (!result.removed) {
    continue;
  }

  writeFileSync(path, result.svg);
  const finalBytes = statSync(path).size;
  changed += 1;
  console.log(
    `[${index + 1}/${files.length}] ${fileName}: background removed ` +
      `(${formatBytes(originalBytes)} -> ${formatBytes(finalBytes)})`,
  );
}

console.log(`Stripped backgrounds from ${changed} marker SVGs.`);
