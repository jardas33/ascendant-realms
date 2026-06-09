# v0.177 Ground Material Opt-In QA And Benchmark

Status: `PASS_V0177_GROUND_MATERIAL_OPT_IN_QA_BENCHMARK`

v0.177 integrates exactly one Barrosan foothold ground-material environment slot into the Godot Salto player-slice review path behind explicit opt-in only.

## Selected Material

- Slot: `barrosan_foothold_ground_material_v0175`
- Approach: `GROUND_MATERIAL_LOCAL_1024`
- File: `artifacts/desktop-spikes/godot-salto/v0175/local-ground-material-slot/barrosan_foothold_ground_material_v0175_1024.png`
- SHA-256: `818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8`
- Dimensions: `1024x1024`
- UV scale: `0.72`
- Filter: linear with mipmaps

## QA Scenarios

Evidence root: `artifacts/desktop-spikes/godot-salto/v0177/`

Passed scenarios:

- `default-procedural`: zero opt-in slots, default procedural posture.
- `e0-environment-foundation-baseline`: five frozen character/material slots plus environment foundation, no ground material.
- `e1-ground-material-opt-in`: five frozen character/material slots plus one ground-material slot.
- `ground-missing-art-fallback`: selected source missing, procedural foothold fallback visible.
- `ground-hash-mismatch-fallback`: expected hash mismatch, procedural foothold fallback visible.

The ground material is applied only to:

- `v0173_terrain_mid_value_field`
- `v0173_friendly_staging_value_field`

It is not applied to roads, river, banks, bridge, structures, site markers, minimap, HUD, character slots, save data, browser runtime, or the default launcher.

## Windows-Side Visual Review

Computer Use review covered the v0.177 review launcher, title, briefing, and battle screen. The material remains dark and high-frequency, but it stays scoped to foothold ground, remains behind tactical overlays, and does not make the roads, river, bridge, minimap, selection rings, or character billboards unreadable at this first integration gate.

Visual note for v0.178: treat UV/noise hardening as the next bounded task. The current texture is acceptable for v0.177 integration evidence, but it is not yet final presentation polish.

## Benchmark

Benchmark scorecard: `artifacts/desktop-spikes/godot-salto/v0177/benchmark/ground-material-opt-in-benchmark-scorecard.json`

| Mode | Average FPS | p95 frame time |
| --- | ---: | ---: |
| E0 environment foundation baseline | `75.37` | `13.23 ms` |
| E1 ground-material opt-in | `75.20` | `13.56 ms` |

Gate results:

- FPS ratio: `0.9977` against required `>= 0.90`.
- p95 worsening: `2.49%` against allowed `<= 15%`.
- Ground source load count: `1`.
- Metadata parse count: `1`.
- Image decode count: `1`.
- Texture create count: `1`.
- Material create count: `1`.
- Applied ground surface count: `2`.

Status: `PASS_V0177_GROUND_MATERIAL_OPT_IN_BENCHMARK`.

## Validation

Command:

```text
npm run godot:validate:salto-ground-material-opt-in
```

Result:

```text
PASS_V0177_SALTO_GROUND_MATERIAL_OPT_IN_AUTOMATION_READY
PASS_V0177_GROUND_MATERIAL_OPT_IN_VALIDATION
PASS_V0177_GROUND_MATERIAL_OPT_IN_CAPTURE
PASS_V0177_GROUND_MATERIAL_OPT_IN_BENCHMARK
PASS_V0177_GROUND_MATERIAL_OPT_IN_BOUNDARY
PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION
PASS_V0166_EXPERIMENTAL_ARTIFACT_CLEANUP_DRY_RUN
```

## Boundary

Zero images generated. One environment-material opt-in slot added. Zero character slots added. Default launchers remain procedural. Browser runtime, saves, stable IDs, gameplay, pathing, objectives, AI, balance, campaign state, and production manifests remain untouched.
