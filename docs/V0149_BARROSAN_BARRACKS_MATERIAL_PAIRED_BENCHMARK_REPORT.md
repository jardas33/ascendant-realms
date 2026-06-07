# v0.149 Barracks Material Paired Benchmark Report

Status: final local headed private-comparator evidence is produced by `npm run godot:barracks-material:capture`.

Artifact root:

```text
artifacts/desktop-spikes/godot-salto/v0149/evidence/
```

Primary evidence files:

```text
artifacts/desktop-spikes/godot-salto/v0149/evidence/barracks-material-runtime.json
artifacts/desktop-spikes/godot-salto/v0149/evidence/barracks-material-evidence.json
artifacts/desktop-spikes/godot-salto/v0149/evidence/paired-benchmark-summary.md
artifacts/desktop-spikes/godot-salto/v0149/evidence/barracks-material-threshold-report.json
artifacts/desktop-spikes/godot-salto/v0149/evidence/barracks-material-fair-path-audit.json
artifacts/desktop-spikes/godot-salto/v0149/evidence/contact-sheet.svg
```

## Benchmark Matrix

The headed paired benchmark compares:

- `HYBRID_BARRACKS_DIAGNOSTIC_FALLBACK`
- `HYBRID_BARRACKS_LOCAL_512`
- `HYBRID_BARRACKS_LOCAL_768`
- `HYBRID_BARRACKS_LOCAL_1024`
- `HYBRID_WORKER_CONTEXT_BASELINE`
- `ORTHO_3D_MESH_FALLBACK_COMPARATOR`

Each approach runs Tier S, Tier M, and Tier L. Tier L runs five trials with rotated scenario order.

## Final Acceptance Gate

Tier L repaired material evidence must remain at least 90 percent of the hybrid diagnostic fallback average FPS and must not worsen p95 frame time by more than 15 percent.

Final threshold marker:

```text
PASS_V0149_BARRACKS_MATERIAL_ORIGINAL_GATE
```

Selected recommended derivative:

```text
HYBRID_BARRACKS_LOCAL_768
```

Selection reason: highest-resolution local Barracks material derivative that passed both preserved Tier L performance thresholds in the final capture.

## Tier L Gate Table

| Candidate | Mean FPS | FPS ratio | p95 ms | p95 ratio | Gate |
| --- | ---: | ---: | ---: | ---: | --- |
| `HYBRID_BARRACKS_DIAGNOSTIC_FALLBACK` | `1784.09` | `1.0000` | `0.94` | `1.0000` | baseline |
| `HYBRID_BARRACKS_LOCAL_512` | `1483.51` | `0.8315` | `1.23` | `1.3085` | fail |
| `HYBRID_BARRACKS_LOCAL_768` | `1873.11` | `1.0499` | `0.85` | `0.9043` | pass, selected |
| `HYBRID_BARRACKS_LOCAL_1024` | `1573.97` | `0.8822` | `1.03` | `1.0957` | fail average FPS, p95 pass |

## S/M/L Summary

| Approach | Tier | Trials | Mean FPS | p95 ms | p99 ms |
| --- | --- | ---: | ---: | ---: | ---: |
| `HYBRID_BARRACKS_DIAGNOSTIC_FALLBACK` | `S` | `1` | `1973.16` | `0.78` | `1.06` |
| `HYBRID_BARRACKS_LOCAL_512` | `S` | `1` | `1914.39` | `0.92` | `0.99` |
| `HYBRID_BARRACKS_LOCAL_768` | `S` | `1` | `2310.18` | `0.66` | `0.77` |
| `HYBRID_BARRACKS_LOCAL_1024` | `S` | `1` | `2132.46` | `0.77` | `0.99` |
| `HYBRID_WORKER_CONTEXT_BASELINE` | `S` | `1` | `1877.73` | `0.78` | `0.95` |
| `ORTHO_3D_MESH_FALLBACK_COMPARATOR` | `S` | `1` | `2638.41` | `0.51` | `0.55` |
| `HYBRID_BARRACKS_DIAGNOSTIC_FALLBACK` | `M` | `1` | `2375.18` | `0.54` | `0.66` |
| `HYBRID_BARRACKS_LOCAL_512` | `M` | `1` | `2471.41` | `0.63` | `0.68` |
| `HYBRID_BARRACKS_LOCAL_768` | `M` | `1` | `2253.54` | `0.60` | `0.86` |
| `HYBRID_BARRACKS_LOCAL_1024` | `M` | `1` | `1592.34` | `1.07` | `1.31` |
| `HYBRID_WORKER_CONTEXT_BASELINE` | `M` | `1` | `2919.42` | `0.47` | `0.55` |
| `ORTHO_3D_MESH_FALLBACK_COMPARATOR` | `M` | `1` | `2778.96` | `0.50` | `0.58` |
| `HYBRID_BARRACKS_DIAGNOSTIC_FALLBACK` | `L` | `5` | `1784.09` | `0.94` | `1.13` |
| `HYBRID_BARRACKS_LOCAL_512` | `L` | `5` | `1483.51` | `1.23` | `1.49` |
| `HYBRID_BARRACKS_LOCAL_768` | `L` | `5` | `1873.11` | `0.85` | `1.05` |
| `HYBRID_BARRACKS_LOCAL_1024` | `L` | `5` | `1573.97` | `1.03` | `1.35` |
| `HYBRID_WORKER_CONTEXT_BASELINE` | `L` | `5` | `2631.36` | `0.59` | `0.82` |
| `ORTHO_3D_MESH_FALLBACK_COMPARATOR` | `L` | `5` | `2413.49` | `0.58` | `0.74` |

## Tier L Selected Trials

`HYBRID_BARRACKS_LOCAL_768` five-trial detail:

- Trial 1: `1934.17` FPS, p95 `0.93 ms`.
- Trial 2: `1977.83` FPS, p95 `0.72 ms`.
- Trial 3: `2095.02` FPS, p95 `0.56 ms`.
- Trial 4: `1850.54` FPS, p95 `0.88 ms`.
- Trial 5: `1507.99` FPS, p95 `1.14 ms`.

The complete 30-row Tier L trial ledger is in:

```text
artifacts/desktop-spikes/godot-salto/v0149/evidence/paired-benchmark-summary.md
```

## Boundary

- No gate relaxation.
- No third slot.
- No import of any existing reference image.
- No normal Salto player-facing scene mutation.
- No browser runtime wiring.
- No v0.150 work.
