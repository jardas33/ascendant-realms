# v0.158 Hybrid Mixed Combat Stress Spec

Status: private-comparator-only stress gate for the already-selected five-slot posture. The automated gate recorded `PASS_V0158_HYBRID_MIXED_COMBAT_STRESS_GATE`; human review remains required.

## Scope

- Use zero new AI images.
- Add zero new runtime-art slots.
- Use exactly the selected v0.148 Worker, v0.150 Barracks material, v0.152 Aster, v0.155 Militia, and v0.157 Ashen Raider paths.
- Preserve the archived v0.156 Ashen Raider source and cutout as comparison evidence only.
- Do not modify the normal Salto player-facing slice.
- Do not wire anything into the browser runtime.
- Do not begin v0.159.

## Selected Context

| Role | Approach | SHA-256 |
| --- | --- | --- |
| Worker | `HYBRID_WORKER_TRIMMED_1024` | `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc` |
| Barracks material | `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND` | `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f` |
| Aster | `HYBRID_ASTER_TRIMMED_1024` | `b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a` |
| Militia | `HYBRID_MILITIA_TRIMMED_1024` | `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb` |
| Ashen Raider | `HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024` | `8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8` |

## Scenarios

- `C1_FOUR_ASHEN_WAVE`: Aster, Worker context, friendly Militia squad, one Barracks shell, and exactly four Ashen Raiders.
- `C2_EIGHT_ASHEN_ESCALATION`: same friendly posture with eight Ashen Raiders.
- `C3_SIXTEEN_ASHEN_STRESS`: sixteen Ashen Raiders, multiple Militia, camera pan and zoom stress.
- `C4_THIRTY_TWO_ASHEN_DIAGNOSTIC`: diagnostic 32-hostile crowd, repeated friendly context, and no balance claim.
- `C5`: fallback-only comparison through tracked diagnostic fallback sources.
- `C6`: orthographic procedural 3D fallback comparison.

## Commands

```text
npm run godot:hybrid-mixed-combat:validate
npm run godot:hybrid-mixed-combat:audit
npm run godot:hybrid-mixed-combat:benchmark:headed
npm run godot:hybrid-mixed-combat:capture
```

One-click wrapper:

```text
GODOT_HYBRID_MIXED_COMBAT_READABILITY_STRESS_WINDOWS.bat
```

Passing this gate records the posture as technically promising only. Human review is still required and production integration remains forbidden.

Recorded evidence:

- `PASS_V0158_HYBRID_MIXED_COMBAT_VALIDATION`.
- `PASS_V0158_HYBRID_MIXED_COMBAT_FAIR_PATH_AUDIT`.
- `PASS_V0158_HYBRID_MIXED_COMBAT_EVIDENCE_RECORDED`.
- `PASS_V0158_HYBRID_MIXED_COMBAT_STRESS_GATE`.
- Tier L selected-vs-fallback FPS / p95 ratios: `0.9392` / `1.1098`.
- 32-Ashen selected-vs-fallback FPS / p95 ratios: `1.1061` / `0.9154`.
- Screenshot count: `47`.
