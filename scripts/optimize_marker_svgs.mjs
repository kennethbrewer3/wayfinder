#!/usr/bin/env node
/**
 * Optimize marker SVG assets for the Flutter client.
 *
 * 1. Run SVGO on every SVG in wayfinder_flutter/assets/markers.
 * 2. For files still larger than the raster threshold, render to a 512px-wide
 *    PNG and replace the SVG with a lightweight wrapper that embeds the PNG.
 *
 * Usage:
 *   node scripts/optimize_marker_svgs.mjs [--dry-run] [--threshold-kb 400] [--raster-width 512]
 *
 * Requires npx access to: svgo, @resvg/resvg-js-cli
 */

import { execFileSync } from 'node:child_process';
import {
  mkdtempSync,
  readFileSync,
  readdirSync,
  rmSync,
  statSync,
  writeFileSync,
} from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const scriptDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(scriptDir, '..');
const markersDir = join(repoRoot, 'wayfinder_flutter/assets/markers');
const svgoConfig = join(scriptDir, 'svgo.marker.config.cjs');
const pinSvgoConfig = join(scriptDir, 'svgo.marker-pin.config.cjs');
const pinFileName = 'marker_pin.svg';

const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const thresholdIndex = args.indexOf('--threshold-kb');
const rasterWidthIndex = args.indexOf('--raster-width');
const thresholdKb = thresholdIndex === -1
  ? 400
  : Number.parseInt(args[thresholdIndex + 1] ?? '400', 10);
const rasterWidth = rasterWidthIndex === -1
  ? 512
  : Number.parseInt(args[rasterWidthIndex + 1] ?? '512', 10);
const rasterThresholdBytes = thresholdKb * 1024;

function run(command, commandArgs) {
  execFileSync(command, commandArgs, { stdio: 'pipe' });
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

function pngDimensions(pngBuffer) {
  return {
    width: pngBuffer.readUInt32BE(16),
    height: pngBuffer.readUInt32BE(20),
  };
}

function svgoOptimize(inputPath, outputPath, configPath) {
  run('npx', ['--yes', 'svgo', '--config', configPath, inputPath, '-o', outputPath]);
}

function rasterizeToPng(inputSvgPath, outputPngPath) {
  run('npx', [
    '--yes',
    '@resvg/resvg-js-cli',
    '--fit-width',
    String(rasterWidth),
    '--no-system-font',
    inputSvgPath,
    outputPngPath,
  ]);
}

function wrapPngAsSvg(pngBuffer) {
  const { width, height } = pngDimensions(pngBuffer);
  const base64 = pngBuffer.toString('base64');
  return `<?xml version="1.0" encoding="UTF-8"?>\n` +
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${width} ${height}" width="${width}" height="${height}">\n` +
    `  <image width="${width}" height="${height}" href="data:image/png;base64,${base64}"/>\n` +
    `</svg>\n`;
}

const BACKGROUND_PATH_RE =
  /<path\s+(?:fill="([^"]+)"\s+d="M0 0h[\d.]+v[\d.]+H0z"|d="M0 0h[\d.]+v[\d.]+H0z"\s+fill="([^"]+)")\s*\/>/gi;

function isLightBackgroundFill(fill) {
  if (!fill) {
    return false;
  }
  const normalized = fill.trim().toLowerCase();
  if (normalized === 'white') {
    return true;
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
  return svg.replace(BACKGROUND_PATH_RE, (match, fillA, fillB) => {
    const fill = fillA ?? fillB;
    return isLightBackgroundFill(fill) ? '' : match;
  });
}

const tempDir = mkdtempSync(join(tmpdir(), 'marker-svg-opt-'));
const results = [];

try {
  const files = readdirSync(markersDir)
    .filter((name) => name.endsWith('.svg'))
    .map((fileName) => ({
      fileName,
      bytes: statSync(join(markersDir, fileName)).size,
    }))
    .sort((a, b) => b.bytes - a.bytes);

  console.log(
    `${dryRun ? '[dry-run] ' : ''}Optimizing ${files.length} marker SVGs...`,
  );

  for (const [index, { fileName }] of files.entries()) {
    const inputPath = join(markersDir, fileName);
    const originalBytes = statSync(inputPath).size;
    const optimizedPath = join(tempDir, `${fileName}.optimized.svg`);
    const pngPath = join(tempDir, `${fileName}.png`);
    const configPath = fileName === pinFileName ? pinSvgoConfig : svgoConfig;

    svgoOptimize(inputPath, optimizedPath, configPath);
    const optimizedBytes = statSync(optimizedPath).size;

    let action = 'svgo';
    let finalBytes = optimizedBytes;
    let finalContents = readFileSync(optimizedPath);

    if (
      fileName !== pinFileName &&
      optimizedBytes > rasterThresholdBytes
    ) {
      rasterizeToPng(optimizedPath, pngPath);
      const pngBuffer = readFileSync(pngPath);
      finalContents = wrapPngAsSvg(pngBuffer);
      finalBytes = finalContents.length;
      action = 'raster';
    }

    if (!dryRun) {
      if (action === 'raster') {
        writeFileSync(inputPath, finalContents);
      } else {
        writeFileSync(inputPath, stripVectorBackground(finalContents));
      }
    }

    results.push({
      fileName,
      action,
      originalBytes,
      finalBytes,
      savedBytes: originalBytes - finalBytes,
    });

    console.log(
      `[${index + 1}/${files.length}] ${fileName}: ` +
        `${formatBytes(originalBytes)} -> ${formatBytes(finalBytes)} [${action}]`,
    );
  }
} finally {
  rmSync(tempDir, { recursive: true, force: true });
}

const totalOriginal = results.reduce((sum, row) => sum + row.originalBytes, 0);
const totalFinal = results.reduce((sum, row) => sum + row.finalBytes, 0);
const rasterized = results.filter((row) => row.action === 'raster');

console.log(
  `${dryRun ? '[dry-run] ' : ''}Optimized ${results.length} marker SVGs in ${markersDir}`,
);
console.log(
  `Total: ${formatBytes(totalOriginal)} -> ${formatBytes(totalFinal)} ` +
    `(${((1 - totalFinal / totalOriginal) * 100).toFixed(1)}% smaller)`,
);
console.log(
  `SVGO only: ${results.length - rasterized.length}, rasterized: ${rasterized.length}`,
);

for (const row of results.sort((a, b) => b.savedBytes - a.savedBytes).slice(0, 20)) {
  if (row.savedBytes <= 0) {
    continue;
  }
  console.log(
    `  ${row.fileName}: ${formatBytes(row.originalBytes)} -> ${formatBytes(row.finalBytes)} ` +
      `[${row.action}]`,
  );
}
