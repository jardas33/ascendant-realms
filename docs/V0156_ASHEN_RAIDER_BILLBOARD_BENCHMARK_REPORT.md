# v0.156 Ashen Raider Billboard Benchmark Report

## Status

`PASS_V0156_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_GATE`

Evidence:

`PASS_V0156_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_EVIDENCE_RECORDED`

Fair-path audit:

`PASS_V0156_ASHEN_RAIDER_BILLBOARD_FAIR_PATH_AUDIT`

## Tier L Gate

- Fallback mean FPS: `1001.64`
- Local mean FPS: `1006.75`
- Local-vs-fallback FPS ratio: `1.0051`
- Fallback p95 frame time: `1.35 ms`
- Local p95 frame time: `1.36 ms`
- p95 frame-time ratio: `1.0074`
- Visual automated posture: pass

## Tier Matrix

Runtime summary:

`artifacts/desktop-spikes/godot-salto/v0156/evidence/paired-benchmark-summary.md`

Capture manifest:

`artifacts/desktop-spikes/godot-salto/v0156/evidence/ashen-raider-billboard-single-slot-screenshot-manifest.json`

## Notes For Review

The Ashen Raider source reads hostile and distinct from Worker and selected Militia context. The weapon silhouette is large and should receive human art review, but it remains inside the single hostile Raider slot and did not fail the automated gate.
