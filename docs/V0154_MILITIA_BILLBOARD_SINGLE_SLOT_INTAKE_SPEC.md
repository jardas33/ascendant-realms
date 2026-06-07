# v0.154 Militia Billboard Single-Slot Intake Spec

Status: private comparator-only Militia static billboard intake experiment.

## Scope

- Generate exactly one AI image: `militia_billboard_static_v0154_source.png`.
- Derive one deterministic alpha cutout from that source for private comparator use.
- Add one tracked procedural geometric fallback for fail-closed comparison.
- Use existing selected Aster, Worker, and Barracks private comparator context only.
- Keep Militia as the fourth private comparator runtime-art intake check and add no fifth runtime-art slot.
- Benchmark `HYBRID_MILITIA_DIAGNOSTIC_FALLBACK_BASELINE`, `HYBRID_MILITIA_LOCAL_STATIC_BILLBOARD`, and `ORTHO_MILITIA_PROCEDURAL_FALLBACK`.
- Capture Tier S/M/L evidence, with at least five alternating Tier L trials per approach.

## Gate

- Tier L local average FPS ratio must be at least `0.90` versus fallback.
- Tier L local p95 frame-time ratio must be at most `1.15` versus fallback.
- Militia must remain lower hierarchy than Aster.
- Groups, static formation, rings, alpha, and pivot must remain reviewable.
- No normal Salto player-slice mutation, browser runtime wiring, save change, stable-ID change, manifest mutation, or production approval.

## Commands

```text
npm run godot:militia-billboard:metadata
npm run godot:militia-billboard:fallback:reproduce
npm run godot:militia-billboard:validate
npm run godot:militia-billboard:benchmark:headed
npm run godot:militia-billboard:audit
npm run godot:militia-billboard:capture
```

Human review remains required for final Militia identity, hierarchy, alpha edge, pivot, and group readability judgement.
