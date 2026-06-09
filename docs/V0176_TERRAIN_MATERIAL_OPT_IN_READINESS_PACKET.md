# v0.176 Terrain Material Opt-In Readiness Packet

Status: `READY_WITH_CONSTRAINTS_V0176_TERRAIN_MATERIAL_OPT_IN`

v0.176 is documentation-only. It prepares a future player-slice terrain-material opt-in plan without modifying runtime code, generating images, adding slots, deleting evidence, or starting v0.177.

## Readiness Decision

Proceed only through a future explicit v0.177 prompt, and only for exactly one terrain-material player-slice opt-in slot.

The approved future candidate is the v0.175 selected private comparator derivative:

- Candidate: `GROUND_MATERIAL_LOCAL_1024`
- File: `artifacts/desktop-spikes/godot-salto/v0175/local-ground-material-slot/barrosan_foothold_ground_material_v0175_1024.png`
- SHA-256: `818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8`
- Source SHA-256: `0a05fa455af72c20f18a9f412949d3b2b3cd1d7bcf61cea9bc297b1a131c0c7e`
- v0.175 gate: `PASS_V0175_GROUND_MATERIAL_SELECTION_GATE`

Do not authorize broad terrain replacement. The future slot should bind one ground material to one constrained terrain surface family only.

## Candidate Terrain Surfaces

Recommended future surface:

- Existing procedural battlefield base ground surface within the Godot Salto player-facing review slice.

Do not include these in the first terrain-material slot:

- Road beds, shoulders, bridge, river water, river banks, site markers, approach-lane overlays, minimap, structures, selection rings, unit billboards, HUD, combat VFX, or browser runtime surfaces.

The road/river/bridge/site-marker clarity from v0.173 and v0.174 should remain procedural and readable above the material. If the material obscures those tactical overlays, v0.177 should fail the visual gate rather than broaden scope.

## Fallback Posture

Future v0.177 should add a normal-slice opt-in fallback contract for the new terrain-material slot, modeled after the existing Worker/Barracks/Militia/Aster/Ashen fallback pattern.

Fallback requirements:

- Missing selected art must fall back to procedural ground without crashing.
- Hash mismatch must fall back to procedural ground without crashing.
- The fallback path must keep Worker, Barracks, Militia, Aster, and Ashen selected opt-in slots active when their launcher is used.
- The default launcher must remain procedural.
- The v0.175 tracked private comparator fallback remains comparator evidence only and should not be reused as player-slice art.

## Opt-In Launcher Design

Future v0.177 should add one new launcher only after human approval:

- Proposed launcher: `GODOT_LAUNCH_SALTO_FIVE_SLOT_TERRAIN_MATERIAL_EXPERIMENT_WINDOWS.bat`
- Proposed validation wrapper: `GODOT_VALIDATE_SALTO_FIVE_SLOT_TERRAIN_MATERIAL_EXPERIMENT_WINDOWS.bat`
- Proposed capture wrapper: `GODOT_CAPTURE_SALTO_FIVE_SLOT_TERRAIN_MATERIAL_EXPERIMENT_WINDOWS.bat`
- Proposed npm scripts should use the existing Godot wrapper style.

Required preservation:

- `GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat` remains procedural.
- `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat` remains procedural.
- Worker-only, Worker + Barracks, Worker + Barracks + Militia, Worker + Barracks + Militia + Aster, and five-slot launchers remain preserved.
- Browser runtime remains untouched.

## UV, Filter, And Mipmap Contract

Future integration should use:

- Repeat tiling on the base ground surface.
- Linear filtering with mipmaps.
- One-time texture load and material creation.
- No per-frame decode.
- No per-frame metadata parsing.
- Stable UV scale chosen for RTS readability at normal and zoomed-out review distances.

Future v0.177 should explicitly capture:

- Close material view.
- Normal RTS gameplay distance.
- Zoomed-out gameplay view.
- Road/river/bridge/site-marker overlay readability.
- Five-slot coexistence.
- Missing-art fallback.
- Hash-mismatch fallback.

## Performance Gates

The future terrain-material opt-in path must benchmark against equivalent procedural modes:

- M0 default procedural baseline.
- M5 existing five-slot opt-in baseline.
- M5+T1 future five-slot plus one terrain-material opt-in.
- Missing-art fallback.
- Hash-mismatch fallback.

Required thresholds:

- M5+T1 average-FPS ratio versus M5 must be `>= 0.90`.
- M5+T1 p95 frame-time worsening versus M5 must be `<= 15%`.
- Fallback modes must not crash and should remain within the same thresholds unless a later prompt defines stricter limits.

## Visual Gates

Future v0.177 must fail rather than broaden scope if any of these appear:

- Roads, bridge, river banks, site markers, or approach lanes lose tactical readability.
- The material reads as a large landmark instead of a reusable ground surface.
- Tiling repetition is distracting at normal RTS distance.
- The selected character slots become harder to read.
- The material makes the world look more cinematic, sci-fi, lava-like, or spectacle-heavy than the approved Salto environment lock.
- Any duplicate procedural placeholder becomes more confusing.

## Package-Leak Prevention

Future v0.177 must prove:

- No browser runtime wiring.
- No production package inclusion unless explicitly authorized by the future prompt.
- No default-art enablement.
- No save, stable-ID, gameplay, objective, AI, balance, or campaign mutation.
- No new character slot.
- Exactly one terrain-material slot, behind explicit opt-in only.

## Evidence Inputs

Read and preserve:

- `docs/V0173_ENVIRONMENT_SHELL_HARDENING_QA_AND_BENCHMARK.md`
- `docs/V0174_TACTICAL_ENVIRONMENT_READABILITY_QA_AND_BENCHMARK.md`
- `docs/V0175_GROUND_MATERIAL_COMPARATOR_QA_AND_BENCHMARK.md`
- `docs/V0175_PRIVATE_COMPARATOR_BOUNDARY_AND_ROLLBACK.md`
- `docs/SALTO_EXPERIMENTAL_ARTIFACT_INDEX.md`
- `artifacts/desktop-spikes/godot-salto/v0175/evidence/`
- `artifacts/desktop-spikes/godot-salto/v0175/cleanup-dry-run/`

## Boundary

No images generated.

No slots added.

No runtime code modified.

No player-slice terrain integration.

No browser runtime wiring.

v0.177 prepared but not started.
