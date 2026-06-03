# v0.113 Implementation Report

v0.113 implements exact-semantics spatial-query instrumentation and two bounded runtime optimizations.

## Runtime Changes

- Added private spatial-query counters to BattleScene test hooks.
- Added same-frame identical path request reuse in MovementSystem.
- Added cached combat frame entity lists and ID lookups in CombatSystem.
- Kept CollisionSystem nearest ordering and tie behavior intact while allowing optional private metrics.

## Artifacts

- `artifacts/performance/v0113/query-profile.json`
- `artifacts/performance/v0113/density-matrix.json`
- `artifacts/performance/v0113/old-new-comparison.json`
- `artifacts/performance/v0113/parity-summary.json`
- `artifacts/performance/v0113/before-after-delta.md`
- `artifacts/performance/v0113/rollback-posture.md`

Profile rows measured: 14.

No AI strategy, target priority, path results, movement outcomes, collision/capture/combat balance, saves, IDs, art, engine posture, desktop, multiplayer, or content changes.
