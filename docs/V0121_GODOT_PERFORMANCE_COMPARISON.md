# v0.121 Godot Performance Comparison

Status: `PASS_GODOT_PROCEDURAL_VISUAL_FOUNDATION_PERFORMANCE_COMPARISON`.

The v0.121 benchmark compares four lanes:

- 2D control.
- 2.5D clean readability.
- 2.5D atmospheric balanced.
- 2.5D VFX stress private.

Each lane must preserve S/M/L workload tiers, idle/moving/combat phases, Results readiness, linked_ward exactness, read-only save posture, and zero routine editor requirement.

Generated outputs:

- `artifacts/desktop-spikes/godot-salto/v0121/performance-comparison.json`
- `artifacts/desktop-spikes/godot-salto/v0121/performance-comparison.md`
- `artifacts/desktop-spikes/godot-salto/latest/performance-comparison-v0121.json`

Metrics include FPS average, 1% low, frame percentiles, startup, scene launch, input latency, Results transition, memory where supported, navigation queries, stuck-unit count, and package evidence through the existing export/package reports.

Latest verified summary:

| Lane | Preset | Status | FPS avg | 1% low | p95 frame ms | input ms | Results ms | stuck units |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 2D control | `2D_CONTROL` | PASS | 32.82 | 32.82 | 35.08 | 3.573 | 5484.198 | 0 |
| 2.5D clean readability | `CLEAN_READABILITY` | PASS | 32.99 | 32.99 | 35.83 | 3.643 | 5457.155 | 0 |
| 2.5D atmospheric balanced | `ATMOSPHERIC_BALANCED` | PASS | 33.21 | 33.21 | 34.80 | 3.688 | 5420.777 | 0 |
| 2.5D VFX stress private | `VFX_STRESS_PRIVATE` | PASS | 32.82 | 32.82 | 36.60 | 3.596 | 5484.281 | 0 |

The private VFX stress lane is evidence only and is excluded from the normal Emmanuel review default.

No metric here is final production certification.
