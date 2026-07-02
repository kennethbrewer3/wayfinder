# Wayfinder REST API

This document describes the public REST API exposed by the Wayfinder web server. Use it with `curl`, scripts, or any HTTP client.

## Base URL

Local development default:

```text
http://localhost:18082
```

All REST resources live under `/api`. PMTiles file bytes are served separately under `/pmtiles/files/`.

Discover available routes:

```bash
curl http://localhost:18082/api/
```

## Conventions

### Request format

- Send JSON bodies with `Content-Type: application/json`.
- UUID path parameters use standard UUID strings (for example `69d0219b-ab94-4f42-94dd-3d102c35ee91`).
- `PUT` and `PATCH` both accept partial updates; only fields present in the body are changed.

### Response format

Successful responses return plain JSON objects or arrays. Serverpod internal fields such as `__className__` are stripped.

Errors return JSON with an `error` message:

```json
{"error":"Marker not found"}
```

| HTTP status | Meaning |
|-------------|---------|
| 200 | Success |
| 201 | Created |
| 204 | Success, no body (typical for deletes) |
| 400 | Invalid request (bad JSON, missing field, invalid UUID) |
| 404 | Resource not found |
| 503 | Service unavailable (health check failed) |
| 500 | Server error |

### Authentication

When a REST API key is configured, all endpoints except `GET /api/` and `GET /api/health` require authentication.

Send the key using either header:

```bash
curl -H "X-API-Key: wf_your_key_here" http://localhost:18082/api/markers
```

```bash
curl -H "Authorization: Bearer wf_your_key_here" http://localhost:18082/api/markers
```

**Configure keys**

1. In the Wayfinder app: **Settings → About → REST API access → Create API key** (enter a name for each app or device)
2. Create additional keys for other integrations; removing one key does not affect the others
3. Or set `WAYFINDER_REST_API_KEY` in the server `.env` file (useful for Docker/scripts)

Keys are stored on the server as SHA-256 hashes. The plaintext key is shown only once when created.

Signed-in Serverpod users can also call the REST API with a JWT access token in the `Authorization: Bearer` header (tokens that start with `wf_` are treated as API keys).

When no key is configured, the REST API remains open (intended for local development only).

---

## Health check

Use this endpoint for load balancers, uptime monitors, and cron scripts.

### Check server health

```bash
curl http://localhost:18082/api/health
```

When the server and its dependencies are healthy, the response is HTTP **200** with the JSON boolean:

```json
true
```

When a dependency check fails, the response is HTTP **503** with diagnostic details:

```json
{
  "healthy": false,
  "checks": {
    "database": {
      "ok": false,
      "error": "connection refused"
    },
    "pmtilesStorage": {
      "ok": true,
      "path": "storage/pmtiles"
    }
  }
}
```

Checks performed:

| Check | Description |
|-------|-------------|
| `database` | PostgreSQL reachable; runs a lightweight query |
| `pmtilesStorage` | PMTiles upload directory exists or can be created |

---

## Markers

### List markers

```bash
curl http://localhost:18082/api/markers
```

### Get one marker

```bash
curl http://localhost:18082/api/markers/69d0219b-ab94-4f42-94dd-3d102c35ee91
```

### Create a marker

Required fields: `name`, `latitude`, `longitude`, `color`, `icon`.

Optional: `notes`, `visible` (defaults to `true`), `elevation` in meters (defaults to `0`), `layerId` (UUID of a map layer).

```bash
curl -X POST http://localhost:18082/api/markers \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Trailhead",
    "latitude": 38.910381,
    "longitude": -77.263527,
    "elevation": 125.5,
    "color": "#009688",
    "icon": "place",
    "visible": true,
    "notes": "Parking lot entrance"
  }'
```

Example response:

```json
{
  "id": "9e2ee7b0-9ba4-4e17-8948-54ae65d82da6",
  "name": "Trailhead",
  "notes": "Parking lot entrance",
  "latitude": 38.910381,
  "longitude": -77.263527,
  "elevation": 125.5,
  "color": "#009688",
  "icon": "place",
  "visible": true,
  "createdAt": "2026-06-16T20:57:37.102516Z",
  "updatedAt": "2026-06-16T20:57:37.102516Z"
}
```

### Update a marker

```bash
curl -X PATCH http://localhost:18082/api/markers/9e2ee7b0-9ba4-4e17-8948-54ae65d82da6 \
  -H "Content-Type: application/json" \
  -d '{"notes":"Updated via curl","elevation":130,"visible":false}'
```

`PUT` works the same way.

### Weather station readings

