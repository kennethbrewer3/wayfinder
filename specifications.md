# Offline PMTiles Map Management System

## Software Requirements Specification (SRS)

### Version

1.0

### Status

Draft

### Author

Kenneth Brewer

---

# 1. Introduction

## 1.1 Purpose

The purpose of this application is to provide a completely offline map management system built with Flutter and Serverpod.

The system shall allow users to:

* View offline maps from PMTiles files.
* Navigate to locations using URL parameters.
* Search for locations.
* Create, edit, and organize map markers.
* Create and manage map zones.
* Display measurement information using multiple unit systems.
* Organize markers and zones using list and tree views.
* Operate without Internet connectivity after map data has been downloaded.

---

# 2. Goals

## Primary Goals

* Fully offline operation
* Cross-platform support
* High-performance rendering
* Scalable to thousands of markers and zones
* Support large PMTiles datasets
* Smooth interaction on desktop and mobile devices

---

# 3. Functional Requirements

## 3.1 Offline Map Viewing

### FR-MAP-001

The system shall support rendering maps from PMTiles files.

### FR-MAP-002

The system shall operate without Internet access after PMTiles files have been installed.

### FR-MAP-003

The system shall support:

* Mouse wheel zoom
* Touch pinch zoom
* Keyboard zoom shortcuts

### FR-MAP-004

The system shall support drag-to-pan navigation.

### FR-MAP-005

The system shall preserve map position and zoom level between sessions.

---

## 3.2 URL Navigation

### FR-NAV-001

The system shall support URL parameters:

```text
/maps?lat=38.8951&lng=-77.0364&zoom=12
```

### FR-NAV-002

The system shall automatically move the map to the specified coordinates.

### FR-NAV-003

The system shall update the browser URL when map position changes.

---

## 3.3 Search

### FR-SEARCH-001

The system shall provide a search box.

### FR-SEARCH-002

Search shall support:

* Marker names
* Zone names
* Coordinates

### FR-SEARCH-003

Selecting a search result shall zoom to the selected object.

---

## 3.4 Map Markers

### FR-MARKER-001

Users shall create markers using:

* Right-click context menu
* Radial menu

### FR-MARKER-002

Markers shall contain:

| Field            | Required |
| ---------------- | -------- |
| Name             | Yes      |
| Notes (Markdown) | No       |
| Color            | Yes      |
| Icon             | Yes      |
| Latitude         | Yes      |
| Longitude        | Yes      |

### FR-MARKER-003

Marker notes shall support Markdown formatting.

### FR-MARKER-004

Markers shall use a custom SVG icon.

### FR-MARKER-005

The SVG pointer tip shall align precisely with the marker coordinates.

### FR-MARKER-006

Users shall edit markers after creation.

### FR-MARKER-007

Users shall delete markers.

### FR-MARKER-008

Users shall toggle marker visibility.

---

## 3.5 Map Zones

### Supported Zone Types

### FR-ZONE-001

Radial Zone

### FR-ZONE-002

Rectangle Zone

### FR-ZONE-003

Polygon Zone

### FR-ZONE-004

Line Zone

---

### Zone Properties

Each zone shall support:

| Property       |
| -------------- |
| Name           |
| Description    |
| Color          |
| Border Color   |
| Border Width   |
| Border Pattern |
| Fill Color     |
| Visibility     |
| Notes          |

---

### Border Patterns

Supported border patterns:

* Solid
* Dashed
* Dotted
* Dash-Dot

---

### Curved Geometry

### FR-ZONE-010

Polygon and line edges shall support bezier curves.

### FR-ZONE-011

Users shall create and manipulate control points.

### FR-ZONE-012

Curves shall update interactively.

---

## 3.6 Directional Lines

### FR-LINE-001

Line zones shall support directional arrows.

### FR-LINE-002

Arrow spacing shall be configurable.

### FR-LINE-003

Arrow direction shall be reversible.

### FR-LINE-004

Arrow visibility shall be configurable.

---

## 3.7 Measurements

### FR-MEASURE-001

Display measurements in:

* Metric
* Imperial
* Nautical

### FR-MEASURE-002

Displayed values shall include:

* Distance
* Radius
* Perimeter
* Area

### FR-MEASURE-003

Line zones shall display total path length.

---

## 3.8 Marker and Zone Panels

### FR-PANEL-001

Provide a unified side panel.

### FR-PANEL-002

Display:

* Map Markers
* Map Zones

### FR-PANEL-003

Support sorting markers by:

* Name
* Hue
* Icon

### FR-PANEL-004

Support sorting zones by:

* Name
* Hue
* Type

### FR-PANEL-005

Support visibility toggles.

### FR-PANEL-006

Support delete actions via trash-can icon.

### FR-PANEL-007

Selecting an item shall zoom to the object.

---

## 3.9 Tree View

### FR-TREE-001

Users shall switch between:

* List View
* Tree View

### FR-TREE-002

Tree View shall support:

* Categories
* Subcategories
* Nested Groups

### FR-TREE-003

Dragging items shall allow hierarchy reorganization.

---

## 3.10 Categories

### FR-CAT-001

Markers may belong to categories.

### FR-CAT-002

Zones may belong to categories.

### FR-CAT-003

Categories may contain child categories.

---

# 4. Non-Functional Requirements

## Performance

### NFR-001

Map movement shall remain responsive at 60 FPS.

### NFR-002

The system shall support:

* 10,000+ markers
* 5,000+ zones

without noticeable UI lag.

### NFR-003

Rendering updates shall complete within 100ms.

---

## Reliability

### NFR-004

All edits shall be saved automatically.

### NFR-005

The system shall recover from unexpected shutdowns.

---

## Portability

### NFR-006

Supported platforms:

* Web
* Windows
* macOS
* Linux
* Android
* iOS

---

## Offline Requirements

### NFR-007

No external network calls shall be required after installation.

### NFR-008

All search indexes shall be stored locally.

---

# 5. Future Enhancements

* GPX import/export
* KML import/export
* GeoJSON import/export
* Route planning
* Elevation profiles
* Layer management
* Multi-user synchronization
* Real-time collaboration
* Terrain rendering
* 3D map support

