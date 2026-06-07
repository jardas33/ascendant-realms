# v0.158 Hybrid Mixed Combat Fair-Path Audit

Status: `PASS_V0158_HYBRID_MIXED_COMBAT_FAIR_PATH_AUDIT`.

Recorded PASS marker:

```text
PASS_V0158_HYBRID_MIXED_COMBAT_FAIR_PATH_AUDIT
```

The audit requires:

- One-time texture load per selected or fallback source key.
- One-time material creation per source/material key.
- Reuse across all billboard instances.
- No per-frame texture decode.
- No per-frame metadata parse.
- No per-frame derivative generation.
- No repeated material creation during steady-state measurement.
- Initialization measured separately from steady-state frames.
- Equivalent workload semantics across selected local and fallback-only scenarios.
- Hash mismatch and unknown source fail closed.
- No comparator leakage into normal Salto or browser surfaces.

Runtime evidence is written to:

```text
artifacts/desktop-spikes/godot-salto/v0158/evidence/hybrid-mixed-combat-fair-path-audit.json
```

Recorded counters:

- Runtime audit available: true.
- Selected source loads: one per Worker, Barracks, Aster, Militia, and Ashen source key.
- Fallback source loads: one per tracked Worker, Barracks, Aster, Militia, and Ashen fallback key.
- Texture cache entries: `10`.
- Material cache entries: `10`.
- Material reuse count: `40` per selected source/material key and `24` per fallback source/material key.
- No per-frame texture decode, metadata parse, derivative generation, or repeated material creation: true.
- Equivalent workload semantics across selected local and fallback-only scenarios: true.
- Hash mismatch and unknown source fail closed: true.

Boundary posture: private comparator only, zero images, zero slots, no normal Salto player slice mutation, and no browser runtime wiring.
