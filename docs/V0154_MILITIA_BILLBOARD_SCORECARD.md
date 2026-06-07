# v0.154 Militia Billboard Scorecard

Status: `PASS_V0154_MILITIA_BILLBOARD_SINGLE_SLOT_GATE`.

Evidence marker: `PASS_V0154_MILITIA_BILLBOARD_SINGLE_SLOT_EVIDENCE_RECORDED`.

Fair-path audit: `PASS_V0154_MILITIA_BILLBOARD_FAIR_PATH_AUDIT`.

Evidence root:

```text
artifacts/desktop-spikes/godot-salto/v0154/evidence/
```

Approaches:

- `HYBRID_MILITIA_DIAGNOSTIC_FALLBACK_BASELINE`
- `HYBRID_MILITIA_LOCAL_STATIC_BILLBOARD`
- `ORTHO_MILITIA_PROCEDURAL_FALLBACK`

Tier L result:

| Approach | Mean FPS | p95 ms | p99 ms | Notes |
| --- | ---: | ---: | ---: | --- |
| `HYBRID_MILITIA_DIAGNOSTIC_FALLBACK_BASELINE` | `962.15` | `1.51` | `1.74` | tracked procedural fallback |
| `HYBRID_MILITIA_LOCAL_STATIC_BILLBOARD` | `967.42` | `1.54` | `1.78` | selected local Militia cutout |
| `ORTHO_MILITIA_PROCEDURAL_FALLBACK` | `853.8` | `2.11` | `2.25` | safe comparison path |

Threshold:

- Tier L local average FPS ratio versus fallback: `1.0055` against required `>= 0.90`.
- Tier L local p95 frame-time ratio versus fallback: `1.0199` against required `<= 1.15`.
- Screenshot count: `22`.
- Benchmark row count: `21`.
- Readability flags: Militia below Aster hierarchy, distinct from Worker, group-readable, ring-readable, pivot-stable, depth-sorting-stable, and alpha-reviewable.

Human review remains required for final identity, hierarchy, alpha edge, pivot, ring readability, and group-readability judgement.
