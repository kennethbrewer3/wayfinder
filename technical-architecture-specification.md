# Offline PMTiles Map Management System

## Technical Architecture Specification

### Version

1.0

---

# 1. Architecture Overview

The system shall use a Flutter + Serverpod architecture.

```text
+---------------------------+
| Flutter Client            |
+---------------------------+
            |
            |
+---------------------------+
| Serverpod API             |
+---------------------------+
            |
            |
+---------------------------+
| PostgreSQL                |
+---------------------------+

Local Storage:
  PMTiles
  Search Indexes
  Cached Assets
```

---

# 2. Technology Stack

## Client

* Flutter
* Dart
* Riverpod
* flutter_map
* PMTiles renderer
* Markdown rendering
* SVG rendering

## Server

* Serverpod

## Database

* PostgreSQL

## Storage

* Local filesystem

---

# 3. Core Modules

## Map Module

Responsibilities:

* Render PMTiles
* Handle zooming
* Handle panning
* Coordinate transforms
* URL synchronization

---

## Marker Module

Responsibilities:

* Marker CRUD
* SVG rendering
* Marker visibility
* Marker grouping

---

## Zone Module

Responsibilities:

* Zone CRUD
* Polygon editing
* Curve editing
* Arrow rendering
* Measurement calculation

---

## Search Module

Responsibilities:

* Full text search
* Coordinate lookup
* Marker search
* Zone search

---

## Sidebar Module

Responsibilities:

* Marker panel
* Zone panel
* Tree view
* Sorting
* Filtering

---

# 4. Database Schema

## map_markers

| Field      | Type     |
| ---------- | -------- |
| id         | UUID     |
| name       | String   |
| notes      | Text     |
| latitude   | Double   |
| longitude  | Double   |
| color      | String   |
| icon       | String   |
| visible    | Boolean  |
| created_at | DateTime |
| updated_at | DateTime |

---

## map_zones

| Field          | Type     |
| -------------- | -------- |
| id             | UUID     |
| name           | String   |
| type           | String   |
| color          | String   |
| border_color   | String   |
| border_pattern | String   |
| fill_color     | String   |
| visible        | Boolean  |
| geometry_json  | JSON     |
| created_at     | DateTime |
| updated_at     | DateTime |

---

## categories

| Field      | Type    |
| ---------- | ------- |
| id         | UUID    |
| parent_id  | UUID    |
| name       | String  |
| sort_order | Integer |

---

# 5. Geometry Model

## Point

```json
{
  "lat": 38.8951,
  "lng": -77.0364
}
```

---

## Rectangle

```json
{
  "north": 0,
  "south": 0,
  "east": 0,
  "west": 0
}
```

---

## Circle

```json
{
  "center": {},
  "radius": 1000
}
```

---

## Polygon

```json
{
  "points": [],
  "curves": []
}
```

---

## Line

```json
{
  "points": [],
  "directional": true
}
```

---

# 6. Rendering Architecture

## Marker Rendering

Custom SVG:

```text
Anchor Point
      ↓
     /\
    /  \
   /    \
  |      |
  | Icon |
  |      |
   \    /
    \  /
     \/
```

Coordinate anchor equals SVG pointer tip.

---

## Zone Rendering

Pipeline:

```text
Geometry
    ↓
Curve Processor
    ↓
Projected Coordinates
    ↓
Canvas Layer
    ↓
Hit Detection Layer
```

---

# 7. Search Architecture

Local Search Index

```text
Marker Names
Zone Names
Category Names
Coordinates
```

Recommended:

* SQLite FTS5

---

# 8. Performance Architecture

## Virtualized Panels

Only visible rows rendered.

---

## Spatial Index

Use:

```text
RTree
```

for:

* Marker lookup
* Zone lookup
* Hit detection

---

## Geometry Cache

Cache:

* Projected coordinates
* Curve calculations
* Bounding boxes

---

# 9. Recommended Open Source Components

## Map Rendering

* flutter_map
* vector_map_tiles
* pmtiles

## Geometry

* turf_dart

## SVG

* flutter_svg

## Markdown

* flutter_markdown

## Search

* sqlite3
* FTS5

---

# 10. Deployment

## Desktop

* Flutter Desktop
* Embedded Serverpod Client

## Mobile

* Flutter Mobile

## Web

* Flutter Web
* Serverpod Backend

---

# 11. Future Architecture Extensions

* Multi-user editing
* Authentication
* Permission system
* Layer support
* Offline synchronization
* Version history
* Undo/redo event sourcing
* Terrain layers
* 3D visualization
* Route optimization

