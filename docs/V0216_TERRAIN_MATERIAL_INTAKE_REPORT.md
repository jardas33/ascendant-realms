# v0.216 Terrain Material Intake Report

Status: PASS

v0.216 generated exactly one original Barrosan foothold terrain-material source and kept it inside the isolated Godot Salto presentation-reboot path. No downloaded assets were used.

## Source

- Source image: `artifacts/desktop-spikes/godot-salto/v0216/terrain-material-source/barrosan_foothold_terrain_material_v0216_source.png`
- Source SHA-256: `c89cd5c9382d8fa236392c4623729ffb2073c434d06d2992c887e5010429fe3f`
- Generated image count for v0.216: `1`
- Provenance: original local AI generation through the built-in image generator.
- Boundary: presentation-reboot-only, not imported into the browser runtime, not enabled by the default launcher.

## Derivatives

The selected material is a deterministic RTS-distance softened derivative of the single generated source. The softening pass reduces distracting micro-gravel shimmer while preserving soil, moss and small-gravel character.

| Derivative | SHA-256 | Mean luma | LR seam delta | TB seam delta | Repetition delta | Decision |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| 512 | `0e2a39b45264e391f44f807b3fb7f353a2a8273287149a5223e195452f898923` | 48.507 | 8.834 | 10.160 | 0.444 | retained |
| 768 | `3af6d013a3df5fddda69f0753233138f6129b9a851818c85a4b9c3a0ff108d1e` | 48.496 | 9.937 | 11.374 | 0.445 | retained |
| 1024 | `8049b692b5d89d9abf5da39a79a31d8609ceb944dcb5695af8efc8553cd1eea3` | 48.451 | 9.790 | 10.913 | 0.445 | selected |
| 1024 wrap-safe diagnostic | `26feb33b3bbe9fdec28f4b9100f0ddcbe64e3df8140db8a3941b8c9d0680fd63` | 48.353 | 0.000 | 0.000 | 0.400 | diagnostic only |

## Selected Candidate

- Candidate identity: `TERRAIN_MATERIAL_PRODUCTION_LOCAL_1024`
- Runtime approach: `GROUND_MATERIAL_LOCAL_1024`
- Selected SHA-256: `8049b692b5d89d9abf5da39a79a31d8609ceb944dcb5695af8efc8553cd1eea3`
- UV scale: `0.48`
- Runtime blend alpha: `0.24`
- Metadata: `artifacts/desktop-spikes/godot-salto/v0216/local-terrain-material-slot/barrosan_foothold_terrain_material_v0216_1024.metadata.json`

## Evidence

Manual review pack:

- `artifacts/manual-review/v0216-terrain-material-production/01_source_derivative_contact_sheet.png`
- `artifacts/manual-review/v0216-terrain-material-production/02_seam_diagnostic.png`
- `artifacts/manual-review/v0216-terrain-material-production/03_before_after_terrain_overview.png`
- `artifacts/manual-review/v0216-terrain-material-production/04_normal_rts_distance.png`
- `artifacts/manual-review/v0216-terrain-material-production/05_zoomed_out_view.png`
- `artifacts/manual-review/v0216-terrain-material-production/06_pan_zoom_framing.png`
- `artifacts/manual-review/v0216-terrain-material-production/07_fallback_comparison.png`

The wrap-safe derivative is retained as diagnostic evidence only. The selected 1024 derivative is the only v0.216 terrain material bound by the presentation-reboot launcher.
