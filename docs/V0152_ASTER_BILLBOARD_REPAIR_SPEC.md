# v0.152 Aster Billboard Repair Spec

Status: private comparator-only repair pass for the existing v0.151 Aster billboard slot.

## Scope

- Use zero new AI images.
- Use the same v0.151 Aster source and cutout only.
- Generate deterministic same-source comparator variants: full-res, trimmed 512, trimmed 768, and trimmed 1024.
- Benchmark fallback, full-res, 512, 768, and 1024 variants at Tier S, M, and L.
- Run at least five rotated Tier L trials for every benchmarked source.
- Preserve the original Aster acceptance posture: FPS ratio at least 0.90, p95 frame-time worsening no more than 15 percent, hero readability, Worker distinction, no obvious halo, stable pivot, and visible selection ring.

## Non-Scope

- No new runtime-art slot.
- No new Aster AI image.
- No repaint, pose, costume, direction, or animation change.
- No normal Salto player-slice mutation.
- No browser runtime wiring.
- No production approval or final Godot selection.

## Artifacts

- Ignored derivative root: `artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair/`
- Ignored evidence root: `artifacts/desktop-spikes/godot-salto/v0152/evidence/`
- Private comparator: `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd`
- One-click repair wrapper: `GODOT_ASTER_BILLBOARD_SINGLE_SLOT_REPAIR_WINDOWS.bat`

## Commands

```text
npm run godot:aster-billboard-repair:derivatives:reproduce
npm run godot:aster-billboard-repair:validate
npm run godot:aster-billboard-repair:benchmark:headed
npm run godot:aster-billboard-repair:audit
npm run godot:aster-billboard-repair:capture
```

Human review remains required for identity, halo, edge, pivot, and scale feel.
