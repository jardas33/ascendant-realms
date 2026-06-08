# v0.165 Duplicate Render Audit

Status: `PASS_V0165_DUPLICATE_RENDER_AUDIT`

## Instrumentation

The Godot scene now reports `v0165VisualHardeningAudit` in player-slice status and benchmark output. It records:

- visual-node counts by current scene
- unit visual entries by entity
- procedural-visible count
- generated-art visible count
- fallback-visible count
- marker/ring visible count
- draw-node creation count
- texture load count
- material create/reuse count
- image decode count
- metadata parse count
- per-frame decode count
- per-frame metadata parse count
- accidental procedural overlay count

## Expected Result

Loaded Worker and Militia billboard roots use `QuadMesh` and do not receive procedural child silhouette parts. Remaining procedural visuals are other units, terrain, structures, health bars, selection rings, objective markers, and fallback cases.

## Gate

The gate passes only when:

- `accidentalProceduralOverlayCount` is zero in M3.
- `validatedArtReplacesProceduralVisual` is true.
- `perFrameDecodeCount` is zero.
- `perFrameMetadataParseCount` is zero.
- M4 and M5 keep Worker and Barracks loaded while Militia returns to procedural fallback.

Evidence:

- `artifacts/desktop-spikes/godot-salto/v0165/audit/v0165-duplicate-render-audit.json`

## Result

M3 reports `accidentalProceduralOverlayCount: 0`, `perFrameDecodeCount: 0`, and `perFrameMetadataParseCount: 0` across the captured validation snapshots. The original first-frame overlap defect was repaired by immediately removing old visual-root children before rebuilding opt-in billboard nodes.
