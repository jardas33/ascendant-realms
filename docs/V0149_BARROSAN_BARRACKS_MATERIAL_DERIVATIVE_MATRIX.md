# v0.149 Barracks Material Derivative Matrix

Status: deterministic derivatives generated from the single ignored v0.149 material source.

Source:

| Field | Value |
| --- | --- |
| Path | `artifacts/desktop-spikes/godot-salto/v0149/local-barracks-material-slot/barrosan_barracks_material_v0149_source.png` |
| SHA-256 | `bd07ef2179dde28161a1c32624eac9efd253de7956c4455e992cb716eb367c6c` |
| Dimensions | `1254 x 1254` |
| Posture | original generated material source, ignored, private comparator-only |

Deterministic derivatives:

| Derivative | Dimensions | SHA-256 | UV scale | Tiling |
| --- | ---: | --- | ---: | --- |
| `barrosan_barracks_material_v0149_512.png` | `512 x 512` | `bb4fbe0ff9a18066dc969b9d8f6f721040161575fd0c1b60d24722f67b007199` | `1.15` | repeat comparator material |
| `barrosan_barracks_material_v0149_768.png` | `768 x 768` | `2731c342024271b2babaac8681d33f060df83e30c47ce56722f9595cd8004ce3` | `1.05` | repeat comparator material |
| `barrosan_barracks_material_v0149_1024.png` | `1024 x 1024` | `913af0ca774c7ab02e12173f7be8d0144b18273c44bcc0c7360520823d22b090` | `1.00` | repeat comparator material |

Deterministic operations:

- Square-preserving resize.
- sRGB opaque PNG output.
- Script-recorded metadata.
- No subjective manual editing.
- No normal, roughness, metallic, or emissive map generation.

Validation command:

```text
npm run godot:barracks-material:derivatives:reproduce
```

Final recommendation:

```text
HYBRID_BARRACKS_LOCAL_768
```

The `768 x 768` derivative is recommended for human review because it is the highest-resolution derivative that passed both preserved Tier L thresholds in the final capture. The `512` derivative missed both thresholds, and the `1024` derivative passed p95 but missed the average-FPS threshold.

Boundary:

- Exactly one AI-generated source image.
- Deterministic scripted derivatives only.
- No existing reference candidate import.
- No production approval.
- No normal Salto player-facing scene mutation.
- No browser runtime wiring.
