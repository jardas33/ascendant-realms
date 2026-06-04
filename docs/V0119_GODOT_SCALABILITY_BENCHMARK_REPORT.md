# v0.119 Godot Scalability Benchmark Report

The v0.119 benchmark ran both placeholder modes through S, M, and L tiers across idle, moving, and combat phases. Metrics are directional workflow evidence only, not final production certification.

## Artifact Paths

```text
artifacts/desktop-spikes/godot-salto/v0119/scalability-benchmark-2d.json
artifacts/desktop-spikes/godot-salto/v0119/scalability-benchmark-2_5d.json
artifacts/desktop-spikes/godot-salto/v0119/benchmark-summary.md
```

## Current Results

| Mode | Tier | Combat avg FPS | Combat p95 ms | Nav queries | Stuck units | AI pressure beats |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 2D | S | 240.00 | 0.54 | 2,888 | 0 | 0 |
| 2D | M | 240.00 | 5.45 | 12,482 | 0 | 1 |
| 2D | L | 31.57 | 41.67 | 28,846 | 0 | 181 |
| 2.5D | S | 240.00 | 0.25 | 2,888 | 0 | 0 |
| 2.5D | M | 240.00 | 3.61 | 12,482 | 0 | 1 |
| 2.5D | L | 32.12 | 40.51 | 28,846 | 0 | 181 |

Total navigation query count per mode across all phases: `53146`.

## Package Evidence

```text
Windows package - PASS_WINDOWS_PACKAGE
Path - artifacts/desktop-spikes/godot-salto/latest/AscendantRealmsGodotSalto-v0119-windows.zip
SHA-256 - 3bb9c596508936a990b106a8a11597243ee55d401299f9f79119baf9c76dc3aa
Size - 34.465 MB
```

## Interpretation

The workload is now large enough to expose tier scaling and 2D-vs-2.5D comparison pressure. Tier L is the meaningful row: it runs 105 units, five sites, two enemy structures, two Lume links, and sustained pressure. It is still placeholder-only and should not be used to certify final art, final gameplay, or final engine selection.
