# v0.157 Ashen Raider Paired Benchmark Report

Benchmark command:

`npm run godot:ashen-raider-replacement:benchmark:headed`

Approaches:

- `HYBRID_ASHEN_RAIDER_DIAGNOSTIC_FALLBACK_BASELINE`
- `HYBRID_ASHEN_RAIDER_ARCHIVED_V0156_COMPARISON`
- `HYBRID_ASHEN_RAIDER_V0157_FULL_RES`
- `HYBRID_ASHEN_RAIDER_V0157_TRIMMED_512`
- `HYBRID_ASHEN_RAIDER_V0157_TRIMMED_768`
- `HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024`

Tiers:

- Tier S: one headed trial per approach.
- Tier M: one headed trial per approach.
- Tier L: five headed trials per approach.

Result:

- Evidence: `PASS_V0157_ASHEN_RAIDER_REPLACEMENT_EVIDENCE_RECORDED`.
- Gate: `PASS_V0157_ASHEN_RAIDER_REPLACEMENT_SELECTION_GATE`.
- Selected candidate: `HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024`.
- Selected SHA-256: `8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8`.
- Selected dimensions: `1024 x 1024`.
- Benchmark rows: `42`.
- Aggregate rows: `18`.
- Screenshots: `37`.

Tier L baseline/comparison:

| Approach | Mean FPS | p95 ms | Notes |
| --- | ---: | ---: | --- |
| `HYBRID_ASHEN_RAIDER_DIAGNOSTIC_FALLBACK_BASELINE` | `1025.21` | `1.26` | Tracked fallback baseline. |
| `HYBRID_ASHEN_RAIDER_ARCHIVED_V0156_COMPARISON` | `988.19` | `1.42` | Archived v0.156 comparison evidence only. |

Tier L v0.157 candidates:

| Candidate | Pass | FPS ratio | p95 ratio | Mean FPS | p95 ms | SHA-256 |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| `HYBRID_ASHEN_RAIDER_V0157_FULL_RES` | yes | `0.9708` | `1.0873` | `995.32` | `1.37` | `04c8ee443331acfc953a70de243e421eab924ac54b972c109a8c3a1b3d166fea` |
| `HYBRID_ASHEN_RAIDER_V0157_TRIMMED_512` | yes | `0.9620` | `1.1349` | `986.21` | `1.43` | `138f72fcbd46584f7f9f46b281d8be651e1c02dd9564c918be1bb997f8418102` |
| `HYBRID_ASHEN_RAIDER_V0157_TRIMMED_768` | yes | `0.9501` | `1.1270` | `974.01` | `1.42` | `a34a2e84eb9064bc7114fecc6e7dc91cec8eb38d103d479521df772e72b62573` |
| `HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024` | yes | `0.9853` | `1.0159` | `1010.16` | `1.28` | `8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8` |

Interpretation:

`HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024` is the recommended human-review candidate because it passes the preserved Tier L private gate, preserves readable hostile identity, keeps the weapon silhouette restrained, and keeps the same private billboard render path as fallback and archived v0.156 comparison evidence. This is not runtime-art approval.
