# v0.125 Implementation Report

Implemented:

- Added `npm run godot:audit:player-slice`.
- Added `tools/godot/auditGodotPlayerSliceWindows.ps1`.
- Added v0.125 screenshot audit, issue ledger, before/after manifest, and README generation.
- Added deterministic per-capture player-shell status in the screenshot manifest.
- Hid battle HUD/minimap chrome on title, briefing, and Results.
- Replaced engineering title copy with player-facing Salto review copy.
- Changed player-facing selected-entity HUD feedback to human-readable labels instead of raw IDs.
- Expanded the procedural terrain plane and supporting bands to reduce gray margins.
- Strengthened Results text separation while keeping the same placeholder-only scene.

Not implemented by design:

- Final artwork.
- Generated images.
- Imported artwork.
- Runtime art integration.
- Gameplay-rule changes.
- Browser-runtime changes.
- No save or localStorage changes.
- Stable-ID changes.
- Final Godot selection.
- Full desktop port.
- v0.126 work.
