# v0.155 Implementation Report

Status: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_GATE`.

Implemented scope:

- Extended the existing private Militia comparator with a v0.155 mass-overlap repair mode.
- Added private root dispatch for `--militia-billboard-mass-overlap-repair`.
- Added deterministic same-source Militia derivatives for full-res, 512, 768, and 1024.
- Added v0.155 private wrappers, package scripts, validation, scorecard, visual review, and fair-path audit docs.
- Tightened v0.155 PowerShell wrappers so Node tool failures stop the command immediately.

Evidence:

- Derivative reproducibility: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_DERIVATIVES_REPRODUCIBILITY`
- Validation: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_VALIDATION`
- Runtime evidence: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_EVIDENCE_RECORDED`
- Gate: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_GATE`
- Fair-path audit: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_FAIR_PATH_AUDIT`
- Selected derivative: `HYBRID_MILITIA_TRIMMED_1024`
- Selected SHA-256: `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb`
- Tier L ratio / p95 ratio: `1.0702` / `0.9688`
- 32-Militia stress ratio / p95 ratio: `1.0018` / `0.9946`
- Screenshots / benchmark rows: `36` / `60`

Boundary:

Zero new AI images, same v0.154 Militia source only, no new runtime-art slot, no fifth runtime-art slot, no animations, no normal Salto player slice mutation, no browser runtime wiring, no production package mutation, no save or stable-ID mutation, and No v0.156 work.