Weather station markers (`icon: "weather_station"`) can store local weather readings on the server in `weatherJson`. This field is intended for data ingested from APRS or other offline/local integrations — Wayfinder does not fetch weather from the public internet.

`weatherJson` is a JSON **string** containing the latest reading at the top level, with optional `history` for recent readings:

```json
{
  "observedAt": "2026-06-29T15:00:00.000Z",
  "source": "aprs",
  "temperature": 22.4,
  "temperatureUnit": "C",
  "apparentTemperature": 21.0,
  "humidityPercent": 58,
  "precipitation": 0.0,
  "precipitationUnit": "mm",
  "weatherCode": 3,
  "condition": "Overcast",
  "windSpeed": 12.0,
  "windSpeedUnit": "km/h",
  "windDirectionDegrees": 225,
  "pressure": 1015.0,
  "pressureUnit": "hPa",
  "history": [
    {
      "observedAt": "2026-06-29T14:00:00.000Z",
      "temperature": 21.8,
      "condition": "Cloudy"
    }
  ]
}
```

Update a weather station marker via REST:

```bash
curl -X PATCH http://localhost:18082/api/markers/9e2ee7b0-9ba4-4e17-8948-54ae65d82da6 \
  -H "Content-Type: application/json" \
  -d '{"weatherJson":"{\"observedAt\":\"2026-06-29T15:00:00.000Z\",\"source\":\"aprs\",\"temperature\":22.4,\"temperatureUnit\":\"C\",\"humidityPercent\":58,\"condition\":\"Overcast\"}"}'
```

### Delete a marker

```bash
curl -X DELETE http://localhost:18082/api/markers/9e2ee7b0-9ba4-4e17-8948-54ae65d82da6
```

Returns HTTP 204 on success.

---

## Map layers

Map layers group markers and zones. Layer order controls draw order (higher `sortOrder` draws on top). Toggling a layer's `visible` flag hides all of its contents on the map.

### List layers

```bash
curl http://localhost:18082/api/layers
```

### Get one layer

```bash
curl http://localhost:18082/api/layers/00000000-0000-4000-8000-000000000001
```

### Create a layer

Required: `name`. Optional: `sortOrder` (auto-assigned if omitted), `visible` (defaults to `true`).

```bash
curl -X POST http://localhost:18082/api/layers \
  -H "Content-Type: application/json" \
  -d '{"name":"Trails","visible":true}'
```

### Update a layer

```bash
curl -X PATCH http://localhost:18082/api/layers/00000000-0000-4000-8000-000000000001 \
  -H "Content-Type: application/json" \
  -d '{"visible":false}'
```

### Reorder layers

Send the full desired order. Each entry needs `id` and `sortOrder` (`0` = bottom, higher values draw above).

```bash
curl -X POST http://localhost:18082/api/layers/reorder \
  -H "Content-Type: application/json" \
  -d '{
    "layers": [
      {"id":"00000000-0000-4000-8000-000000000001","sortOrder":0},
      {"id":"9e2ee7b0-9ba4-4e17-8948-54ae65d82da6","sortOrder":1}
    ]
  }'
```

### Delete a layer

Cannot delete the last remaining layer. Markers and zones on the deleted layer are moved to another layer.

```bash
curl -X DELETE http://localhost:18082/api/layers/9e2ee7b0-9ba4-4e17-8948-54ae65d82da6
```

---

## Zones

Zones represent map overlays: lines, circles, and rectangles.

### Zone object fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Assigned by the server |
| `name` | string | Display name |
| `type` | string | `line`, `circle`, or `rectangle` |
| `color` | string | Hex color (used mainly for lines) |
| `borderColor` | string | Hex border color |
| `borderPattern` | string | `solid` or `dashed` |
| `fillColor` | string | Hex fill color (often with alpha) |
| `visible` | boolean | Whether the zone is shown on the map |
| `layerId` | UUID | Map layer this zone belongs to |
| `geometryJson` | string | JSON string with type-specific geometry |
| `createdAt` | datetime | UTC timestamp |
| `updatedAt` | datetime | UTC timestamp |

### List zones

```bash
curl http://localhost:18082/api/zones
```

### Get one zone

```bash
curl http://localhost:18082/api/zones/{id}
```

### Create a line zone

`geometryJson` must be a JSON **string** containing the geometry object.

```bash
curl -X POST http://localhost:18082/api/zones \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Fence line",
    "type": "line",
    "color": "#2196F3",
    "borderColor": "#2196F3",
    "borderPattern": "solid",
    "fillColor": "#2196F300",
    "visible": true,
    "geometryJson": "{\"points\":[{\"lat\":38.91,\"lng\":-77.26},{\"lat\":38.912,\"lng\":-77.258}],\"showArrows\":true,\"showDistanceLabel\":true,\"showNameLabel\":false}"
  }'
```

