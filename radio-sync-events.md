# Radio Sync Events — Design Proposal

### Status

Draft — design only. **Not ready for implementation.**

### Version

0.1

### Related domains

Wayfinder entities today: `MapMarker`, `MapZone` (including `type = evac_kit`), `WatchLogEntry`.  
Online sync today: full-object change streams (`created|updated|deleted|bulk`).  
Offline today: outbox with full `toJson()` payloads for a subset of mutations; field packs are bulk zip transfers (out of scope for radio).

---

## 1. Goal

Enable **small, bidirectional domain updates** between field clients and a retreat/server (and peer-to-peer in the field) over multiple radio transports, without shipping field packs or other large dumps.

Example operations:

- A lookout appends a watch-log entry
- A ranger creates or updates a map marker
- Someone updates an evacuation kit route on the fly
- Peers out of server Wi‑Fi/API range still receive those updates over mesh or digimode

## 2. Non-goals (v1)

- Full field packs, PMTiles, marker attachments, or media over the air
- Full marker inventory / weather / radio / checklist JSON blobs over the air
- Complex CRDTs
- Replacing Serverpod live streams for online clients
- Arbitrary GMRS digital networking (see §10); GMRS remains a constrained / voice-first option pending regulatory review

## 3. Design principle

**One event format, many transports.**

```text
UI / providers
      ↓
Domain Event API     (MarkerUpsert, LogAppend, EvacRouteUpsert, …)
      ↓
Binary Codec         (versioned frames, CRC, optional chunking)
      ↓
Transport Port       (send / receive opaque bytes)
      ↓
Adapters: Mesh | Ham digimode | Local outbox | Server bridge
     (| GMRS audio modem — only if permitted)
```

Application code must not couple to Meshtastic vs ham vs HTTP. Transports only move frames.

Prefer **compact binary** payloads. Do **not** send JSON over the air. Hex/Base64/Base91 are optional last-mile encodings for text-only channels; they are not the data model (hex roughly doubles size vs raw binary).

---

## 4. Frame format

All transports carry the same frame:

| Offset | Size | Field | Notes |
|--------|------|-------|-------|
| 0 | 2 | `magic` | `WF` (`0x57 0x46`) |
| 2 | 1 | `version` | Start at `1` |
| 3 | 1 | `flags` | bit0: chunked inner payload; bit1: ack-request; others reserved |
| 4 | 1 | `msgType` | See §5 |
| 5 | 16 | `eventId` | UUID; dedupe key |
| 21 | 16 | `entityId` | UUID of marker / zone / watch-log / kit zone |
| 37 | 4 | `revisedAt` | Unix seconds UTC (last-write-wins for upserts) |
| 41 | 2 | `payloadLen` | `uint16` big-endian |
| 43 | N | `payload` | Type-specific |
| 43+N | 4 | `crc32` | Over bytes `[0 .. 43+N)` |

### Encoding conventions

- Endianness: big-endian for multi-byte integers
- UUIDs: 16 raw bytes (not hex strings)
- Coordinates: `int32` degrees × `1e7` (~1 cm)
- Strings: length prefix (`uint8` or `uint16`) + UTF-8, with per-field maxima
- Unknown `version` / `msgType`: ignore (do not crash)
- CRC failure: drop (transport may retry)

### Chunking (`msgType = 0x7E`)

When a logical frame exceeds a transport MTU, set `flags.chunked` and send chunk envelopes:

```text
transferId[16] | seq:u16 | total:u16 | chunkData…
```

Reassemble, verify the inner frame CRC, then decode as usual. Evac route upserts are the most likely multi-chunk messages on mesh.

---

## 5. Event catalog (v1)

Air payloads are **operational subsets**, not full Serverpod `toJson()` documents.

### Markers

| Code | Event | Notes |
|------|-------|-------|
| `0x01` | `MarkerUpsert` | Slim marker create/update |
| `0x02` | `MarkerDelete` | Soft-delete; payload may be empty |

**`MarkerUpsert` payload (air-relevant):**

- `name` (max 40)
- `lat`, `lon` (`int32` e7)
- `elevation` optional (`int16` meters; omit if 0)
- `color` as packed RGB `uint32` (not hex string)
- `icon` as `uint8` dictionary id (known icon keys → ids) *or* short key — see open decisions
- `visible` bool
- `layerId` optional UUID
- `notes` optional max 80 (truncate flag if longer)
- `isTracking` bool

**Omit over air:** inventory, weather, radio, checklists, attachments.

### Generic zones (non–evac-kit)

| Code | Event | Notes |
|------|-------|-------|
| `0x03` | `ZoneUpsertLight` | Circle / simple polygon / line only |
| `0x04` | `ZoneDelete` | Soft-delete |

**`ZoneUpsertLight`:** name, type, colors, visibility, optional `layerId`, compact geometry:

