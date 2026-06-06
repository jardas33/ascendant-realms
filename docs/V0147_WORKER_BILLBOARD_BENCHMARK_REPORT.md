# v0.147 Worker Billboard Benchmark Report

Status: local headed comparator evidence. Final numbers are mirrored from the ignored v0.147 evidence packet after verification.

Artifact root:

```text
artifacts/desktop-spikes/godot-salto/v0147/evidence/
```

Primary evidence files:

```text
artifacts/desktop-spikes/godot-salto/v0147/evidence/worker-billboard-single-slot-runtime.json
artifacts/desktop-spikes/godot-salto/v0147/evidence/worker-billboard-evidence.json
artifacts/desktop-spikes/godot-salto/v0147/evidence/benchmark-summary.md
artifacts/desktop-spikes/godot-salto/v0147/evidence/threshold-report.json
artifacts/desktop-spikes/godot-salto/v0147/evidence/screenshot-manifest.json
artifacts/desktop-spikes/godot-salto/v0147/evidence/contact-sheet.svg
```

## Benchmark Matrix

The headed benchmark compares:

- `HYBRID_DIAGNOSTIC_FALLBACK_BASELINE`
- `HYBRID_LOCAL_WORKER_SLOT`
- `ORTHO_3D_MESH_FALLBACK_COMPARATOR`

Each approach runs Tier S, Tier M, and Tier L.

Final headed capture, written under the ignored evidence root:

| Approach | Tier | Avg FPS | p95 ms | p99 ms | Frames | Duration ms | Entities | Billboards | Objects | Source |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| `HYBRID_DIAGNOSTIC_FALLBACK_BASELINE` | S | 1285.90 | 1.09 | 1.15 | 120 | 93.32 | 14 | 14 | 38 | tracked diagnostic fallback |
| `HYBRID_DIAGNOSTIC_FALLBACK_BASELINE` | M | 1176.29 | 1.24 | 1.55 | 150 | 127.52 | 43 | 43 | 75 | tracked diagnostic fallback |
| `HYBRID_DIAGNOSTIC_FALLBACK_BASELINE` | L | 1035.67 | 1.19 | 1.47 | 180 | 173.80 | 105 | 105 | 150 | tracked diagnostic fallback |
| `HYBRID_LOCAL_WORKER_SLOT` | S | 1524.39 | 0.88 | 0.97 | 120 | 78.72 | 14 | 14 | 38 | local experimental cutout |
| `HYBRID_LOCAL_WORKER_SLOT` | M | 1277.47 | 1.07 | 1.15 | 150 | 117.42 | 43 | 43 | 75 | local experimental cutout |
| `HYBRID_LOCAL_WORKER_SLOT` | L | 876.64 | 1.63 | 1.80 | 180 | 205.33 | 105 | 105 | 150 | local experimental cutout |
| `ORTHO_3D_MESH_FALLBACK_COMPARATOR` | S | 1637.55 | 0.76 | 0.85 | 120 | 73.28 | 14 | 0 | 38 | orthographic procedural mesh |
| `ORTHO_3D_MESH_FALLBACK_COMPARATOR` | M | 1211.83 | 1.44 | 1.60 | 150 | 123.78 | 43 | 0 | 75 | orthographic procedural mesh |
| `ORTHO_3D_MESH_FALLBACK_COMPARATOR` | L | 850.10 | 1.94 | 2.52 | 180 | 211.74 | 105 | 0 | 150 | orthographic procedural mesh |

## Acceptance Threshold

Tier L local Worker-slot evidence should remain at least 90 percent of the hybrid diagnostic baseline average FPS and should not worsen p95 frame time by more than 15 percent versus the hybrid diagnostic baseline.

Final threshold result:

```text
FAIL_V0147_WORKER_BILLBOARD_TIER_L_THRESHOLD
```

- Baseline Tier L average FPS: `1035.67`.
- Local Worker Tier L average FPS: `876.64`.
- Average FPS ratio: `0.8464`, below the `0.90` acceptance target.
- Baseline Tier L p95 frame time: `1.19 ms`.
- Local Worker Tier L p95 frame time: `1.63 ms`.
- p95 frame-time ratio: `1.3697`, above the strict `1.15` target.
- p95 absolute delta: `0.44 ms`, within the recorded `0.50 ms` local headed jitter allowance.
- Preferred scale posture: `1.00x`; `0.90x` is safer for crowding, and `1.10x` is close-review only.

Interpretation: this is not a catastrophic performance regression, but the final local headed capture misses the Tier L average-FPS gate and should stop here with a single bounded repair pass recommendation instead of expanding scope.

## Limitations

- This is private local headed comparator evidence, not packaged Salto playability proof.
- The local AI cutout is ignored and private comparator-only.
- The tracked fallback is diagnostic geometry only.
- No animation asset production is performed.
- No production approval, final Worker design approval, final engine selection, or runtime-art integration approval is implied.
