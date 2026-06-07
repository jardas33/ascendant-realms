# V0159 First-Slot Decision Scorecard

Status: decision packet only. Higher scores are safer or more useful for the first player-facing opt-in proof. The scorecard chooses a first candidate for a future v0.160 contract; it does not integrate art in v0.159.

| Candidate | Technical maturity | Visual-review maturity | Player-facing risk | Reversibility | Gameplay exposure | Hierarchy risk | Fallback simplicity | Benchmark evidence | Pipeline value | First-proof usefulness | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Worker `HYBRID_WORKER_TRIMMED_1024` | 5 | 4 | 5 | 5 | 4 | 5 | 5 | 5 | 5 | 5 | 48 |
| Barracks `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND` | 4 | 3 | 3 | 4 | 3 | 4 | 4 | 4 | 4 | 3 | 35 |
| Militia `HYBRID_MILITIA_TRIMMED_1024` | 4 | 3 | 2 | 4 | 2 | 3 | 4 | 5 | 4 | 3 | 33 |
| Aster `HYBRID_ASTER_TRIMMED_1024` | 4 | 3 | 2 | 4 | 2 | 2 | 4 | 4 | 4 | 3 | 32 |
| Ashen Raider `HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024` | 4 | 3 | 2 | 4 | 2 | 2 | 4 | 4 | 4 | 3 | 32 |

## Selected First Slot

Selected future v0.160 first slot:

- Slot: `worker_billboard_static_v0147`.
- Derivative: `HYBRID_WORKER_TRIMMED_1024`.
- SHA-256: `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Future use: Godot player-facing Salto review slice only, behind a new opt-in experimental launcher.

## Rationale

Worker should be first because it tests the integration mechanics where the project most needs early proof: static billboard loading, hash-gated local file intake, scale, pivot, selection ring alignment, repeated-unit readability, and fallback behavior. It avoids the higher review cost of touching Aster hero identity, hostile Ashen combat readability, Militia mass-overlap combat clarity, or Barracks world-material permanence as the first player-facing crossing.

## Candidate Notes

Worker has the best combination of reversibility and signal. If the local image is missing, corrupt, or hash-mismatched, the procedural Worker fallback remains understandable and already validated.

Barracks is valuable, but material integration carries world-surface tiling, lighting, and package-leakage risk that is better tested after one billboard slot proves the intake controls.

Aster carries hero-identity risk and should wait until the pipeline has proven that opt-in loading cannot confuse the default stabilized slice.

Militia and Ashen Raider are combat-readability candidates. They should wait until first-slot integration proves fallback behavior, packaging boundaries, and review capture discipline.
