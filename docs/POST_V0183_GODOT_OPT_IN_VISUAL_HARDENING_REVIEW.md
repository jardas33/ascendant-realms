# Post-v0.183 Godot Opt-In Visual Hardening Review

Status: `PASS_POST_V0183_GODOT_OPT_IN_VISUAL_HARDENING_REVIEW`

Scope: ad hoc visual QA and repair for the existing explicit Godot Salto ground + road material opt-in review path after v0.183. This is not v0.184. It generates zero images, adds zero slots, changes no launcher, keeps the default launcher procedural, keeps browser runtime untouched, and preserves the frozen five character slots plus the selected ground and road environment-material opt-ins.

## Visual Issue Reviewed

The explicit ground + road material opt-in path was technically valid but still read weak in the Windows-side Godot review: the ground texture was too dark and high-frequency, the road material competed with the lane hierarchy, character billboards needed better grounding, and structure/river/bridge contrast could use a more coherent review-only finish.

## Repairs Applied

- Reduced ground-material visual dominance by lowering the material alpha and warming/lightening its tint.
- Reduced road-material dominance while keeping the authored road hierarchy visible.
- Lightened opt-in-only terrain and ridge colors for the environment foundation/readability review modes.
- Lightened opt-in-only review lighting without changing default procedural launchers.
- Tightened the environment-foundation review camera framing so the playable foothold fills the screen more intentionally.
- Added opt-in-only terrain feathering, staging/mine/enemy masks, road crowns, river edges, and bridge trim to improve tactical readability.
- Added opt-in-only structure trim and Barracks binding accents to make the material application more legible.
- Added opt-in-only unit contact shadows so the selected billboards sit into the scene instead of floating over it.

## Validation

```text
PASS: npm run godot:validate:salto-ground-road-material-opt-in
PASS: PASS_WINDOWS_EXPORT
PASS: PASS_WINDOWS_PACKAGE
PASS: PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION
PASS: PASS_V0181_SALTO_GROUND_ROAD_MATERIAL_OPT_IN_AUTOMATION_READY
PASS: PASS_V0181_ROAD_MATERIAL_OPT_IN_VALIDATION
PASS: PASS_V0181_ROAD_MATERIAL_OPT_IN_CAPTURE
PASS: PASS_V0181_ROAD_MATERIAL_OPT_IN_BENCHMARK
PASS: PASS_V0181_ROAD_MATERIAL_OPT_IN_BOUNDARY
PASS: default procedural path remains zero art slots
PASS: ground-only opt-in remains one environment-material slot
PASS: ground+road opt-in remains two environment-material slots
PASS: road missing-art fallback
PASS: road hash-mismatch fallback
PASS: Windows-side Computer Use title, briefing, battle-start, selection, move-order, and mine-conversion smoke
```

Latest benchmark sample from the repaired opt-in path:

```text
Ground-only FPS: 75.08
Ground+road FPS: 74.98
FPS ratio: 0.9987
Ground-only p95: 13.31 ms
Ground+road p95: 12.97 ms
p95 worsening: -2.55%
```

## Evidence

- `artifacts/desktop-spikes/godot-salto/v0181/capture/e2-ground-road-material-opt-in/screenshots/03_ground_material_normal_rts.png`
- `artifacts/desktop-spikes/godot-salto/v0181/capture/e2-ground-road-material-opt-in/screenshots/05_road_river_bridge_hierarchy.png`
- `artifacts/desktop-spikes/godot-salto/v0181/capture/e2-ground-road-material-opt-in/screenshots/07_five_slot_coexistence.png`
- `artifacts/desktop-spikes/godot-salto/v0181/benchmark/road-material-opt-in-benchmark.md`

## Boundary Audit

```text
PASS: zero images generated
PASS: zero character slots added
PASS: zero environment-material slots added
PASS: no launcher changes
PASS: default launcher remains procedural
PASS: browser runtime untouched
PASS: no save, stable-ID, objective, pathing, AI, balance, or campaign mutation
PASS: selected Worker, Barracks, Militia, Aster, Ashen, ground, and road art preserved
PASS: v0.184 prepared by v0.183 but not started here
```

## Residual Review Note

This pass materially improves the explicit Godot opt-in presentation, but it is still a review slice built from procedural shell geometry plus selected opt-in materials and billboards. It should not be treated as final production art quality or as approval to enable art by default.
