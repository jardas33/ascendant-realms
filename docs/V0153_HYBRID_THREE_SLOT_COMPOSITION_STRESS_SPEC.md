# v0.153 Hybrid Three-Slot Composition Stress Spec

Status: private comparator-only stress gate for the already-selected Worker billboard, Barracks material shell, and Aster billboard paths.

## Scope

- Use zero new AI images.
- Add zero new runtime-art slots.
- Use the selected v0.148 Worker derivative: `HYBRID_WORKER_TRIMMED_1024`.
- Use the selected v0.150 Barracks material repair: `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND`.
- Use the selected v0.152 Aster derivative: `HYBRID_ASTER_TRIMMED_1024`.
- Benchmark `HYBRID_THREE_SLOT_FALLBACK_ONLY`, `HYBRID_THREE_SLOT_SELECTED_LOCAL`, and `ORTHO_THREE_SLOT_PROCEDURAL_FALLBACK`.
- Capture Tier S/M/L evidence, with at least five alternating Tier L trials for every approach.

## Gate

- Tier L selected-local average FPS ratio must be at least `0.90` versus fallback-only hybrid.
- Tier L selected-local p95 frame-time ratio must be at most `1.15` versus fallback-only hybrid.
- Aster and Worker must remain distinct.
- Rings must remain readable.
- No obvious halo, severe seam, severe shimmer, unstable pivot, depth-sort failure, or player-facing mutation.

## Commands

```text
npm run godot:hybrid-three-slot-composition:validate
npm run godot:hybrid-three-slot-composition:benchmark:headed
npm run godot:hybrid-three-slot-composition:audit
npm run godot:hybrid-three-slot-composition:capture
```

Human review remains required for final overlap, seam, shimmer, halo, identity, and composition judgement.
