# v0.146 Runtime-Art Pipeline Benchmark Report

Status: local headed comparator evidence.

Artifact root:

```text
artifacts/desktop-spikes/godot-salto/v0146/
```

Raw runtime report:

```text
artifacts/desktop-spikes/godot-salto/v0146/runtime-art-comparator-runtime.json
```

Post-processed evidence:

```text
artifacts/desktop-spikes/godot-salto/v0146/runtime-art-comparator-evidence.json
artifacts/desktop-spikes/godot-salto/v0146/benchmark-summary.md
artifacts/desktop-spikes/godot-salto/v0146/scorecard.json
artifacts/desktop-spikes/godot-salto/v0146/scorecard.md
artifacts/desktop-spikes/godot-salto/v0146/screenshot-manifest.json
artifacts/desktop-spikes/godot-salto/v0146/contact-sheet.svg
```

## Headed Benchmark Summary

Latest local headed comparator run:

| Approach | Tier | Avg FPS | p95 frame ms | p99 frame ms | Frames | Duration ms | Entities | Object proxy | Animation updates | Stuck units |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `ORTHO_3D_MESH` | S | 1261.51 | 1.09 | 1.24 | 120 | 104.24 | 14 | 59 | 1680 | 0 |
| `ORTHO_3D_MESH` | M | 1136.05 | 1.37 | 1.54 | 150 | 158.48 | 43 | 127 | 6450 | 0 |
| `ORTHO_3D_MESH` | L | 775.30 | 2.32 | 2.60 | 180 | 307.87 | 105 | 268 | 18900 | 0 |
| `BILLBOARD_2D_ATLAS` | S | 1208.13 | 1.23 | 1.38 | 120 | 108.83 | 14 | 48 | 1680 | 0 |
| `BILLBOARD_2D_ATLAS` | M | 1332.13 | 1.10 | 1.31 | 150 | 134.40 | 43 | 116 | 6450 | 0 |
| `BILLBOARD_2D_ATLAS` | L | 780.75 | 2.31 | 2.93 | 180 | 300.02 | 105 | 255 | 18900 | 0 |
| `HYBRID_3D_WORLD_BILLBOARD_UNITS` | S | 1088.49 | 1.34 | 1.40 | 120 | 120.10 | 14 | 59 | 1680 | 0 |
| `HYBRID_3D_WORLD_BILLBOARD_UNITS` | M | 1076.66 | 1.47 | 1.78 | 150 | 164.01 | 43 | 127 | 6450 | 0 |
| `HYBRID_3D_WORLD_BILLBOARD_UNITS` | L | 759.59 | 2.24 | 2.46 | 180 | 302.77 | 105 | 268 | 18900 | 0 |

## Interpretation

All three approaches clear the local comparator workload comfortably because the harness uses low-complexity diagnostic primitives. The useful comparison is not raw FPS alone; it is the combined posture across visual ceiling, unit readability, asset-production burden, AI-first operability, and future runtime-art feasibility.

The hybrid lane shows the strongest scorecard balance in this run: it keeps the richer procedural 3D world and structure posture while using billboard units to reduce animation and unit-production burden. Pure billboard remains fast and readable but under-serves terrain and architecture richness. Pure 3D mesh keeps the best full-3D ceiling but carries the heaviest unit animation/content-production risk.

## Limitations

- This is local headed comparator evidence, not packaged Salto microloop proof.
- Screenshots are diagnostic visual evidence only.
- The atlas is generated in memory at runtime and is not a production sprite sheet.
- No human playability, protected-IP clearance, final engine choice, or runtime-art approval is implied.