### Create a circle zone

```bash
curl -X POST http://localhost:18082/api/zones \
  -H "Content-Type: application/json" \
  -d '{
    "name": "500m radius",
    "type": "circle",
    "color": "#009688",
    "borderColor": "#009688",
    "borderPattern": "solid",
    "fillColor": "#00968833",
    "visible": true,
    "geometryJson": "{\"center\":{\"lat\":38.910381,\"lng\":-77.263527},\"radiusMeters\":500,\"radiusLineBearing\":90,\"sizeDisplay\":\"radius\",\"showNameLabel\":false}"
  }'
```

### Create a rectangle zone

```bash
curl -X POST http://localhost:18082/api/zones \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Field",
    "type": "rectangle",
    "color": "#FF9800",
    "borderColor": "#FF9800",
    "borderPattern": "solid",
    "fillColor": "#FF980033",
    "visible": true,
    "geometryJson": "{\"creationMode\":\"center_extent\",\"bounds\":{\"southWest\":{\"lat\":38.909,\"lng\":-77.265},\"northEast\":{\"lat\":38.912,\"lng\":-77.262}},\"center\":{\"lat\":38.9105,\"lng\":-77.2635},\"extentPoint\":{\"lat\":38.912,\"lng\":-77.262},\"sizeDisplay\":\"dimensions\",\"showNameLabel\":false}"
  }'
```

### Update a zone

```bash
curl -X PATCH http://localhost:18082/api/zones/{id} \
  -H "Content-Type: application/json" \
  -d '{"name":"Renamed zone","visible":false}'
```

### Delete a zone

```bash
curl -X DELETE http://localhost:18082/api/zones/{id}
```

---

## Categories

Categories are optional organizational groupings.

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Assigned by the server |
| `parentId` | UUID or null | Parent category, if nested |
| `name` | string | Category name |
| `sortOrder` | integer | Sort position |

### List categories

```bash
curl http://localhost:18082/api/categories
```

### Create a category

```bash
curl -X POST http://localhost:18082/api/categories \
  -H "Content-Type: application/json" \
  -d '{"name":"Trails","sortOrder":0}'
```

### Update a category

```bash
curl -X PATCH http://localhost:18082/api/categories/{id} \
  -H "Content-Type: application/json" \
  -d '{"sortOrder":1}'
```

### Delete a category

```bash
curl -X DELETE http://localhost:18082/api/categories/{id}
```

---

## PMTiles

PMTiles metadata is managed through the REST API. File bytes are uploaded as raw binary and downloaded through a separate static route.

### List PMTiles files

```bash
curl http://localhost:18082/api/pmtiles
```

Example response:

```json
[
  {
    "id": "17feeaff-1532-4709-8786-0225974b2691",
    "name": "virginia_2025-12.pmtiles",
    "sizeBytes": 467537819,
    "isActive": true,
    "addedAt": "2026-06-15T14:27:23.354366Z"
  }
]
```

### Get active PMTiles file

```bash
curl http://localhost:18082/api/pmtiles/active
```

Example response:

```json
{"id":"17feeaff-1532-4709-8786-0225974b2691"}
```

If no file is active, `id` is `null`.

### Set active PMTiles file

```bash
curl -X PUT http://localhost:18082/api/pmtiles/active \
  -H "Content-Type: application/json" \
  -d '{"id":"17feeaff-1532-4709-8786-0225974b2691"}'
```

### Clear active PMTiles file

```bash
curl -X DELETE http://localhost:18082/api/pmtiles/active
```

### Upload a PMTiles file

Upload the raw `.pmtiles` bytes. The `name` query parameter must end with `.pmtiles`.

```bash
curl -X POST "http://localhost:18082/api/pmtiles/upload?name=virginia_2025-12.pmtiles" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @virginia_2025-12.pmtiles
```

The same upload is also available at the legacy path:

```bash
curl -X POST "http://localhost:18082/pmtiles/upload?name=virginia_2025-12.pmtiles" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @virginia_2025-12.pmtiles
```

If no file is currently active, the newly uploaded file becomes active automatically.

### Download a PMTiles file

Use the file `id` from the catalog. Range requests are supported.

```bash
curl -O "http://localhost:18082/pmtiles/files/17feeaff-1532-4709-8786-0225974b2691"
```

### Delete a PMTiles file

Removes both the catalog entry and the file on disk. If the deleted file was active, the most recently added remaining file becomes active.