- Circle: center e7 + `radiusMeters`
- Polygon / line: capped point list (e.g. ≤16 points in v1)

Do **not** use `ZoneUpsertLight` for `evac_kit` zones.

### Watch log

| Code | Event | Notes |
|------|-------|-------|
| `0x05` | `LogAppend` | Maps to `WatchLogEntry`; append-only over air |

**`LogAppend` payload:**

- `occurredAt` unix seconds
- `severity` `uint8` (`info` \| `notice` \| `warning` \| `critical`)
- `author` max 20
- `text` max 120–180 depending on MTU target
- optional `markerId`, `zoneId`

No `LogUpdate` / `LogDelete` over air in v1 (handle online).

### Evacuation kits (first-class)

Evac kits are `MapZone` rows with `type = evac_kit` and `EvacKitGeometry` (routes, waypoints, primary route, default mode, notes). They change under operational pressure and need dedicated events so a full multi-route geometry is not forced into one mesh frame.

| Code | Event | Notes |
|------|-------|-------|
| `0x10` | `EvacKitMetaUpsert` | Kit shell / metadata without full geometry |
| `0x11` | `EvacRouteUpsert` | Create or replace **one** route |
| `0x12` | `EvacRouteDelete` | Remove one route from a kit |
| `0x13` | `EvacKitDelete` | Soft-delete whole kit zone |

Frame `entityId` = **kit zone UUID** (`MapZone.id`).  
Route events also carry `routeId` (16-byte UUID; existing string route ids are UUID strings today).

**`EvacKitMetaUpsert`:**

- `name` (max 40)
- packed `color` / `borderColor` / `fillColor`
- `visible`, optional `layerId`
- `primaryRouteId` (16 bytes)
- `defaultMode` `uint8` (transportation mode)
- `showNameLabel` bool
- optional `notes` max ~80 (truncate flag)

**`EvacRouteUpsert` (hot path for field edits):**

- `routeId` (16)
- `name` max 32
- `role` `uint8` (`primary` \| `alternate`)
- optional route `color`, `borderPattern`, `showArrows`, `pathMode` (`straight` \| `smooth`)
- `waypointCount` + waypoints:
  - `kind` (`marker` \| `point` \| `control`)
  - `lat` / `lon` e7
  - optional `markerId` (16) for `marker` kind
  - optional `label` max 20

**Air caps (v1 proposal):**

- Max **24** waypoints per `EvacRouteUpsert` (including control points)
- Max **4** routes maintained via radio without requiring online sync for that kit
- Over cap → chunked transfer and/or online-only for that edit; meta + primary change can still go over air

**`EvacRouteDelete`:** `routeId` only. If deleted route was primary, fall back to first remaining valid route or mark kit pending.

**Apply notes:**

- Meta upsert merges into existing geometry (does not wipe routes)
- Route upsert replaces one route by id; require ≥2 waypoints to accept
- Meta before any route: allow shell kit; render when a valid primary route exists
- Unknown `markerId` on a waypoint: keep lat/lon and degrade kind to `point` (same spirit as current client parser)

### Control / utility

| Code | Event | Notes |
|------|-------|-------|
| `0x06` | `EventAck` | Optional; `ackedEventId` + status |
| `0x7E` | `Chunk` | Reassembly envelope |
| `0x7F` | `Hello` | Peer announce: unit id, schema version |

### Deferred

Seasonal overlays, full GPS track polylines, attachments, inventory/weather blobs.

### Catalog priority

1. `LogAppend`, `MarkerUpsert` / `MarkerDelete`
2. `EvacKitMetaUpsert`, `EvacRouteUpsert` / `EvacRouteDelete`, `EvacKitDelete`
3. `ZoneUpsertLight` / `ZoneDelete`
4. Ack / Hello

---

## 6. Codec and apply rules

### Detection and reliability (above the modem)

Binary carries data. Reliability is layered:

1. **CRC** on every frame (detect corruption)
2. **Chunking + optional erasure coding** for multi-frame transfers (repair loss)
3. **ARQ / retry** at the transport or outbox layer (retransmit missing pieces)
4. **Idempotent apply** so duplicates from retries are safe

Digimodes and mesh firmwares may add their own FEC; application framing still needs CRC, sequencing, and idempotent apply.

### Apply semantics

| Event class | Rule |
|-------------|------|
| Marker / zone / evac meta upserts | Last-write-wins on `revisedAt` (seconds). Ignore if local entity is newer. |
| `EvacRouteUpsert` | Replace that route if event is accepted; treat event time as the revision for that replace |
| `LogAppend` | Insert if `eventId` / entity id unseen; never merge text |
| Deletes | Soft-delete (`deletedAt`); ignore if already deleted |
| Duplicate `eventId` | Ignore |

