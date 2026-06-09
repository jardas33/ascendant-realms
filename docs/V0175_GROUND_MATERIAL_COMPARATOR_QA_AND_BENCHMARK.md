# v0.175 Ground Material Comparator QA And Benchmark

Status: `PASS_V0175_GROUND_MATERIAL_SELECTION_GATE`

v0.175 generated exactly one private-comparator-only Barrosan foothold terrain-material source and tested deterministic derivatives in the isolated Godot ground-material comparator. The player-facing Salto slice was not modified.

## Source And Derivatives

Source: `artifacts/desktop-spikes/godot-salto/v0175/local-ground-material-slot/barrosan_foothold_ground_material_v0175_source.png`

Source SHA-256: `0a05fa455af72c20f18a9f412949d3b2b3cd1d7bcf61cea9bc297b1a131c0c7e`

| Candidate | File | SHA-256 | Decision |
| --- | --- | --- | --- |
| `GROUND_MATERIAL_LOCAL_512` | `artifacts/desktop-spikes/godot-salto/v0175/local-ground-material-slot/barrosan_foothold_ground_material_v0175_512.png` | `eee989847468aec416595fda68c1d5b83c21897256aacb9a59ae1dff4b6698ee` | comparison only |
| `GROUND_MATERIAL_LOCAL_768` | `artifacts/desktop-spikes/godot-salto/v0175/local-ground-material-slot/barrosan_foothold_ground_material_v0175_768.png` | `53c1dddd45cab83f6e58dfc5e03d54bb47b317097eeaa5c1103eb0f04d5d16b8` | comparison only |
| `GROUND_MATERIAL_LOCAL_1024` | `artifacts/desktop-spikes/godot-salto/v0175/local-ground-material-slot/barrosan_foothold_ground_material_v0175_1024.png` | `818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8` | selected |
| `GROUND_MATERIAL_1024_WRAPSAFE_OFFSET_BLEND` | `artifacts/desktop-spikes/godot-salto/v0175/local-ground-material-slot/barrosan_foothold_ground_material_v0175_1024_wrapsafe_offset_blend.png` | `8ecd8e4e9f8e71b8a1f626b04d8d022dc2f9669a580796bcc24c5778345444a9` | rejected comparison |

Selected derivative: `GROUND_MATERIAL_LOCAL_1024`

Rejected comparison: `GROUND_MATERIAL_1024_WRAPSAFE_OFFSET_BLEND`

The wrap-safe offset-blend derivative was preserved as evidence but rejected because the diagnostic comparison showed more obvious banding than the direct 1024 derivative at review distance.

## QA Findings

The selected candidate matches the approved wet Barrosan foothold direction: practical packed earth, granite fragments, restrained moss/grass, overcast tactical clarity, no text, no border, no characters, no buildings, and no perspective horizon.

Seam findings:

- Mean opposing-edge delta: `11.29`.
- RTS-distance seam: acceptable.
- Repetition: restrained at normal and zoomed-out review distances.

Runtime findings:

- Texture source loaded once per candidate.
- Material created once per candidate and reused where safe.
- No per-frame decode.
- No steady-state metadata parsing.
- UV rebuild did not occur during steady-state benchmark.
- Comparator material used repeat tiling with linear filtering and mipmaps.

## Benchmark

Tier L selected-vs-fallback result:

| Metric | Fallback | Selected | Result |
| --- | ---: | ---: | ---: |
| Average FPS | `1501.96` | `1524.56` | ratio `1.015` |
| p95 frame time | `1.21 ms` | `1.20 ms` | worsening `-1.32%` |

Gate result: average-FPS ratio is above `0.90`, and p95 worsening is below `15%`.

## Captures

Required captures:

- Close material source view: `artifacts/desktop-spikes/godot-salto/v0175/evidence/screenshots/015_ground_material_local_1024_s_close_material_source_view.png`
- Normal RTS gameplay distance: `artifacts/desktop-spikes/godot-salto/v0175/evidence/screenshots/016_ground_material_local_1024_m_normal_rts_gameplay_distance.png`
- Zoomed-out gameplay view: `artifacts/desktop-spikes/godot-salto/v0175/evidence/screenshots/017_ground_material_local_1024_l_zoomed_out_gameplay_view.png`
- Seam grid diagnostic: `artifacts/desktop-spikes/godot-salto/v0175/evidence/screenshots/018_ground_material_local_1024_s_seam_grid_offset_diagnostic.png`
- Rejected wrap-safe comparison: `artifacts/desktop-spikes/godot-salto/v0175/evidence/screenshots/022_ground_material_1024_wrapsafe_offset_blend_s_wrapsafe_1024_rejected_banding_comparison.png`

Evidence reports:

- `artifacts/desktop-spikes/godot-salto/v0175/evidence/ground-material-threshold-report.json`
- `artifacts/desktop-spikes/godot-salto/v0175/evidence/ground-material-evidence.json`
- `artifacts/desktop-spikes/godot-salto/v0175/evidence/ground-material-fair-path-audit.json`
- `artifacts/desktop-spikes/godot-salto/v0175/evidence/ground-material-boundary-report.json`
- `artifacts/desktop-spikes/godot-salto/v0175/cleanup-dry-run/salto-experimental-cleanup-report.json`

## Boundary

No player-slice integration

No browser runtime wiring

No further character slots

The selected terrain-material candidate is evidence for future human review only. It is not authorized as player-facing art in this checkpoint.