```bash
curl -X DELETE http://localhost:18082/api/pmtiles/17feeaff-1532-4709-8786-0225974b2691
```

---

## Map data backup

Export or restore the full map structure (layers, markers, and zones) in one JSON document. IDs and relationships are preserved on restore.

### Export all map data

```bash
curl http://localhost:18082/api/map-data
```

Save to a dated backup file:

```bash
curl -s http://localhost:18082/api/map-data \
  -o "wayfinder-backup-$(date -u +%Y-%m-%d).json"
```

Example response shape:

```json
{
  "version": 1,
  "exportedAt": "2026-06-15T12:34:56.789Z",
  "layers": [ { "id": "…", "name": "Default", "sortOrder": 0, "visible": true, "createdAt": "…", "updatedAt": "…" } ],
  "markers": [ { "id": "…", "name": "Trailhead", "latitude": 38.9, "longitude": -77.2, "elevation": 0, "color": "#1B4965", "icon": "place", "visible": true, "layerId": "…", "createdAt": "…", "updatedAt": "…" } ],
  "zones": [ { "id": "…", "name": "Route", "type": "line", "color": "#1B4965", "borderColor": "#1B4965", "borderPattern": "solid", "fillColor": "#1B4965", "visible": true, "geometryJson": "{…}", "layerId": "…", "createdAt": "…", "updatedAt": "…" } ]
}
```

### Restore map data

**Warning:** This replaces all existing layers, markers, and zones on the server.

Required top-level fields: `version` (must be `1`), `layers`, `markers`, and `zones` (arrays). Use the same object shapes returned by export.

```bash
curl -X POST http://localhost:18082/api/map-data/restore \
  -H "Content-Type: application/json" \
  --data-binary @wayfinder-backup.json
```

Example response:

```json
{
  "restored": {
    "layers": 2,
    "markers": 15,
    "zones": 8
  }
}
```

If the backup has no layers, a default layer is created. Markers or zones referencing unknown `layerId` values are assigned to the first layer in the backup.

### Cron backup example

```bash
0 2 * * * curl -sf http://localhost:18082/api/map-data -o "/backups/wayfinder-$(date +\%Y\%m\%d).json"
```

---

## Endpoint summary

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/` | API index |
| GET | `/api/health` | Server health check |
| GET | `/api/markers` | List markers |
| GET | `/api/markers/:id` | Get marker |
| POST | `/api/markers` | Create marker |
| PUT/PATCH | `/api/markers/:id` | Update marker |
| DELETE | `/api/markers/:id` | Delete marker |
| GET | `/api/zones` | List zones |
| GET | `/api/zones/:id` | Get zone |
| POST | `/api/zones` | Create zone |
| PUT/PATCH | `/api/zones/:id` | Update zone |
| DELETE | `/api/zones/:id` | Delete zone |
| GET | `/api/categories` | List categories |
| GET | `/api/categories/:id` | Get category |
| POST | `/api/categories` | Create category |
| PUT/PATCH | `/api/categories/:id` | Update category |
| DELETE | `/api/categories/:id` | Delete category |
| GET | `/api/layers` | List map layers |
| GET | `/api/layers/:id` | Get map layer |
| POST | `/api/layers` | Create map layer |
| PUT/PATCH | `/api/layers/:id` | Update map layer |
| POST | `/api/layers/reorder` | Reorder map layers |
| DELETE | `/api/layers/:id` | Delete map layer |
| GET | `/api/map-data` | Export all layers, markers, and zones |
| POST | `/api/map-data/restore` | Restore map data from backup JSON |
| GET | `/api/pmtiles` | List PMTiles catalog |
| POST | `/api/pmtiles/upload?name=…` | Upload PMTiles bytes |
| GET | `/api/pmtiles/active` | Get active file id |
| PUT | `/api/pmtiles/active` | Set active file |
| DELETE | `/api/pmtiles/active` | Clear active file |
| DELETE | `/api/pmtiles/:id` | Delete catalog entry and file |
| GET | `/pmtiles/files/:id` | Download PMTiles bytes |

---

## Tips

- Pretty-print JSON responses with `curl … | python3 -m json.tool` or `jq`.
- Save a created resource id in a shell variable:

  ```bash
  ID=$(curl -s -X POST http://localhost:18082/api/markers \
    -H "Content-Type: application/json" \
    -d '{"name":"Test","latitude":38.9,"longitude":-77.2,"color":"#ff0000","icon":"place"}' \
    | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
  ```

- Zone `geometryJson` values are easiest to build in a file first, then pass to `curl` with `--data-binary @geometry.json` inside a wrapper JSON object, or by escaping the string carefully as shown above.
