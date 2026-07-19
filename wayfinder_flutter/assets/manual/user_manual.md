# Wayfinder User Manual

Welcome to **Wayfinder** — a map application for planning, marking, and measuring locations on your own offline vector maps. This manual describes every major feature so you can get productive quickly and troubleshoot common issues.

Wayfinder stores your markers, lines, circles, and rectangles on a **Wayfinder server** you connect to. Map tiles (PMTiles) and geocoding data can also be managed through optional dedicated servers.

---

## Getting started

### What you need

1. **Wayfinder app** — runs in a web browser or as a desktop/mobile build.
2. **Wayfinder server** — stores layers, markers, and zones. Configure its URL in **Settings → General**.
3. **PMTiles map archive(s)** — optional but recommended. Without enabled tiles the map shows a placeholder until you upload or configure tiles in **Settings → Map tiles**.
4. **Geocoding server** — optional. Enables place-name and street-address search when configured in **Settings → Geocoding**.

### First launch checklist

1. Open **Settings** (gear icon on the map) → **General**.
2. Enter your **server URL** (the address where the Wayfinder API is reachable from your device).
3. Set a **home location** (latitude, longitude, zoom) and tap **Save home location**.
4. Go to **Map tiles**, confirm the storage path if prompted, and **upload** at least one `.pmtiles` file. Enable it for the map.
5. Optionally configure a **geocoding server URL** under **Geocoding** if you want address search.
6. Return to the map. Pan and zoom to confirm tiles load (watch the layers icon in the app bar).

### App bar icons (left to right)

| Icon | Purpose |
|------|---------|
| Search field | Find markers, zones, coordinates, and geocoded places |
| Status dot (geocoding) | Shows whether place/address search indexes are ready |
| Layers | PMTiles load progress and enabled tile list |
| Grid | Toggle MGRS grid overlay |
| My location | Show GPS “you are here” (long-press to hide) |
| Home | Jump to your saved home location |
| PDF | Export a printable map atlas of the current view |
| Book | Open this user manual |
| Gear | Open Settings |

---

## The map

### Pan and zoom

- **Drag** the map to pan.
- **Scroll** or pinch (trackpad/touch) to zoom.
- The current viewport is reflected in the browser URL as `?lat=&lng=&zoom=` so you can bookmark or share a map view.

### Cursor coordinates

While the pointer is over the map, a small readout appears **above** the cursor. It shows latitude/longitude by default. When the **MGRS grid** is enabled, the readout shows the Military Grid Reference System coordinate instead (precision follows zoom). If an offline **elevation DEM** pack is enabled, the readout also appends spot elevation.

### My location (GPS)

Tap the **my location** button (crosshair) in the map app bar to show a blue **you are here** dot from this device’s GPS / browser geolocation.

