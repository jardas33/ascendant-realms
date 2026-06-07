# v0.158 Hybrid Mixed Combat Benchmark Report

Status: `PASS_V0158_HYBRID_MIXED_COMBAT_STRESS_GATE`.

Recorded PASS markers:

```text
PASS_V0158_HYBRID_MIXED_COMBAT_VALIDATION
PASS_V0158_HYBRID_MIXED_COMBAT_FAIR_PATH_AUDIT
PASS_V0158_HYBRID_MIXED_COMBAT_EVIDENCE_RECORDED
PASS_V0158_HYBRID_MIXED_COMBAT_STRESS_GATE
```

The benchmark compares:

- `HYBRID_MIXED_COMBAT_SELECTED_LOCAL`
- `HYBRID_MIXED_COMBAT_FALLBACK_ONLY`
- `ORTHO_MIXED_COMBAT_PROCEDURAL_FALLBACK`

The headed matrix covers Tier S, Tier M, Tier L, and the 32-Ashen diagnostic crowd. Tier L and 32-Ashen selected/fallback scenarios require at least five alternating trials.

Recorded scorecard:

| Gate | Selected | Fallback | Ratio | Requirement | Result |
| --- | --- | --- | --- | --- | --- |
| Tier L mean FPS | `1715.78` | `1826.91` | `0.9392` | `>= 0.90` | PASS |
| Tier L mean p95 ms | `0.91` | `0.82` | `1.1098` | `<= 1.15` | PASS |
| 32-Ashen mean FPS | `1399.45` | `1265.20` | `1.1061` | no catastrophic regression | PASS |
| 32-Ashen mean p95 ms | `1.19` | `1.30` | `0.9154` | no catastrophic regression | PASS |

Rows and captures:

- Benchmark rows: `28`.
- Aggregate rows: `12`.
- Screenshots: `47`.
- Human review required: yes.

Evidence paths:

```text
artifacts/desktop-spikes/godot-salto/v0158/evidence/hybrid-mixed-combat-runtime.json
artifacts/desktop-spikes/godot-salto/v0158/evidence/hybrid-mixed-combat-threshold-report.json
artifacts/desktop-spikes/godot-salto/v0158/evidence/hybrid-mixed-combat-scorecard.json
artifacts/desktop-spikes/godot-salto/v0158/evidence/paired-benchmark-summary.md
```

Acceptance requires Tier L selected-vs-fallback FPS ratio at least `0.90`, Tier L p95 ratio at most `1.15`, no catastrophic 32-Ashen regression, all visual-readability flags passing, and no player-slice mutation. The recorded v0.158 scorecard satisfies those automated gates but does not approve production runtime art.
