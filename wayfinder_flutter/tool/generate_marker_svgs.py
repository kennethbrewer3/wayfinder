#!/usr/bin/env python3
"""Download Material Design SVGs for marker icons missing from assets/markers/."""

from __future__ import annotations

import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "lib/features/markers/models/marker_icon_registry.dart"
OUT = ROOT / "assets/markers"

CATEGORIES = [
    "action",
    "maps",
    "social",
    "places",
    "navigation",
    "communication",
    "content",
    "device",
    "editor",
    "notification",
    "av",
    "image",
    "file",
    "hardware",
    "search",
    "home",
]

SYMBOL_OVERRIDES = {
    "fire_hydrant": "fire_hydrant",
    "directions_ferry": "directions_boat",
}

FILE_OVERRIDES = {
    "nuclear_weapons_facility": "nuclear.svg",
}


def parse_registry() -> list[tuple[str, str]]:
    text = REGISTRY.read_text()
    blocks = text.split("MarkerIconOption(")[1:]
    icons: list[tuple[str, str]] = []
    for block in blocks:
        key_match = re.search(r"key: '([^']+)'", block)
        if not key_match:
            continue
        key = key_match.group(1)
        icon_match = re.search(r"icon: Icons\.(\w+)", block)
        material = icon_match.group(1) if icon_match else key
        icons.append((key, material))
    return icons


def fetch(url: str) -> str | None:
    try:
        with urllib.request.urlopen(url, timeout=20) as response:
            if response.status != 200:
                return None
            return response.read().decode("utf-8")
    except (urllib.error.URLError, TimeoutError):
        return None


def download_material_icon(material: str) -> str | None:
    for category in CATEGORIES:
        url = (
            "https://raw.githubusercontent.com/google/material-design-icons/"
            f"master/src/{category}/{material}/materialicons/24px.svg"
        )
        content = fetch(url)
        if content and "<svg" in content:
            return normalize_svg(content)
    return None


def download_symbol_icon(material: str) -> str | None:
    symbol = SYMBOL_OVERRIDES.get(material, material)
    url = (
        "https://raw.githubusercontent.com/google/material-design-icons/"
        f"master/symbols/web/{symbol}/materialsymbolsoutlined/{symbol}_24px.svg"
    )
    content = fetch(url)
    if content and "<svg" in content:
        return normalize_svg(content)
    return None


def normalize_svg(content: str) -> str:
    content = re.sub(
        r'<path d="M0 0h24v24H0z" fill="none"/>',
        "",
        content,
    )
    content = re.sub(
        r'<path d="M0 0h24v24H0V0z" fill="none"/>',
        "",
        content,
    )
    if 'viewBox="0 0 24 24"' not in content and "viewBox=" not in content:
        content = content.replace("<svg ", '<svg viewBox="0 0 24 24" ', 1)
    return content.strip() + "\n"


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    icons = parse_registry()
    created = 0
    skipped = 0
    failed: list[str] = []

    for key, material in icons:
        target = OUT / f"{key}.svg"
        if target.exists():
            skipped += 1
            continue

        override_name = FILE_OVERRIDES.get(key)
        if override_name:
            source = OUT / override_name
            if source.exists():
                target.write_text(source.read_text())
                print(f"copied {override_name} -> {key}.svg")
                created += 1
                continue

        svg = download_material_icon(material)
        if svg is None:
            svg = download_symbol_icon(material)
        if svg is None:
            failed.append(f"{key} ({material})")
            continue

        target.write_text(svg)
        print(f"created {key}.svg from {material}")
        created += 1

    print(f"\nDone: {created} created, {skipped} already present, {len(failed)} failed")
    if failed:
        print("Failed:")
        for item in failed:
            print(f"  - {item}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
