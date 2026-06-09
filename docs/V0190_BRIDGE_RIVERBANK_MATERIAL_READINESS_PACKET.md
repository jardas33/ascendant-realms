# v0.190 Bridge-Riverbank Material Readiness Packet

Status: `READY_WITH_CONSTRAINTS_V0190_BRIDGE_RIVERBANK_MATERIAL_OPT_IN`

v0.190 is documentation-only. It prepares a future single bridge-riverbank material opt-in plan without generating images, adding slots, modifying runtime code, deleting evidence, enabling art by default, wiring the browser runtime, or starting v0.191 inside this checkpoint.

## Readiness Decision

Proceed only through a future explicit implementation prompt, and only for exactly one bridge-riverbank material player-slice opt-in slot.

The approved future candidate is the v0.189 selected private comparator derivative:

- Candidate: `BRIDGE_RIVERBANK_MATERIAL_LOCAL_1024`
- File: `artifacts/desktop-spikes/godot-salto/v0189/local-bridge-riverbank-material-slot/barrosan_wet_granite_bridge_riverbank_material_v0189_1024.png`
- SHA-256: `638ce153d7a3d39db729dfa13ba05f3fb05c437c2802ab91b5cd248bd2036753`
- Source SHA-256: `342d058f4749e115569a82bf971bb409ccd63825f93b7428d346150ebd9d003a`
- v0.189 gate: `PASS_V0189_BRIDGE_RIVERBANK_MATERIAL_SELECTION_GATE`
- Seam mean opposing-edge delta: `11.94`
- Private comparator UV scale: `0.70`

Do not authorize broad stone replacement. The future slot should bind one material to one constrained bridge-riverbank surface family only.

## Scoped Surfaces

Recommended future surfaces:

- Bridge abutment faces.
- Bridge retaining caps only where they visually ground the crossing.
- Riverbank retaining-edge stones immediately beside the river/ford edge.
- Small bridge-to-bank transition skirts where the road visually meets the crossing.

Forbidden surfaces:

- Base ground material.
- Road beds, shoulders, and approach lanes.
- River water, ford water, water foam, and any water shader.
- Structures, walls, roofs, rubble fields, site markers, selection rings, unit billboards, combat VFX, HUD, or minimap.

The v0.189 material is visually strong and dark. If the future path makes the scene read as broad granite terrain instead of focused wet retaining stone, the visual gate should fail rather than expand scope.

## Fallback Posture

Future integration should add a normal-slice opt-in fallback contract for the bridge-riverbank material slot, modeled after the existing environment-material fallback pattern.

Fallback requirements:

- Missing selected art falls back to procedural bridge and riverbank visuals without crashing.
- Hash mismatch falls back to procedural bridge and riverbank visuals without crashing.
- Fallback must keep Worker, Barracks, Militia, Aster, Ashen Raider, ground material, and road material opt-in slots active when their explicit launcher is used.
- The default launcher remains procedural.
- The v0.189 tracked private comparator fallback remains comparator evidence only and should not be reused as player-slice art.

## Future Launcher Design

Future implementation should add one explicit launcher only after human approval:

- Proposed launcher: `GODOT_LAUNCH_SALTO_GROUND_ROAD_BRIDGE_RIVERBANK_MATERIAL_OPT_IN_WINDOWS.bat`
- Proposed review wrapper: `GODOT_REVIEW_SALTO_GROUND_ROAD_BRIDGE_RIVERBANK_MATERIAL_OPT_IN_WINDOWS.bat`
- Proposed validation wrapper: `GODOT_VALIDATE_SALTO_GROUND_ROAD_BRIDGE_RIVERBANK_MATERIAL_OPT_IN_WINDOWS.bat`
- Proposed capture wrapper: `GODOT_CAPTURE_SALTO_GROUND_ROAD_BRIDGE_RIVERBANK_MATERIAL_OPT_IN_WINDOWS.bat`
- Proposed npm scripts should use the existing Godot wrapper style and should not replace any earlier launcher.

Required preservation:

