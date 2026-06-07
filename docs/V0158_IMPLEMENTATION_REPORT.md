# v0.158 Implementation Report

Status: implementation complete and runtime evidence recorded.

Implemented private-only surfaces:

- `--hybrid-mixed-combat-readability-stress` root dispatch.
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/hybrid_mixed_combat_readability_stress_comparator.gd`.
- `tools/godot/hybridMixedCombatReadabilityStressTool.mjs`.
- `GODOT_HYBRID_MIXED_COMBAT_READABILITY_STRESS_WINDOWS.bat`.
- `godot:hybrid-mixed-combat:*` npm scripts.
- v0.158 docs and scaffold coverage.

Human decision encoded:

- The v0.157 restrained Ashen Raider is approved only as the preferred private-comparator hostile direction for this mixed-combat stress gate.
- This is not production approval, final Ashen art approval, player-facing Salto integration, final combat-art approval, animation approval, or final Godot selection.

Evidence root:

```text
artifacts/desktop-spikes/godot-salto/v0158/evidence/
```

Recorded evidence:

- Validation: `PASS_V0158_HYBRID_MIXED_COMBAT_VALIDATION`.
- Fair-path audit: `PASS_V0158_HYBRID_MIXED_COMBAT_FAIR_PATH_AUDIT`.
- Benchmark/capture evidence: `PASS_V0158_HYBRID_MIXED_COMBAT_EVIDENCE_RECORDED`.
- Stress gate: `PASS_V0158_HYBRID_MIXED_COMBAT_STRESS_GATE`.
- Tier L selected-vs-fallback FPS / p95 ratios: `0.9392` / `1.1098`.
- 32-Ashen selected-vs-fallback FPS / p95 ratios: `1.1061` / `0.9154`.
- Screenshots: `47`.

Boundary:

Zero new images, zero new slots, selected five-slot private comparator only, no normal Salto player slice mutation, no browser runtime wiring, no production manifest or art-slot mutation, no save or stable-ID change, and no v0.159 work.
