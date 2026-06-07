# v0.155 Militia Billboard Repair Spec

Status: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_GATE`.

v0.155 repairs and fairly benchmarks the existing v0.154 Militia static billboard intake path. It generates zero new AI images, imports no reference candidate, adds no runtime-art slot, adds no fifth runtime-art slot, adds no animation, and derives only deterministic same-source Militia PNG variants from `artifacts/desktop-spikes/godot-salto/v0154/local-militia-slot/militia_billboard_static_v0154_cutout.png`.

Selected derivative: `HYBRID_MILITIA_TRIMMED_1024`.

Selected SHA-256: `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb`.

Derivative root:

```text
artifacts/desktop-spikes/godot-salto/v0155/local-militia-billboard-repair/
```

Evidence root:

```text
artifacts/desktop-spikes/godot-salto/v0155/evidence/
```

Gate results:

- Derivative reproducibility: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_DERIVATIVES_REPRODUCIBILITY`
- Validation: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_VALIDATION`
- Runtime evidence: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_EVIDENCE_RECORDED`
- Selection gate: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_GATE`
- Fair-path audit: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_FAIR_PATH_AUDIT`

The preserved threshold is Tier L average-FPS ratio at least `0.90` and p95 frame-time worsening at most `1.15` versus the private fallback baseline, plus the same threshold for the focused 32-Militia stress tier.

Final selected ratios:

- Tier L selected-vs-fallback FPS ratio: `1.0702`.
- Tier L selected-vs-fallback p95 ratio: `0.9688`.
- 32-Militia stress selected-vs-fallback FPS ratio: `1.0018`.
- 32-Militia stress selected-vs-fallback p95 ratio: `0.9946`.

Required commands:

```text
npm run godot:militia-billboard-repair:derivatives:reproduce
npm run godot:militia-billboard-repair:validate
npm run godot:militia-billboard-repair:benchmark:headed
npm run godot:militia-billboard-repair:audit
npm run godot:militia-billboard-repair:capture
```