- **No internet is required** for positioning — the OS or browser reads satellites (and related sensors) locally. Wayfinder only plots those coordinates on your offline PMTiles map.
- The map **follows** your position until you pan or zoom; tap the button again to re-center and resume following.
- **Long-press** the button to hide the blue dot and stop tracking.
- An accuracy circle appears when the device reports a useful accuracy radius.
- A **status card** (bottom-left) shows your position as lat/lng, or as **MGRS** when the MGRS grid is on, plus magnetic variation (WMM2025). If a **marker is selected**, it also shows distance and bearing to that marker (true or magnetic per Settings → Bearings), with a dashed guide line on the map.
- **Web note:** browsers only allow geolocation in a [secure context](https://developer.mozilla.org/en-US/docs/Web/Security/Secure_Contexts) — `https://…` or `http://localhost`. Plain `http://192.168.x.x` usually blocks location. Serve the client behind HTTPS on the LAN if you need GPS in the browser (see the client deploy guide). Native Android/iOS/macOS builds use system location APIs and do not need HTTPS for GPS.

### MGRS grid

Wayfinder can overlay a true **MGRS** (Military Grid Reference System) grid on the map. Toggle it from the map toolbar (grid icon) or **Settings → General → Map display → Show MGRS grid**.

MGRS is based on the **UTM** projection, not on simple latitude/longitude squares:

- **At wide / low zoom**, the overlay shows **Grid Zone Designator (GZD)** lines — 6° longitude zones and latitude bands. Those lines follow meridians and parallels, so they look straight on the Web Mercator basemap.
- **When you zoom in**, the overlay draws the real **UTM easting/northing** squares used by MGRS (100 km, 10 km, 1 km, and finer as the view tightens). Labels sit at the center of each visible square.
- **Zone boundaries are seams.** Adjacent UTM zones use different axes, so grid lines from neighboring zones do **not** meet in a continuous rectangle. That discontinuity is correct MGRS, not a map bug.
- **Lines may look slightly curved** on this map. UTM grid lines are straight in UTM space; Wayfinder’s basemap uses **Web Mercator**, so true MGRS lines can bend a little when drawn on screen—especially across a tall north–south span.

You can also **search** for an MGRS string (compact or spaced, e.g. `18SUJ23480647` or `18S UJ 23480 647`) and view/copy MGRS on marker details.

### Responsive layout

- **Wide screens (960 px and up):** the **Map Objects** sidebar appears on the right.
- **Narrow screens:** the sidebar collapses to a bottom panel. Use the expand control to show the full list.

### No map tiles?

If no PMTiles archives are enabled, the map area shows a placeholder with a link to **Settings → Map tiles**. The app still works for markers and zones; you simply will not see a basemap until tiles are configured.

---

## Search

The search bar at the top of the map finds several kinds of results:

### Your map objects

- **Markers** and **zones** (lines, circles, rectangles) whose names match your query.
- Selecting a result pans the map to that object and opens its details where appropriate.

### Coordinates

Enter coordinates in common formats, for example:

- `38.8951, -77.0364`
- `38.8951 -77.0364`
- MGRS: `18SUJ23480647` or `18S UJ 23480 647`

Selecting a coordinate or MGRS result places a temporary pin on the map. You can save it as a marker from the pin or details flow.

### Geocoded places and addresses

When a geocoding server is configured and its search indexes are ready (green status in the app bar), search also returns:

- **Places** — towns, landmarks, and other named locations from imported OSMNames data.
- **Addresses** — house number + street matches when housenumber data has been imported.

Tap the geocoding status icon for details on index build progress.

---

## Map objects sidebar

The sidebar lists everything on your map, organized by **layers**.

### Layers

Layers group markers and zones. Each layer can be shown or hidden independently.

- **Create layer** — add a new empty layer.
- **Rename / delete** — manage existing layers (deleting removes objects in that layer).
- **Reorder** — change draw order and list order.
- **Visibility** — toggle the eye icon to show or hide a layer on the map.
- **Active layer** — new markers and zones are created on the active layer.

### List and tree views

Switch between a flat list and a tree grouped by layer. Sort markers and zones by name or other fields.

### Object actions

For each marker or zone you can typically:

- **Show/hide** on the map
- **Zoom to** — center the map on the object
- **Edit** — open the form dialog
- **Delete** — remove permanently

Use the sidebar search filter (linked to the main search bar) to narrow a long list.

---

## Live updates across clients

Wayfinder keeps an open connection to the server. When any client creates, edits, or deletes a **marker**, **line/circle/rectangle/track (zone)**, or **layer**, other open browsers and apps refresh that data automatically — no page reload required.

## Markers

Markers are point locations with a name, icon, color, optional elevation, and notes.

### Create a marker

**Long-press** (or right-click on desktop) on the map to open the **radial menu**, then choose **Add marker**. Alternatively, create from a search coordinate pin.

In the marker form:

- **Name** — required label shown on the map and in search.
- **Icon** — pick from the built-in icon set (map pins, shelters, water, and more).
- **Color** — marker color on the map.
- **Coordinates** — latitude and longitude (editable when creating or editing).
- **Layer** — which layer owns this marker.
- **Tracking marker** — optional; records movement history as a trail (see below).
- **Transportation** — when tracking is enabled, choose how the marker moves. Options align with common APRS mobile symbols. Each mode renders a distinct **trail style** on the map (footprints, tread, road lane, railroad, wake, flight path, or balloon drift).
- **Elevation** — optional height in your chosen units.
- **Notes** — rich text stored as Markdown (links, lists, and basic formatting supported).

### Edit or view a marker

**Tap** a marker or zone on the map to select it. Selected markers grow slightly and show a colored ring so the choice is obvious; the selected marker also drives GPS distance/bearing in the location HUD. **Long-press** a marker or zone to open its details dialog (or use the sidebar edit control).

### Connect markers with a line (waypoints)

With one marker already selected, **long-press a different marker** to create a **line zone** between them. The line form opens with endpoints set to those two pins. After you save, the destination marker stays selected so you can chain another segment (A → B → C). Long-pressing the same selected marker (or long-pressing with none selected) still opens details.

Marker details show coordinates, notes, and actions:

- **Edit** — change any field.
- **Copy coordinates** — to the clipboard.
- **Share link** — copies a URL that opens the map centered on this marker (`?marker=<uuid>`).
- **QR code** — shows a scannable QR of the marker link with the Wayfinder favicon in the center. You can save it as a PNG image or SVG vector (QR modules are vector; the favicon is embedded as PNG).
- **Delete** — remove the marker (also removes its associated track, if any).

### Tracking markers

A **tracking marker** records where the marker has moved over time. Each time the position changes by at least about **5 meters**, a new point is saved and a **trail** is drawn on the map behind the marker. This is useful for following a pet, person, or vehicle when coordinates are updated from the app or over the REST API.

**Turn tracking on or off**

1. Create or edit a marker.
2. Enable **Tracking marker** in the form and save.

When tracking is **off**, no new points are recorded, but **existing history is kept** in the database. Turn tracking on again to resume appending to the same trail.

**What you see on the map**

- The marker pin shows the current location.
- A colored **polyline** shows the path taken so far.
- **Styled trails** along the path indicate direction of travel. Each **Transportation** mode uses a distinct trail style (footprints, tire tread, road lane markings, railroad track, boat wake, contrail, or drifting balloon path).

**Transportation mode**

When **Tracking marker** is enabled, choose **Transportation** in the marker form:

| Mode | Trail style |
|------|-------------|
| On foot | Footprints |
| Horse | Hoof prints |
| Bicycle | Tire tread |
| Motorcycle | Single tire tread |
| ATV | Off-road tread |
| Land vehicle | Road lane / dashed centerline |
| Truck | Wide road lane |
| Bus | Wide road lane |
| Recreational vehicle | Wide road lane |
| Train | Railroad track |
| Ambulance | Road lane |
| Fire truck | Wide road lane |
| Farm vehicle | Tractor tread |
| Canoe | Wake trail |
| Watercraft | Wide wake trail |
| Sailboat | Light wake trail |
| Aircraft | Contrail / dashed flight path |
| Helicopter | Dashed path with hover rings |
| Glider | Smooth flight path |
| Balloon | Wavy drift path |

You can change the mode later by editing the marker (while tracking is on) or by editing the companion track in the sidebar. To set transportation mode from automation, update the track zone’s `geometryJson` field with `"transportationMode": "train"` (or any other mode key such as `onFoot`, `bike`, `motorcycle`, `bus`, `helicopter`, `sailboat`, and so on).

**Manage the trail separately from the marker**

Enabling tracking creates a companion **track** object in the sidebar (transportation icon, usually named “*marker name* track”). The marker and track can live on **different layers**:

| Goal | How |
|------|-----|
| Move the trail to another layer | Sidebar → select the track → **Edit track** → choose **Layer** |
| Hide the trail but keep the marker | Sidebar → track → **Hide** (visibility toggle) |
| Hide only the trail | **Edit track** → turn off **Show trail on map** |
| Change trail color, name, or transportation | **Edit track** |

Hiding or moving the track does **not** delete its history. Disabling **Tracking marker** on the marker also does **not** clear the trail.

**Update position from automation**

For GPS trackers, scripts, or integrations, use the REST API to move the marker. Each qualifying move extends the trail while tracking is enabled. See **Settings → About → REST API access** for your API key.

```bash
# Enable tracking on an existing marker
curl -X PATCH 'http://YOUR_SERVER:18082/api/markers/MARKER_UUID' \
  -H 'Content-Type: application/json' \
  -H 'X-API-Key: wf_your_key_here' \
  -d '{"isTracking":true}'

# Report a new position (trail updates when movement is ≥ ~5 m)
curl -X PATCH 'http://YOUR_SERVER:18082/api/markers/MARKER_UUID' \
  -H 'Content-Type: application/json' \
  -H 'X-API-Key: wf_your_key_here' \
  -d '{"latitude":38.91201,"longitude":-77.17357}'
```

---

## Lines

Lines are polylines drawn on the map — useful for trails, boundaries, or measured paths.

### Draw a line

1. Long-press the map → **Draw line**. The line starts at the long-press point, or at a **selected marker** if one is selected when you choose Draw line.
2. Move the pointer to the end point (preview follows; points snap to nearby geometry when close). **Double-tap** to place the end and open the line form. A short click or drag only adjusts the preview so you can reposition freely.
3. Set name, color, layer, and notes in the form.
4. Distance labels and direction arrows can appear along the line depending on settings.

### Select and edit a line

**Tap** a line to select it (details stay closed). **Long-press** the line to open its details dialog.

With a line selected:

- **Tap** the line again to add a mid-point (turns a straight segment into a curve).
- **Drag** an endpoint or mid-point to reposition it. When other line endpoints share the same coordinates, they move together so connected lines stay contiguous.
- **Double-tap** a mid-point to remove it (endpoints stay). Remove all mid-points to turn a curve back into a straight line.
- **Double-tap** an endpoint to start a bearing plot (so a single press can still begin a drag).

A banner on the map explains these controls while a line is selected.

Line length is shown using your configured **measurement units** (metric or imperial).

### Bearing plot

From a line endpoint you can start a **bearing plot**: specify a bearing (absolute or relative) and distance to visualize a ray from that point. Absolute bearings follow Settings → Bearings (true °T or magnetic °M). Useful for navigation exercises and sight lines.

### Dead reckoning / pace count

When GPS is denied or unreliable, estimate a new position from a known start using heading and distance (or paces).

1. Optionally **select a marker** (or enable GPS so the last fix can be used).
2. Long-press the map → **Pace count**.
3. Enter **bearing** (°T or °M per Settings → Bearings), then either:
   - **Paces** — pace count × pace length (meters per pace; remembered on this device), or
   - **Distance** — direct ground distance in your measurement units.
4. The map shows a preview leg to the estimated point.
5. **Place marker** drops a pin at the estimate, or **Create line** saves the leg as a line zone.

Start point priority: selected marker → current GPS fix → long-press location.

### Viewshed / RF line-of-sight

Estimate terrain-masked visibility from a lookout, repeater, mesh node, or any map point using DEM elevation (elevation-angle occlusion; no Fresnel clearance).

1. Optionally **select a marker** (lookouts / radio markers get a sensible default antenna height).
2. Long-press the map → **Viewshed**.
3. Adjust **antenna height** (AGL), optional **target height** (AGL), and **range**, then **Compute** (first run starts automatically).
4. The map shows a filled visible footprint and a dotted max-range ring. Cancel clears the overlay (it is not saved as a zone).

Requires DEM elevation data for the area. Observer ground and eye height are shown in the banner when available.

---

## Circles

Circles represent a radius around a center point.

### Draw a circle

1. Long-press → **Draw circle**. The center is the long-press point, or a **selected marker** if one is selected when you choose Draw circle.
2. Move to set the radius preview, then **double-tap** to place it.
3. Complete the form with name, color, fill opacity, layer, and notes.

The map can display the radius with a **size label** (diameter, radius, area, or circumference — configurable in **Settings → General**).

---

## Rectangles

Rectangles are axis-aligned or rotated boxes defined by center and dimensions, or by two opposite corners.

### Draw a rectangle

Long-press the radial menu offers:

- **Rectangle (center)** — center is the long-press point, or a **selected marker** if one is selected; then move to define size and **double-tap** to place.
- **Rectangle (corners)** — place the first corner, then move to the opposite corner and **double-tap** to place.

Size labels can show width, height, area, or perimeter depending on display settings.

---

## Long-press radial menu

Long-press (hold) on empty map space to open the radial menu. Available actions include:

| Action | Result |
|--------|--------|
| Add marker | New marker at this location |
| Draw line | Start line drawing (from selected marker when one is selected) |
| Pace count | Dead reckoning / pace-count helper |
| Viewshed | Terrain / RF line-of-sight from this point (or selected marker) |
| Draw circle | Start circle drawing (from selected marker when one is selected) |
| Rectangle (center) | Start center-based rectangle (from selected marker when one is selected) |
| Rectangle (corners) | Start corner-based rectangle |
| Copy coordinates | Copy lat/lng to clipboard |

Cancel by tapping outside the menu or pressing Escape where supported.

---

## Sharing and deep links

### Viewport links

When you pan and zoom, the URL updates with `lat`, `lng`, and `zoom`. Share that URL so others open the same map view.

### Marker links

Select a marker and use **Share link** or **QR code** in the details dialog. The URL includes `?marker=<uuid>` so the recipient’s map opens on that marker. From the QR dialog you can save a PNG or SVG of the code.

**Note:** Recipients need network access to your Wayfinder server and the same map data (tiles, markers) to see identical content.

---

## Settings — General

Open via the gear icon → **General** tab.

### Language

Choose **English**, **Spanish**, or **French** for the app interface. Some map drawing hints may remain in English.

### Appearance

- **Theme family** — color palette variants.
- **Brightness** — light, dark, or follow system.

Changing language may prompt an app restart.

### Server connection

- **Server URL** — base URL of the Wayfinder API (must be reachable from your browser or device).
- After changing the URL, save and confirm markers load on the map.

### Home location

Set latitude, longitude, and zoom for the **Home** button on the map. If no marker exists near home, a temporary home pin appears when you go home.

### Measurement preferences

- **Units** — metric or imperial for distances and areas.
- **Angle format** — degrees or mils for bearings.
- **Default circle size label** — what to show for circles (radius, diameter, area, etc.).

### Map display

- **Bearings** — display absolute bearings as **true north (°T)** or **magnetic north (°M)** using WMM2025 declination at GPS position or map center.
- **Compass rose** — show or hide the compass overlay (below instruction banners). **±5°** buttons rotate the map; **double-tap** the rose to reset rotation; **long-press** toggles true north (red **N**) vs magnetic north (blue **MN**). Variation uses WMM2025.
- **Show MGRS grid** — overlay true Military Grid Reference System lines (see [MGRS grid](#mgrs-grid) under **The map**). Spacing follows zoom; zone seams and slight curvature on Web Mercator are expected for correct MGRS.
- **Map zoom range** — optional min/max zoom limits for the map interaction range.

### Map debug (advanced)

Optional overlays for troubleshooting:

- Viewport debug border
- Tile borders
- Copy debug info to clipboard

Leave these off during normal use.

---

## Settings — Map tiles

PMTiles are compressed map archives. Wayfinder renders vector/raster basemaps locally, and can also sample **offline elevation (DEM)** packs for height readouts.

### Storage path

The server stores uploaded `.pmtiles` files in a folder path configured here (usually set once by your administrator). All clients use the same library after upload.

### Get maps (recommended)

Tap **Get maps** to import curated archives. The Wayfinder **server** downloads them into its storage (keep the dialog open until finished):

- **US state basemaps** — regional Protomaps vector extracts hosted by [Project NOMAD Maps](https://github.com/Crosstalk-Solutions/project-nomad-maps) (ODbL). Prefer these over a full-planet file.
- **Elevation DEM** — [Mapterhorn](https://mapterhorn.com/data-access/) Terrarium planet pack (named `mapterhorn-terrarium-z12.pmtiles` so Wayfinder treats it as DEM). It is large; for smaller areas, extract a region with the [`pmtiles extract`](https://docs.protomaps.com/pmtiles/cli#extract) CLI, then use **Upload**.

You can also build your own cutouts from the daily Protomaps planet at [maps.protomaps.com/builds](https://maps.protomaps.com/builds) using `pmtiles extract`.

### Upload tiles

1. Tap **Upload** and choose a `.pmtiles` file from your device (or a DEM extract you created offline).
2. Wait for upload and processing to finish (large files take time). On web, large archives upload in chunks so the UI and server logs show progress while data is transferring.
3. Enable the archive with the toggle. Multiple archives can be enabled; they composited on the map.

### Download / backup tiles

Use the **download** icon on each archive row to save a copy of that `.pmtiles` file (desktop/mobile picks a destination; web starts a browser download). Handy for backing up DEM packs and basemap archives stored on the server.

### Offline elevation (DEM)

Use **Get maps → Mapterhorn Terrarium**, or upload Terrarium / Mapbox Terrain-RGB height tiles packed as `.pmtiles`. Name the file so Wayfinder recognizes it as DEM — include one of: `dem`, `terrarium`, `terrain-rgb`, or `elevation` (for example `virginia-terrarium.pmtiles`).

- Enable the DEM archive with the toggle (listed with an **Elevation DEM** badge).
- DEM packs are **not** drawn as the basemap; they are sampled for height.
- With DEM enabled you get: **spot elevation** on the cursor readout, **climb to marker** in the GPS HUD when a marker is selected, and **Elevation profile** on line/track details.
- Avoid serving a single ~150 GB worldwide DEM over HTTP if Range requests stall; prefer a regional extract.

### Groups

Organize tile files into **groups** for easier management. Show or hide entire groups.

### Show / hide all

Quick toggles to enable or disable every archive without deleting files.

### Performance notes

- Very large archives may take noticeable time to load; watch the **layers** icon in the app bar.
- Web clients store tile bytes in browser storage; ensure sufficient disk space.

---

## Settings — Geocoding

Geocoding adds place-name and address search using a separate **geocoding server**.

### Geocoding server URL

Enter the web URL of your geocoding server (port **18182** in default deployments). Save the URL before importing data or adding custom locations.

### Custom locations

At the top of the Geocoding tab you can:

- **Add locations** manually (name, latitude, longitude, optional country and notes).
- **List, edit, and delete** your contributions and community-imported entries.
- **Export / import** contributions as JSON archives.
- **Crowdsource** — import community bundles or submit anonymous contributions (when enabled on the server).

Custom locations appear in search immediately and do not require OSM imports.

### OSM place import

Import named places from **OSMNames** datasets:

1. Choose a preset (sample, single country, full planet, or custom URL).
2. Tap **Download and import**. The server downloads a compressed TSV and loads matching rows into its database.
3. Monitor progress in the import panel. **Do not restart the server** during an active import.

**Country imports** still download the global OSMNames file (~1.4 GB compressed) but only load places for the selected country into the database — much faster than a full planet import.

**Full planet** imports every place (~23M rows) and can take many hours.

### Housenumbers (address) import

A separate housenumbers dataset enables street-address search. Import flow is similar to places; the file is also large. Place search and address search work independently — you can import one without the other.

### Archive export / import

Export imported geocoding data as JSON backups or transfer between servers. Use **Remove all** to clear places or housenumbers before a fresh import.

### Search readiness

After import, the geocoding server builds **trigram search indexes** on startup. Until indexes finish, the status indicator shows progress. Search uses these indexes for fast fuzzy matching.

---

## Settings — Backup

### Full backup

Backup exports all **layers, markers, zones, and custom marker icons** from the Wayfinder server as a `.zip` archive (legacy `.json` backups can still be restored).

#### Export

Tap **Export map data** to download `wayfinder-backup-<timestamp>.zip`. Store it safely.

#### Restore

Tap **Restore from backup**, select a backup file, and confirm. **Restore replaces all existing map objects** on the server with the backup contents.

Backup does **not** include PMTiles files or geocoding database contents — export those separately from their respective settings tabs.

### GPX / KML / GeoJSON

Use this section to exchange waypoints and paths with other mapping tools.

- **Import** — pick a `.gpx`, `.kml`, or `.geojson` file. Waypoints become markers; routes/tracks/LineStrings become lines. Features are added to the currently selected create layer when one is set. If the map already has markers or zones, you are asked to **Add to existing**, **Replace existing** (deletes all markers and zones first), or **Cancel**.
- **Export** — choose GPX, KML, or GeoJSON. Markers export as waypoints/points; lines and track paths export as tracks/LineStrings.

### Printable map atlas (PDF)

Use this when you need paper sheets if the phone dies. From the map, tap the **PDF** app-bar icon (or use **Settings → Backup → Export printable atlas**). Then choose:

- **Coverage** — current map view (approximate), or fit all visible markers
- **Sheet grid** — how many pages to tile the area into (with slight edge overlap)
- **Page size** — US Letter or A4 landscape
- Optional marker list on each sheet

The PDF includes an index overview plus one page per sheet with the **enabled PMTiles basemap** (rasterized from the same archives used on the map), markers, lines/tracks/circles/rectangles, scale bar, north arrow, and an approximate MGRS label for the sheet center. Sheets use a lat/lng grid by default; if the **MGRS grid** is enabled on the map when you export, the MGRS grid (and its labels) is drawn instead. Export can take a moment while tiles are rendered.

---

## Settings — About

The About tab shows:

- App name, version, and build information
- Git commit and build time (when available)
- Platform and package name
- Configured server and geocoding URLs
- Docker image metadata (when running from a container)
- **REST API access** — create, list, and remove named API keys

Use this information when reporting bugs or verifying you are on the expected build.

### REST API access

Wayfinder exposes a JSON REST API on the web server (port **18082** by default) under `/api`. Use it with `curl`, scripts, automation, or external tools.

**Protect the API**

1. Open **Settings → About → REST API access**.
2. Tap **Create API key**, enter a name for the app or device (for example “GPS tracker” or “Home automation”), and copy the key immediately — it is shown only once.
3. Create additional keys for other integrations. Each key works independently; removing one does not affect the others.
4. Optionally store a key under **Key on this device** so the Wayfinder app can use REST fallbacks (backup restore, settings sync).

When at least one key is configured (or an environment key is set on the server), every endpoint except `GET /api/` and `GET /api/health` requires the key in a request header:

- `X-API-Key: wf_…`, or
- `Authorization: Bearer wf_…`

**Manage keys**

| Action | How |
|--------|-----|
| Create a key for a new app | **Create API key** → enter application name |
| Revoke one integration | Tap **Remove** on that key’s row |
| Remove all stored keys | **Remove all keys** (environment keys are unchanged) |

Server administrators can also set `WAYFINDER_REST_API_KEY` in the server environment (useful for Docker installs before first login). That key cannot be removed from the app.

**Example — move a marker**

```bash
curl -X PATCH 'http://YOUR_SERVER:18082/api/markers/MARKER_UUID' \
  -H 'Content-Type: application/json' \
  -H 'X-API-Key: wf_your_key_here' \
  -d '{"latitude":38.91201,"longitude":-77.17357}'
```

**Example — tracking marker (enable trail, then report positions)**

```bash
curl -X PATCH 'http://YOUR_SERVER:18082/api/markers/MARKER_UUID' \
  -H 'Content-Type: application/json' \
  -H 'X-API-Key: wf_your_key_here' \
  -d '{"isTracking":true}'

curl -X PATCH 'http://YOUR_SERVER:18082/api/markers/MARKER_UUID' \
  -H 'Content-Type: application/json' \
  -H 'X-API-Key: wf_your_key_here' \
  -d '{"latitude":38.91201,"longitude":-77.17357}'
```

`PUT` and `PATCH` accept partial JSON bodies — only include fields you want to change. Markers, zones, layers, map-data backup/restore, and PMTiles management are all available over REST.

Server administrators can also set `WAYFINDER_REST_API_KEY` in the server environment (useful for Docker installs before first login).

---

## Troubleshooting

### Map does not load / “failed to load”

- Verify the **server URL** in Settings → General.
- Check that the server is running and reachable from your network (firewall, HTTPS, correct port).
- Open the browser developer console for network errors.

### No basemap / gray placeholder

- Upload and **enable** at least one PMTiles file in Settings → Map tiles.
- Wait for the layers indicator to show load complete.

### Markers or zones do not appear

- Confirm server URL and refresh the page.
- Check the sidebar layer visibility toggles.
- Ensure objects are on a visible layer.

### Geocoding search returns nothing

- Confirm geocoding server URL is saved.
- Tap the geocoding status icon — indexes may still be building.
- Verify places or housenumbers import **completed** successfully on the geocoding server.
- Custom locations work without OSM import if added manually.

### Geocoding server connection refused

- Ensure the geocoding stack is running (`docker compose up` on the geocoding host).
- Match the URL port to your deployment (default web port **18182**).
- Pull the latest geocoding server image after upgrades.

### Import stuck or failed

- Check geocoding server logs for errors.
- Cancel and retry after fixing disk space or network issues.
- For corrupted migration state, administrators may need to reset the geocoding database volume (see deployment documentation).

### Restore backup failed

- Ensure the JSON file is a valid Wayfinder backup exported from this app version family.
- Check server logs for validation errors.

### Shared marker link does not work

- Recipient must reach the same Wayfinder server.
- Marker UUID must still exist (not deleted).
- URL must include correct `marker` query parameter.

---

## Privacy and data

- Map objects you create are stored on **your Wayfinder server**, not on a shared public cloud operated by the app authors.
- Geocoding imports download public OSMNames datasets to **your geocoding server**.
- Crowdsource submission (when enabled) uploads anonymous contribution bundles to a git repository configured by the server operator.
- Review your server operator’s policies for retention and access control.

---

## Quick reference

| Task | How |
|------|-----|
| Go home | Home icon in app bar |
| Open manual | Book icon in app bar |
| Open settings | Gear icon in app bar |
| Create marker | Long-press map → Add marker |
| Draw line / shape | Long-press map → choose tool |
| Search | Type in app bar search field |
| Share marker | Marker details → Share link or QR code |
| Tracking marker | Marker edit → Tracking marker; manage trail in sidebar (track) |
| Backup data | Settings → Backup → Export |
| Print map sheets (PDF) | Settings → Backup → Export printable atlas |
| Offline elevation DEM | Settings → Map tiles → enable `*dem*` / `*terrarium*` pack |
| Path elevation profile | Line/track details → Elevation profile |
| Script with curl | Settings → About → REST API access → generate key |
| Add map tiles | Settings → Map tiles → Upload |
| Enable address search | Settings → Geocoding → import housenumbers |
| Change units | Settings → General → Measurement units |
| Toggle MGRS grid | Map toolbar grid icon, or Settings → General → Map display |
| Search MGRS | Search bar — paste a grid reference (e.g. `18S UJ 23480 647`) |
| Show my GPS location | Map toolbar my-location icon (long-press to hide) |

---

*This manual corresponds to the Wayfinder application family. Server and geocoding features require compatible server versions deployed alongside the client.*
