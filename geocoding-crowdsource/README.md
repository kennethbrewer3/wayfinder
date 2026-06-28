# Wayfinder geocoding crowdsource

Anonymous community geocoding locations shared across Wayfinder installs.

## Format

`contributions.json` contains only location data — no user names, emails, or device identifiers:

```json
{
  "version": 1,
  "type": "geocode_crowdsource",
  "exportedAt": "2026-06-15T00:00:00.000Z",
  "entries": [
    {
      "contentKey": "<sha256 of normalized name|lat|lng>",
      "name": "Example Trailhead",
      "latitude": 47.12345,
      "longitude": -122.54321,
      "notes": "Optional hint shown in search results",
      "countryCode": "US"
    }
  ]
}
```

Each entry is deduplicated by `contentKey`. Wayfinder computes the same key locally so imports and submissions merge safely.

## Contributing

1. In **Settings → Geocoding**, add locations under **Custom locations**.
2. Use **Submit to crowdsource** to upload anonymously (when the geocoding server has a GitHub token configured), or export the anonymous bundle and open a pull request that updates `contributions.json`.
3. Others import via **Import crowdsource data** using the raw GitHub URL of this file.

## Server configuration (optional)

Set these environment variables on the geocoding server to enable direct anonymous uploads:

- `GEOCODING_CROWDSOURCE_GITHUB_TOKEN` — fine-grained token with contents write access
- `GEOCODING_CROWDSOURCE_GITHUB_REPO` — default `kennethbrewer3/wayfinder`
- `GEOCODING_CROWDSOURCE_GITHUB_FILE` — default `geocoding-crowdsource/contributions.json`

Without a token, the server returns an anonymous JSON bundle that you can submit manually.
