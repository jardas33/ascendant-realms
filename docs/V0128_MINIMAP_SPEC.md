# v0.128 Minimap Spec

v0.128 upgrades the Godot Salto player-slice minimap from a simple orientation frame into a compact authored placeholder map. It is still procedural Control geometry only.

## Required Markers

- Salto terrain outline.
- Main road cue.
- Water and ford cues.
- Friendly cluster marker.
- Hostile pressure marker.
- Hero marker.
- Current objective marker.
- Quarry marker.
- Shrine and mine markers.
- Lume endpoints and connecting link.
- Camera viewport indicator.

## Interaction Posture

Click-to-orient is recorded as safe for the bounded spike. It does not add a broad new camera-control system.

## Constraints

- No giant empty minimap frame.
- No debug rectangles or raw IDs.
- No imported art, generated imagery, final UI art, save changes, stable-ID changes, browser-runtime changes, final Godot decision, or full port.
