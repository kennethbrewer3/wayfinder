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
| Home | Jump to your saved home location |
| Book | Open this user manual |
| Gear | Open Settings |

---

## The map

### Pan and zoom

- **Drag** the map to pan.
- **Scroll** or pinch (trackpad/touch) to zoom.
- The current viewport is reflected in the browser URL as `?lat=&lng=&zoom=` so you can bookmark or share a map view.

### Cursor coordinates

While the pointer is over the map, latitude and longitude appear in a small overlay. Use this when placing objects precisely.

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

Selecting a coordinate result places a temporary pin on the map. You can save it as a marker from the pin or details flow.

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

## Markers

Markers are point locations with a name, icon, color, optional elevation, and notes.

### Create a marker

**Long-press** (or right-click on desktop) on the map to open the **radial menu**, then choose **Add marker**. Alternatively, create from a search coordinate pin.

In the marker form:

- **Name** — required label shown on the map and in search.
- **Icon** — pick from the built-in icon set (map pins, shelters, water, and more).
- **Color** — marker color on the map.
- **Layer** — which layer owns this marker.
- **Elevation** — optional height in your chosen units.
- **Notes** — rich text stored as Markdown (links, lists, and basic formatting supported).

### Edit or view a marker

Tap a marker on the map or choose it from the sidebar. The details dialog shows coordinates, notes, and actions:

- **Edit** — change any field.
- **Copy coordinates** — to the clipboard.
- **Share link** — copies a URL that opens the map centered on this marker (`?marker=<uuid>`).
- **Delete** — remove the marker.

---

## Lines

Lines are polylines drawn on the map — useful for trails, boundaries, or measured paths.

### Draw a line

1. Long-press the map → **Draw line**.
2. Tap additional points along the path. Points snap to nearby geometry when close.
3. Open the line form to set name, color, layer, and notes.
4. Distance labels and direction arrows can appear along the line depending on settings.

### Edit a line

With a line selected or in edit mode:

- **Tap** the map to add a vertex.
- **Drag** a vertex to move it.
- **Long-press** a vertex to remove it (a banner explains controls while editing).

Line length is shown using your configured **measurement units** (metric or imperial).

### Bearing plot

From a line endpoint you can start a **bearing plot**: specify a bearing (true or relative) and distance to visualize a ray from that point. Useful for navigation exercises and sight lines.

---

## Circles

Circles represent a radius around a center point.

### Draw a circle

1. Long-press → **Draw circle**.
2. Tap to set the center, then tap again (or drag) to set the radius.
3. Complete the form with name, color, fill opacity, layer, and notes.

The map can display the radius with a **size label** (diameter, radius, area, or circumference — configurable in **Settings → General**).

---

## Rectangles

Rectangles are axis-aligned or rotated boxes defined by center and dimensions, or by two opposite corners.

### Draw a rectangle

Long-press the radial menu offers:

- **Rectangle (center)** — tap center, then define size and bearing in the form.
- **Rectangle (corners)** — tap two opposite corners on the map.

Size labels can show width, height, area, or perimeter depending on display settings.

---

## Long-press radial menu

Long-press (hold) on empty map space to open the radial menu. Available actions include:

| Action | Result |
|--------|--------|
| Add marker | New marker at this location |
| Draw line | Start line drawing |
| Draw circle | Start circle drawing |
| Rectangle (center) | Start center-based rectangle |
| Rectangle (corners) | Start corner-based rectangle |
| Copy coordinates | Copy lat/lng to clipboard |

Cancel by tapping outside the menu or pressing Escape where supported.

---

## Sharing and deep links

### Viewport links

When you pan and zoom, the URL updates with `lat`, `lng`, and `zoom`. Share that URL so others open the same map view.

### Marker links

Select a marker and use **Share link** in the details dialog. The URL includes `?marker=<uuid>` so the recipient’s map opens on that marker.

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

### Map debug (advanced)

Optional overlays for troubleshooting:

- Viewport debug border
- Tile borders
- Copy debug info to clipboard

Leave these off during normal use.

---

## Settings — Map tiles

PMTiles are compressed vector map archives. Wayfinder renders them locally for offline-capable basemaps.

### Storage path

The server stores uploaded `.pmtiles` files in a folder path configured here (usually set once by your administrator). All clients use the same library after upload.

### Upload tiles

1. Tap **Upload** and choose a `.pmtiles` file from your device.
2. Wait for upload and processing to finish (large files take time).
3. Enable the archive with the toggle. Multiple archives can be enabled; they composited on the map.

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

Backup exports all **layers, markers, and zones** from the Wayfinder server as a single JSON file.

### Export

Tap **Export** to download `wayfinder-backup-<timestamp>.json`. Store it safely.

### Restore

Tap **Restore**, select a backup file, and confirm. **Restore replaces all existing map objects** on the server with the backup contents.

Backup does **not** include PMTiles files or geocoding database contents — export those separately from their respective settings tabs.

---

## Settings — About

The About tab shows:

- App name, version, and build information
- Git commit and build time (when available)
- Platform and package name
- Configured server and geocoding URLs
- Deployment notes for Docker-based installs

Use this information when reporting bugs or verifying you are on the expected build.

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
| Share marker | Marker details → Share link |
| Backup data | Settings → Backup → Export |
| Add map tiles | Settings → Map tiles → Upload |
| Enable address search | Settings → Geocoding → import housenumbers |
| Change units | Settings → General → Measurement units |

---

*This manual corresponds to the Wayfinder application family. Server and geocoding features require compatible server versions deployed alongside the client.*
