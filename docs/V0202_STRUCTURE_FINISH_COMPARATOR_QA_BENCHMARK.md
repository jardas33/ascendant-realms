# v0.202 Structure-Finish Material Comparator QA And Benchmark

Status: `PASS_V0202_STRUCTURE_FINISH_MATERIAL_SELECTION_GATE`

v0.202 generated exactly one original local source image for a private-comparator-only Barrosan structure-finish material test:

`D:\Code for projects\WB game like\ascendant-realms\artifacts\desktop-spikes\godot-salto\v0202\local-structure-finish-material-slot\barrosan_structure_finish_material_v0202_source.png`

Selected derivative:

`D:\Code for projects\WB game like\ascendant-realms\artifacts\desktop-spikes\godot-salto\v0202\local-structure-finish-material-slot\barrosan_structure_finish_material_v0202_1024.png`

Selected derivative SHA-256:

`94d4975f9e6f13453103439135da930b74d1d66b56d2b10e43219de408f508ef`

## Manual Review PNG Pack

`D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0202-structure-finish-material\`

Files:

- `01_selected_1024_derivative.png`
- `02_close_material_source_view.png`
- `03_normal_rts_gameplay_distance.png`
- `04_zoomed_out_gameplay_view.png`
- `05_seam_grid_offset_diagnostic.png`
- `06_diagnostic_fallback_comparison.png`
- `07_contact_sheet.png`

## Selection Gate

| Gate | Result |
| --- | --- |
| Exactly one generated source image | PASS |
| Selected derivative | `STRUCTURE_FINISH_MATERIAL_LOCAL_1024` |
| Seam acceptable at RTS distance | PASS, mean opposing edge delta `11.51` |
| Repetition restrained at RTS distance | PASS |
| Distinct from ground and road | PASS |
| Distinct from riverbank stone | PASS |
| Suitable for future structure shells | PASS |
| Player-slice integration | Forbidden and not performed |

## Tier L Benchmark

| Metric | Fallback | Selected | Gate |
| --- | ---: | ---: | --- |
| Average FPS | `1913.47` | `1874.14` | PASS, ratio `0.9794` >= `0.90` |
| p95 frame time | `0.87 ms` | `0.93 ms` | PASS, worsening `6.65%` <= `15%` |

Runtime evidence:

`D:\Code for projects\WB game like\ascendant-realms\artifacts\desktop-spikes\godot-salto\v0202\evidence\`

## Fair Path Audit

Status: `PASS_V0202_STRUCTURE_FINISH_MATERIAL_FAIR_PATH_AUDIT`

- Texture loaded once and reused.
- Materials created once per source and reused where safe.
- No per-frame decode.
- No derivative generation during runtime.
- Local and fallback materials share the same structure-finish plane render path.