Truncation: if notes/text exceed maxima, set a payload `truncated` flag so UI can indicate partial radio content.

### Server / gateway apply

Retreat gateway decodes events and calls existing Serverpod endpoints (`mapMarker`, `mapZone`, `watchLog`, etc.) with **upsert / create-if-absent** behavior keyed by UUID so mesh retries do not create duplicates.

---

## 7. Transport port

Conceptual interface:

```text
send(frameBytes, { priority, wantAck, ttl })
onReceive(frameBytes, { transportId, rssi?, fromPeer? })
capabilities() -> { maxPayload, reliable, bidirectional, mtu }
```

### Adapters

| Adapter | Role |
|---------|------|
| `ServerBridgeTransport` | Online: map events ↔ create/update APIs and/or change streams |
| `MeshTransport` | Meshtastic / MeshCore raw packets |
| `HamAudioTransport` | Digimode modem frames (same bytes; smaller MTU, more chunking) |
| `LocalOutboxTransport` | Persist unsent events (evolution of today’s offline outbox) |
| `GmrsAudioTransport` | Optional; only if legally and technically validated |

### Runtime preference (example)

1. Server HTTP / WebSocket if reachable  
2. Mesh if linked  
3. Ham digimode if configured  
4. Store-and-forward until any path works  

The retreat gateway is the natural bridge: `mesh ↔ Wayfinder server ↔ ham digimode`.

---

## 8. Mapping to current Wayfinder code

| Today | This design |
|-------|-------------|
| `MapMarkerChange` / `MapZoneChange` / `WatchLogEntryChange` full objects | Remain for online streams; radio uses slim events |
| Offline outbox `{ type, payload: toJson }` | Evolve toward same `msgType` + binary codec (dual-write acceptable during migration) |
| Field packs | Unrelated bulk path; keep separate |
| Evac kits via `MapZone` + `EvacKitGeometry` | First-class radio events `0x10`–`0x13` |
| Providers / dialogs mutating markers, zones, watch log, evac kits | Later: emit domain events into a sync controller when radio mode is enabled |

Suggested future package home (when implementing):  
`wayfinder_flutter/lib/features/radio_sync/`  
and/or a shared package if the server gateway must share the codec.

---

## 9. Consistency model

- **Online + radio:** server is system of record; gateway translates both directions
- **Radio-only field mesh:** peers converge via LWW (upserts) and append (logs); when any node reaches the gateway, events flush upward; gateway may echo latest state back out
- **Conflicts:** last `revisedAt` wins for markers/zones/evac meta; logs are append-only; route upsert replaces one route at a time

---

## 10. Security, trust, and spectrum notes

- Frame CRC is integrity against corruption, not authentication
- Mesh channel keys / hop limits are transport concerns
- Optional later: payload HMAC with a pre-shared team key (`flags` bit)
- Include `senderUnitId` (Hello or payload) for allowlists
- **Ham:** licensed operation, identification, and content rules apply; no secret encryption to obscure meaning where prohibited
- **GMRS (US Part 95):** primarily a voice service; do not assume arbitrary digital event networking is permitted. Prefer mesh/ham for data; use GMRS for voice coordination unless counsel/rules clearly allow a specific data method

---

## 11. Phased delivery (when ready to implement)

| Phase | Work |
|-------|------|
| **A** | Design lock (this document) |
| **B** | Codec + in-process loopback; unit tests for CRC, dedupe, LWW, evac route merge |
| **C** | Outbox stores binary events; flush to server when HTTP available |
| **D** | Mesh adapter; bidirectional marker + log + evac meta/route |
| **E** | Ham digimode adapter (chunking-heavy) |
| **F** | `ZoneUpsertLight` + gateway rebroadcast polish |

No implementation work is implied by accepting this draft.

---

## 12. Open decisions (lock before coding)

1. Icon representation: fixed `uint8` dictionary vs short ASCII icon key  
2. `ZoneUpsertLight` v1 scope: circle-only first vs polygon/line ≤16 points  
3. Shared codec package vs Flutter-first  
4. `revisedAt` seconds vs milliseconds (seconds save space; ms reduce ties)  
5. Evac air caps: confirm 24 waypoints / 4 routes  
6. Route id encoding: always 16-byte UUID (current string ids are UUID strings)  
7. Whether radio deletes are soft-only (recommended: yes)  
8. GMRS: explicitly in or out of supported adapters for v1

---

## 13. Summary

Design Wayfinder radio sync around **versioned binary domain events** with a stable frame and CRC, slim payloads for markers, watch-log entries, light zones, and **first-class evacuation kit meta/route updates**, plus a **transport port** so mesh and ham (and later other audio paths) are adapters. Keep field packs and rich nested marker blobs off the air. Implement only after this proposal is reviewed and the open decisions in §12 are closed.
