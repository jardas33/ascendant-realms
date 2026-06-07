# v0.148 Worker Billboard Paired Benchmark Report

Status: final local headed private-comparator evidence from `npm run godot:worker-billboard-repair:capture`.

Artifact root:

```text
artifacts/desktop-spikes/godot-salto/v0148/evidence/
```

Primary evidence files:

```text
artifacts/desktop-spikes/godot-salto/v0148/evidence/worker-billboard-repair-runtime.json
artifacts/desktop-spikes/godot-salto/v0148/evidence/worker-billboard-repair-evidence.json
artifacts/desktop-spikes/godot-salto/v0148/evidence/paired-benchmark-summary.md
artifacts/desktop-spikes/godot-salto/v0148/evidence/worker-billboard-repair-threshold-report.json
artifacts/desktop-spikes/godot-salto/v0148/evidence/worker-billboard-repair-fair-path-audit.json
artifacts/desktop-spikes/godot-salto/v0148/evidence/contact-sheet.svg
```

## Benchmark Matrix

The headed paired benchmark compares:

- `HYBRID_DIAGNOSTIC_FALLBACK_BASELINE`
- `HYBRID_WORKER_FULL_RES`
- `HYBRID_WORKER_TRIMMED_512`
- `HYBRID_WORKER_TRIMMED_768`
- `HYBRID_WORKER_TRIMMED_1024`
- `ORTHO_3D_MESH_FALLBACK_COMPARATOR`

Each approach runs Tier S, Tier M, and Tier L. Hybrid billboard approaches run five Tier L trials.

Final captured aggregate:

| Approach | Tier S FPS | Tier M FPS | Tier L trials | Tier L mean FPS | Tier L p95 ms | Source |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| `HYBRID_DIAGNOSTIC_FALLBACK_BASELINE` | `1606.64` | `1386.71` | `5` | `858.41` | `1.87` | tracked diagnostic fallback |
| `HYBRID_WORKER_FULL_RES` | `1303.50` | `1344.57` | `5` | `781.83` | `2.05` | local full-resolution Worker |
| `HYBRID_WORKER_TRIMMED_512` | `1571.50` | `1387.86` | `5` | `875.47` | `1.93` | local trimmed 512 Worker |
| `HYBRID_WORKER_TRIMMED_768` | `1443.87` | `1360.67` | `5` | `851.48` | `1.94` | local trimmed 768 Worker |
| `HYBRID_WORKER_TRIMMED_1024` | `1489.57` | `1378.68` | `5` | `851.14` | `1.88` | local trimmed 1024 Worker |
| `ORTHO_3D_MESH_FALLBACK_COMPARATOR` | `1334.52` | `1285.02` | `5` | `824.07` | `1.96` | orthographic procedural mesh |

## Original Acceptance Gate

Tier L repaired Worker evidence must remain at least 90 percent of the hybrid diagnostic fallback baseline average FPS and must not worsen p95 frame time by more than 15 percent. Absolute p95 delta is context only.

Final threshold result:

```text
PASS_V0148_WORKER_BILLBOARD_ORIGINAL_GATE
```

- Selected recommended derivative: `HYBRID_WORKER_TRIMMED_1024`.
- Baseline Tier L mean FPS: `858.41`.
- Selected Tier L mean FPS: `851.14`.
- Average FPS ratio: `0.9915`, above the `0.90` target.
- Baseline Tier L mean p95 frame time: `1.87 ms`.
- Selected Tier L mean p95 frame time: `1.88 ms`.
- p95 frame-time ratio: `1.0053`, within the `1.15` limit.
- Absolute p95 delta: `0.01 ms`, recorded as context only.

Interpretation: the repaired private path passes the preserved original gate. The selected 1024 derivative is not the fastest candidate, but it is the highest-resolution passing candidate and remains the recommended human-review stop.

## Boundary

- No gate relaxation.
- No second slot.
- No import of any generated reference image.
- No normal Salto player-facing scene mutation.
- No browser runtime wiring.
- No v0.149 work.
