# v0.198 Wet-Granite Mesh Opt-In QA And Benchmark

Status: `PASS_V0198_WET_GRANITE_MESH_OPT_IN_QA_BENCHMARK`

Date: 2026-06-10

Scope: integrate exactly one previously selected wet-granite bridge-riverbank material into the isolated Salto shell-v2 mesh-compositor review path. No images were generated, no character art slots were added, no default launcher was changed, the browser runtime was not touched, and gameplay, pathing, collisions, objectives, AI, saves, stable IDs, production manifests, legacy shell paths, and prior launchers were preserved.

## Selected Source

Selected derivative from v0.189/v0.190 evidence:

- Candidate: `BRIDGE_RIVERBANK_MATERIAL_LOCAL_1024`
- Source: `artifacts/desktop-spikes/godot-salto/v0189/local-bridge-riverbank-material-slot/barrosan_wet_granite_bridge_riverbank_material_v0189_1024.png`
- Metadata: `artifacts/desktop-spikes/godot-salto/v0189/local-bridge-riverbank-material-slot/barrosan_wet_granite_bridge_riverbank_material_v0189_1024.metadata.json`
- SHA-256: `638ce153d7a3d39db729dfa13ba05f3fb05c437c2802ab91b5cd248bd2036753`
- Source SHA-256: `342d058f4749e115569a82bf971bb409ccd63825f93b7428d346150ebd9d003a`
- Dimensions: `1024x1024`
- UV scale: `0.70`

## Windows QA

The deterministic packaged Godot capture harness exported the compact manual-review pack and the resulting images were directly inspected. The wet-granite material initially read too broadly when applied to continuous bank ribbons, so the final implementation keeps the long bank ribbons procedural and binds the material only to localized retaining-edge and bridge-landing/abutment surfaces.

Final visual read: the bridge and immediate riverbank crossing now have a darker stone accent without reintroducing full-height dark bank bars, broad material masks, detached islands, floating road strips, or road/river alignment regressions. The material is still intentionally restrained and scoped; later structure or shell polish should not treat v0.198 as approval for broader bridge, water, terrain, structure, minimap, or legacy-shell binding.

## Scoped Bind Targets

Final wet-granite bind targets:

- `v0198_mesh_west_bridge_bank_retaining_edge`
- `v0198_mesh_east_bridge_bank_retaining_edge`
- `v0196_mesh_bridge_west_abutment_mass`
- `v0196_mesh_bridge_east_abutment_mass`
- `v0196_mesh_bridge_west_landing_apron`
- `v0196_mesh_bridge_east_landing_apron`

Excluded surfaces remained excluded: terrain, road surfaces, road shoulders, road crowns, river water, bridge deck route, bridge deck planks, rails, structures, site markers, minimap, HUD, character slots, browser runtime, default launcher, and legacy shell paths.

## Validation Summary

| Scenario | Character slots requested/loaded | Environment slots requested/loaded | Wet granite | Fallback |
| --- | ---: | ---: | --- | --- |
| `default-procedural` | `0/0` | `0/0` | disabled | procedural, opt-in absent |
| `m2-shell-v2-mesh-qa` | `5/5` | `2/2` | disabled | procedural, opt-in absent |
| `w1-shell-v2-mesh-wet-granite` | `5/5` | `3/3` | loaded, `6` scoped surfaces | inactive |
| `w1-missing-bridge-riverbank-fallback` | `5/5` | `3/2` | not loaded | missing source file |
| `w1-hash-mismatch-bridge-riverbank-fallback` | `5/5` | `3/2` | not loaded | metadata hash mismatch |

Loader contract evidence:

- Exact metadata SHA and actual image SHA verification.
- Exact `1024x1024` dimension verification.
- One-time image decode, texture creation, and material creation.
- Linear filtering with mipmaps.
- Procedural fallback when disabled, missing, or hash-mismatched.
- Existing Worker, Barracks, Militia, Aster, Ashen, ground, and road slots retained during wet-granite fallback.

## Benchmark

Comparator: v0.197 M2 shell-v2 mesh QA path.

| Scenario | Average FPS | p95 frame time |
| --- | ---: | ---: |
| `m2-shell-v2-mesh-qa` | 75.32 | 13.21 ms |
| `w1-shell-v2-mesh-wet-granite` | 75.12 | 13.37 ms |

Result: FPS ratio `0.9973`; p95 worsening ratio `0.0121`; threshold was FPS ratio >= `0.90` and p95 worsening <= `0.15`.

## Evidence

- `artifacts/desktop-spikes/godot-salto/v0198/validation/wet-granite-mesh-opt-in-validation-report.json`
- `artifacts/desktop-spikes/godot-salto/v0198/benchmark/wet-granite-mesh-opt-in-benchmark-report.json`
- `artifacts/desktop-spikes/godot-salto/v0198/capture/wet-granite-mesh-opt-in-capture-report.json`
- `artifacts/desktop-spikes/godot-salto/v0198/capture/w1-shell-v2-mesh-wet-granite/screenshots/`
- `artifacts/desktop-spikes/godot-salto/v0198/boundary/wet-granite-mesh-opt-in-boundary-scan.json`
- `artifacts/desktop-spikes/godot-salto/v0198/cleanup-dry-run/salto-experimental-cleanup-report.json`
- `artifacts/desktop-spikes/godot-salto/v0198/cleanup-safe-only/salto-experimental-cleanup-report.json`
- `artifacts/desktop-spikes/godot-salto/v0198/artifact-retention-post-cleanup/salto-experimental-artifact-retention-report.json`
- `artifacts/manual-review/v0198-wet-granite-mesh/`

Manual-review PNG pack:

- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0198-wet-granite-mesh\01_procedural_bridge_banks.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0198-wet-granite-mesh\02_wet_granite_bridge_banks.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0198-wet-granite-mesh\03_bridge_close.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0198-wet-granite-mesh\04_banks_close.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0198-wet-granite-mesh\05_road_bridge_transition.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0198-wet-granite-mesh\06_units_crossing.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0198-wet-granite-mesh\07_overview.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0198-wet-granite-mesh\08_contact_sheet.png`

Recommended review screenshots:

- `02_wet_granite_bridge_banks.png`
- `03_bridge_close.png`
- `04_banks_close.png`
- `08_contact_sheet.png`

PASS gates:

- `PASS_V0198_WET_GRANITE_MESH_OPT_IN_VALIDATION`
- `PASS_V0198_WET_GRANITE_MESH_OPT_IN_BENCHMARK`
- `PASS_V0198_WET_GRANITE_MESH_OPT_IN_BOUNDARY_SCAN`
- `PASS_V0198_WET_GRANITE_MESH_OPT_IN_CAPTURE_PACKET`
- `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`
- `PASS_V0198_WET_GRANITE_MESH_OPT_IN_VALIDATION_READY`