- `GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat` remains procedural.
- `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat` remains procedural.
- Worker-only, Worker + Barracks, Worker + Barracks + Militia, Worker + Barracks + Militia + Aster, five-slot, ground-material, and ground+road-material launchers remain preserved.
- Browser runtime remains untouched.

## UV, Filter, And Mipmap Contract

Future integration should use:

- Repeat tiling only on the scoped abutment and retaining-edge meshes.
- Initial UV scale target `0.70`, with allowed review tuning only if the v0.189 selected derivative becomes too noisy or too large in the player slice.
- Linear filtering with mipmaps.
- One-time texture load and material creation.
- No per-frame decode.
- No per-frame metadata parsing.
- Stable material identity and explicit hash verification before binding.
- No broad terrain, road, water, structure, minimap, or HUD material sharing.

Future capture should explicitly cover:

- Close abutment view.
- Normal RTS gameplay distance.
- Zoomed-out gameplay view.
- Road-to-bridge transition.
- Riverbank readability beside water.
- Ground and road material coexistence.
- Five selected character-slot coexistence.
- Missing-art fallback.
- Hash-mismatch fallback.

## Performance Gates

The future bridge-riverbank material opt-in path must benchmark against equivalent modes:

- M0 default procedural baseline.
- M5 existing five-character-slot opt-in baseline.
- M5+G1+R1 existing five-slot plus ground+road material opt-in baseline.
- M5+G1+R1+B1 future bridge-riverbank material opt-in.
- Missing-art fallback.
- Hash-mismatch fallback.

Required thresholds:

- M5+G1+R1+B1 average-FPS ratio versus M5+G1+R1 must be `>= 0.90`.
- M5+G1+R1+B1 p95 frame-time worsening versus M5+G1+R1 must be `<= 15%`.
- Fallback modes must not crash and should remain within the same thresholds unless a later prompt defines stricter limits.

## Visual Gates

Future implementation must fail rather than broaden scope if any of these appear:

- Roads or approach lanes lose continuity at the crossing.
- River water contrast, riverbank shape, or ford readability weakens.
- The material reads as broad terrain, structure walls, decorative rubble, or a large landmark.
- The dark wet-granite texture crushes character, selection-ring, or combat readability.
- Tiling repetition, shimmer, or mipmap transition is distracting at normal RTS distance.
- Ground and road materials become harder to distinguish.
- Bridge hierarchy or tactical crossing direction becomes less clear.
- Any duplicate procedural placeholder or leftover overlay becomes more confusing.

## Package-Leak Prevention

Future implementation must prove:

- No browser runtime wiring.
- No default-art enablement.
- No production package inclusion beyond the explicit opt-in Godot review path unless a future prompt authorizes it.
- No save, stable-ID, gameplay, pathing, collision, objective, AI, balance, campaign, or content mutation.
- No new character slot.
- Exactly one bridge-riverbank environment-material slot, behind explicit opt-in only.
- The selected v0.189 local derivative and metadata remain preserved.

## Evidence Inputs

Read and preserve:

- `docs/V0187_RIVERBANK_BRIDGE_APPROACH_QA_BENCHMARK.md`
- `docs/V0188_ENVIRONMENT_SHELL_FULL_COHESION_QA.md`
- `docs/V0188_SAFE_CLEANUP_SHELL_FREEZE_PACKET.md`
- `docs/V0189_BRIDGE_RIVERBANK_MATERIAL_COMPARATOR_QA_BENCHMARK.md`
- `docs/V0189_PRIVATE_COMPARATOR_BOUNDARY_ROLLBACK.md`
- `docs/V0189_IMPLEMENTATION_REPORT.md`
- `docs/SALTO_EXPERIMENTAL_ARTIFACT_INDEX.md`
- `artifacts/desktop-spikes/godot-salto/v0189/evidence/`
- `artifacts/desktop-spikes/godot-salto/v0189/cleanup-dry-run/`

## Boundary

No images generated.

No slots added.

No runtime code modified.

No player-slice bridge-riverbank integration.

No browser runtime wiring.

No broad stone replacement authorized.

v0.191 opt-in prompt prepared as a tracked readiness artifact, but v0.191 was not started inside this checkpoint.
