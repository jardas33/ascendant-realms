# v0.155 Militia Billboard Scorecard

Status: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_GATE`.

Selected derivative: `HYBRID_MILITIA_TRIMMED_1024`.

Selected SHA-256: `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb`.

Evidence summary:

- Evidence marker: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_EVIDENCE_RECORDED`.
- Benchmark rows: `60`.
- Aggregate rows: `20`.
- Screenshots: `36`.
- Selected texture memory proxy: `4194304` bytes.

| Scenario | Fallback FPS / p95 | Selected FPS / p95 | FPS ratio | p95 ratio |
| --- | ---: | ---: | ---: | ---: |
| Tier L | `650.79` / `1.92 ms` | `696.5` / `1.86 ms` | `1.0702` | `0.9688` |
| 32-Militia stress | `690.55` / `1.85 ms` | `691.77` / `1.84 ms` | `1.0018` | `0.9946` |

The selected derivative passes the preserved `0.90` FPS-ratio floor and `1.15` p95-ratio ceiling in both Tier L and 32-Militia stress.

Scorecard JSON:

```text
artifacts/desktop-spikes/godot-salto/v0155/evidence/militia-billboard-repair-scorecard.json
```
