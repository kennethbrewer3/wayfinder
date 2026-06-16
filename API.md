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
| 500 | Server error |

### Authentication

The REST API does not currently require authentication. The Flutter app uses separate Serverpod RPC endpoints on port **18080** with JWT auth.

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

Optional: `notes`, `visible` (defaults to `true`).

```bash
curl -X POST http://localhost:18082/api/markers \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Trailhead",
    "latitude": 38.910381,
    "longitude": -77.263527,
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
  -d '{"notes":"Updated via curl","visible":false}'
```

`PUT` works the same way.

### Delete a marker

```bash
curl -X DELETE http://localhost:18082/api/markers/9e2ee7b0-9ba4-4e17-8948-54ae65d82da6
```

Returns HTTP 204 on success.

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

## Endpoint summary

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/` | API index |
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
