# v0.153 Hybrid Three-Slot Scorecard

Status: `PASS_V0153_HYBRID_THREE_SLOT_STRESS_GATE`.

Expected gate marker: `PASS_V0153_HYBRID_THREE_SLOT_STRESS_GATE`.

Evidence root:

```text
artifacts/desktop-spikes/godot-salto/v0153/evidence/
```

Approaches:

- `HYBRID_THREE_SLOT_FALLBACK_ONLY`
- `HYBRID_THREE_SLOT_SELECTED_LOCAL`
- `ORTHO_THREE_SLOT_PROCEDURAL_FALLBACK`

Final Tier L scorecard:

| Approach | Mean FPS | Mean p95 ms | Mean p99 ms | Tier L trials | Notes |
| --- | ---: | ---: | ---: | ---: | --- |
| `HYBRID_THREE_SLOT_FALLBACK_ONLY` | `1111.09` | `1.32` | `1.49` | `5` | tracked fallback-only hybrid |
| `HYBRID_THREE_SLOT_SELECTED_LOCAL` | `1118.98` | `1.37` | `1.49` | `5` | selected v0.148/v0.150/v0.152 local derivatives |
| `ORTHO_THREE_SLOT_PROCEDURAL_FALLBACK` | `999.84` | `1.67` | `1.86` | `5` | procedural ortho comparison |

Gate result:

- Selected-local FPS ratio versus fallback-only: `1.0071`.
- Selected-local p95 frame-time ratio versus fallback-only: `1.0379`.
- Benchmark rows: `21`.
- Screenshot count: `24`.
- Evidence marker: `PASS_V0153_HYBRID_THREE_SLOT_EVIDENCE_RECORDED`.
- Human review remains required for final overlap, seam, shimmer, halo, identity, and composition judgement.
