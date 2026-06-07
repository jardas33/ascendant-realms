# v0.157 Implementation Report

Status: private comparator implementation and local evidence are complete. Commit, push, and remote confirmation are handled by the checkpoint closeout.

Implemented:

- Preserved the v0.156 Ashen Raider source/cutout as archived comparison evidence.
- Generated exactly one restrained v0.157 Ashen Raider source image.
- Added deterministic v0.157 cutout, fullres, 512, 768, and 1024 derivative tooling.
- Added the private `--ashen-raider-visual-restraint-replacement` Godot dispatch and comparator.
- Added package scripts and the Windows review wrapper.
- Added scaffold guardrail coverage for the v0.157 private path.

Evidence:

- Derivative reproducibility: `PASS_V0157_ASHEN_RAIDER_REPLACEMENT_DERIVATIVES_REPRODUCIBILITY`.
- Validation: `PASS_V0157_ASHEN_RAIDER_REPLACEMENT_VALIDATION`.
- Runtime validation: `PASS_V0157_ASHEN_RAIDER_RESTRAINT_REPLACEMENT_RUNTIME_VALIDATION`.
- Runtime evidence: `PASS_V0157_ASHEN_RAIDER_RESTRAINT_REPLACEMENT_RUNTIME_EVIDENCE`.
- Evidence: `PASS_V0157_ASHEN_RAIDER_REPLACEMENT_EVIDENCE_RECORDED`.
- Gate: `PASS_V0157_ASHEN_RAIDER_REPLACEMENT_SELECTION_GATE`.
- Fair-path audit: `PASS_V0157_ASHEN_RAIDER_REPLACEMENT_FAIR_PATH_AUDIT`.
- Source SHA-256: `f2c96f230534c86f060b04d0580b8b0f797b859dc348ba1a450a97c90eca6954`, dimensions `1024 x 1536`.
- Archived v0.156 source SHA-256: `9eec7bde19bbd698ae3d738c7cb284d570043fe31d220e22e7a00e6ecb344cad`.
- Archived v0.156 cutout SHA-256: `95b9d6dd592e9cb84aff64ae5fb1b73eb80d8bf2b93064260484f3f99514e6ba`.
- Selected derivative: `HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024`.
- Selected SHA-256: `8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8`, dimensions `1024 x 1024`.
- Tier L fallback mean FPS / p95: `1025.21` / `1.26 ms`.
- Tier L archived v0.156 mean FPS / p95: `988.19` / `1.42 ms`.
- Tier L selected mean FPS / p95: `1010.16` / `1.28 ms`.
- Tier L selected-vs-fallback FPS ratio / p95 ratio: `0.9853` / `1.0159`.
- Evidence packet: `37` screenshots, `42` benchmark rows, and `18` aggregate rows under `artifacts/desktop-spikes/godot-salto/v0157/evidence/`.
- Fair-path audit cache posture: `10` texture cache entries, `10` material cache entries, `10` source load entries, one create/load per key, no repeated texture/material creation, and no metadata parsing during steady-state frames.

Boundaries preserved:

- No normal Salto player-slice mutation.
- No browser runtime wiring.
- No sixth runtime-art slot.
- No production import or final art approval.
- Do not begin v0.158.

Human review is pending. The v0.157 replacement is recommended only as the selected private-comparator review candidate, not as approved runtime art.
