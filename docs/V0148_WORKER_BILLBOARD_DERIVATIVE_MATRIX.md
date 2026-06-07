# v0.148 Worker Billboard Derivative Matrix

Status: deterministic derivatives generated from the existing ignored v0.147 Worker cutout. These are private comparator-only artifacts and are not tracked production art.

Source-quality comparator:

| Field | Value |
| --- | --- |
| Path | `artifacts/desktop-spikes/godot-salto/v0147/local-worker-slot/worker_billboard_static_v0147.png` |
| SHA-256 | `e294115817821eb84a459f6c86110d7b6951ad34182802bf6b0c07f560cab88a` |
| Dimensions | `1254 x 1254` |
| Pivot | `0.4868, 0.9577` |
| Posture | matte-to-alpha transparent PNG; original chroma source preserved |

Deterministic derivatives:

| Derivative | Dimensions | SHA-256 | Pivot | Alpha-edge green fringe |
| --- | ---: | --- | --- | ---: |
| `worker_billboard_static_v0147_trimmed_512.png` | `512 x 512` | `6cc77a33eb2fb54a36a8b501af3cd89279e12d7f3f03cada2fb296d913b6e884` | `0.5000, 0.9629` | `0` |
| `worker_billboard_static_v0147_trimmed_768.png` | `768 x 768` | `d69f7d6b9aacb5b13a858bc1414a026466ebeae5d22256deb93abda215e848d5` | `0.5000, 0.9635` | `0` |
| `worker_billboard_static_v0147_trimmed_1024.png` | `1024 x 1024` | `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc` | `0.5000, 0.9639` | `0` |

Deterministic operations:

- Alpha-bounds trim.
- Premultiplied-alpha deterministic resize.
- Transparent padding for bottom-center pivot stability.
- Transparent RGB alpha-edge bleed.

Validation command:

```text
npm run godot:worker-billboard-repair:derivatives:reproduce
```

Boundary:

- Generate zero new AI-generated images.
- No existing reference candidate import.
- No production approval.
- No normal Salto player-facing scene mutation.
- No browser runtime wiring.
