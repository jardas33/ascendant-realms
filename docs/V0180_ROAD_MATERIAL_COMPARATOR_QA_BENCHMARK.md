# v0.180 Road Material Comparator QA Benchmark

Status: `PASS_V0180_ROAD_MATERIAL_SELECTION_GATE`

v0.180 tested exactly one private-comparator Barrosan foothold road-material source and stopped before v0.181. The source and derivatives remain local ignored evidence; only the diagnostic fallback, comparator harness, docs, and wrappers are tracked.

## Source And Derivatives

Generated source:

- `artifacts/desktop-spikes/godot-salto/v0180/local-road-material-slot/barrosan_foothold_road_material_v0180_source.png`
- SHA-256: `4e0399a606843003fe0b5db0070bb67716b4f3d4aa87d3fe81c932bcdf77a817`
- Prompt posture: top-down square wet Barrosan road-surface study, compacted earth path, practical granite fragments, restrained moss edges, subtle central wear, no text, border, characters, buildings, horizon, or baked directional shadow.

Selected candidate:

- `ROAD_MATERIAL_LOCAL_1024`
- `artifacts/desktop-spikes/godot-salto/v0180/local-road-material-slot/barrosan_foothold_road_material_v0180_1024.png`
- SHA-256: `a64959ef2fd7a509fcaaa969fca3e095d590d563a4f0c578a5e96d1fb04c0e10`
- Mean opposing-edge seam delta: `15.32`
- UV scale: `0.80`

Comparison derivatives:

- `ROAD_MATERIAL_LOCAL_512`: `a4bf9ad2c994aa59ce6b958f22220d37038409da704853b35848f297577a0b5e`
- `ROAD_MATERIAL_LOCAL_768`: `bd2ed3aa6006b9a4f995209e317734d04e5711b62cb68dd188ae1aa753fb2bfd`
- `ROAD_MATERIAL_1024_WRAPSAFE_OFFSET_BLEND`: `7519620caa79a9c4d3d22a64e0e161af1d9817aab70ce7474255259dcf8158a9`

## Visual QA

Captured review views:

- Close source view: `artifacts/desktop-spikes/godot-salto/v0180/evidence/screenshots/015_road_material_local_1024_s_close_material_source_view.png`
- Normal RTS distance: `artifacts/desktop-spikes/godot-salto/v0180/evidence/screenshots/016_road_material_local_1024_m_normal_rts_gameplay_distance.png`
- Zoomed-out gameplay distance: `artifacts/desktop-spikes/godot-salto/v0180/evidence/screenshots/017_road_material_local_1024_l_zoomed_out_gameplay_view.png`
- Seam diagnostic: `artifacts/desktop-spikes/godot-salto/v0180/evidence/screenshots/018_road_material_local_1024_s_seam_grid_offset_diagnostic.png`

Findings:

- The selected material reads as a traversable compacted road surface at normal and zoomed-out comparator distances.
- Moss remains edge-biased and restrained; central wear is visible without turning into a landmark.
- The non-wrapsafe 1024 candidate was selected because its seam score is acceptable and it preserves the road-like central wear better than the offset-blend comparison.
- The comparator review scaffolding was strengthened only in the private comparator to make road shoulders, river, bridge, and site markers legible during human review.

## Benchmark

Final private comparator benchmark:

- Status: `PASS_V0180_ROAD_MATERIAL_SELECTION_GATE`
- Tier L fallback average FPS: `1843.93`
- Tier L selected average FPS: `1829.83`
- Tier L FPS ratio: `0.9924`
- Tier L fallback p95 frame time: `0.92 ms`
- Tier L selected p95 frame time: `0.90 ms`
- Tier L p95 worsening: `-1.96%`
- Screenshot count: `26`
- Benchmark count: `35`

Commands run:

- `node --check tools/godot/roadMaterialSingleSlotTool.mjs`
- `npm run godot:road-material:fallback:reproduce`
- `npm run godot:road-material:derivatives:reproduce`
- `npm run godot:road-material:validate`
- `npm run godot:road-material:benchmark:headed`

Evidence:

- `artifacts/desktop-spikes/godot-salto/v0180/evidence/road-material-threshold-report.json`
- `artifacts/desktop-spikes/godot-salto/v0180/evidence/road-material-runtime.json`
- `artifacts/desktop-spikes/godot-salto/v0180/evidence/road-material-fair-path-audit.json`
- `artifacts/desktop-spikes/godot-salto/v0180/evidence/road-material-boundary-report.json`
