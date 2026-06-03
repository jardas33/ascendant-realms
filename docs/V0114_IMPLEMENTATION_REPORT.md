# v0.114 Implementation Report

v0.114 adds private render-lifecycle counters and bounded presentation optimizations for existing Phaser Graphics/Text and HUD DOM surfaces.

## Runtime Changes

- Added private render-lifecycle metrics and BattleScene hooks.
- Cached deterministic static terrain geometry and removed transient polyline slicing.
- Added no-op guards for capture site visuals, label visibility, health-bar width changes, HUD volatile patches, and local HUD panel state.
- Added command feedback marker Graphics/Text pooling with reset-on-release.
- Added minimap due-or-dirty snapshot reuse without changing minimap contents or visibility rules.

## Artifacts

- `artifacts/performance/v0114/lifecycle-audit.json`
- `artifacts/performance/v0114/before-after-delta.json`
- `artifacts/performance/v0114/before-after-delta.md`
- `artifacts/performance/v0114/memory-trend.json`
- `artifacts/performance/v0114/visual-parity.json`

Audit rows measured: 15.

No art, gameplay, balance, AI, pathing, fog simulation, saves, stable IDs, engine posture, desktop, multiplayer, content, public benchmark posture, or v0.115 work changed.
