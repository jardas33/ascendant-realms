# v0.189 Bridge-Riverbank Material Comparator QA Benchmark

Status: `PASS_V0189_BRIDGE_RIVERBANK_MATERIAL_SELECTION_GATE`

v0.189 generated exactly one private-comparator Barrosan wet-granite bridge-riverbank material source and stopped before player-slice integration. The source and derivatives remain local ignored evidence; only the diagnostic fallback, comparator harness, docs, and wrappers are tracked.

## Source And Derivatives

Generated source:

- `artifacts/desktop-spikes/godot-salto/v0189/local-bridge-riverbank-material-slot/barrosan_wet_granite_bridge_riverbank_material_v0189_source.png`
- SHA-256: `342d058f4749e115569a82bf971bb409ccd63825f93b7428d346150ebd9d003a`
- Dimensions: `1254x1254`
- Prompt posture: top-down square wet granite material study for bridge abutments and riverbank retaining edges, restrained moss/dark lichen in seams, no characters, buildings, text, horizon, border, landmark, or baked directional shadow.

Selected candidate:

- `BRIDGE_RIVERBANK_MATERIAL_LOCAL_1024`
- `artifacts/desktop-spikes/godot-salto/v0189/local-bridge-riverbank-material-slot/barrosan_wet_granite_bridge_riverbank_material_v0189_1024.png`
- SHA-256: `638ce153d7a3d39db729dfa13ba05f3fb05c437c2802ab91b5cd248bd2036753`
- Mean opposing-edge seam delta: `11.94`
- UV scale: `0.70`
- Moss/lichen classifier ratio after restraint pass: `0.007`

Comparison derivatives:

- `BRIDGE_RIVERBANK_MATERIAL_LOCAL_512`: `08561015bca1a80c6024b198b88a268fd52c5bcd957d2d15590f2f42cd662d00`
- `BRIDGE_RIVERBANK_MATERIAL_LOCAL_768`: `1fb3cc72c4bcafb24c4c45a80332037a3b057236f93782b0c30c719996bfa957`
- `BRIDGE_RIVERBANK_MATERIAL_1024_WRAPSAFE_OFFSET_BLEND`: `cb955f953f0530d31df8cdbc958f87dfb9c1e7a2fdd8736f3476db0a222122d9`

Tracked diagnostic fallback:

- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_wet_granite_bridge_riverbank_material_v0189_fallback.png`
- SHA-256: `0a2e9bb0b94f544b183f49cf7a5f2a213768a5bca9a2c76192db9bb982b36ef2`

## Visual QA

Captured review views:

- Close source view: `artifacts/desktop-spikes/godot-salto/v0189/evidence/screenshots/015_bridge_riverbank_material_local_1024_s_close_material_source_view.png`
- Normal RTS distance: `artifacts/desktop-spikes/godot-salto/v0189/evidence/screenshots/016_bridge_riverbank_material_local_1024_m_normal_rts_gameplay_distance.png`
- Zoomed-out gameplay distance: `artifacts/desktop-spikes/godot-salto/v0189/evidence/screenshots/017_bridge_riverbank_material_local_1024_l_zoomed_out_gameplay_view.png`
- Seam diagnostic: `artifacts/desktop-spikes/godot-salto/v0189/evidence/screenshots/018_bridge_riverbank_material_local_1024_s_seam_grid_offset_diagnostic.png`
- Fallback comparison: `artifacts/desktop-spikes/godot-salto/v0189/evidence/screenshots/023_bridge_riverbank_material_diagnostic_fallback_s_deterministic_fallback_comparison.png`

Findings:

- The selected derivative reads as dark wet granite and is visually distinct from the existing brown ground and compacted road materials.
- The stone is strong enough that future integration should be limited to bridge abutments and riverbank retaining-edge accents, not broad ground, road, water, structure, or minimap replacement.
- Normal and zoomed-out comparator captures preserve river/road contrast; the selected material is legible beside water and does not collapse into the road band.
- The non-wrapsafe 1024 candidate was selected because its seam score is acceptable and it preserves natural slab variation better than the offset-blend comparison.

## Benchmark

Final private comparator benchmark:

- Status: `PASS_V0189_BRIDGE_RIVERBANK_MATERIAL_SELECTION_GATE`
- Tier L fallback average FPS: `1489.42`
- Tier L selected average FPS: `1597.49`
- Tier L FPS ratio: `1.0726`
- Tier L fallback p95 frame time: `1.02 ms`
- Tier L selected p95 frame time: `1.00 ms`
- Tier L p95 worsening: `-1.57%`
- Screenshot count: `26`
- Benchmark count: `35`

Commands run:

- `node --check tools/godot/bridgeRiverbankMaterialSingleSlotTool.mjs`
- `npm run godot:bridge-riverbank-material:fallback:reproduce`
- `npm run godot:bridge-riverbank-material:derivatives:reproduce`
- `npm run godot:bridge-riverbank-material:validate`
- `npm run godot:bridge-riverbank-material:benchmark:headed`
- `npm run godot:cleanup:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0189/cleanup-dry-run`
- `npm run godot:validate:salto-experimental-artifact-retention`

Evidence:

- `artifacts/desktop-spikes/godot-salto/v0189/evidence/bridge-riverbank-material-threshold-report.json`
- `artifacts/desktop-spikes/godot-salto/v0189/evidence/bridge-riverbank-material-runtime.json`
- `artifacts/desktop-spikes/godot-salto/v0189/evidence/bridge-riverbank-material-fair-path-audit.json`
- `artifacts/desktop-spikes/godot-salto/v0189/evidence/bridge-riverbank-material-boundary-report.json`
- `artifacts/desktop-spikes/godot-salto/v0189/cleanup-dry-run/salto-experimental-cleanup-report.json`
