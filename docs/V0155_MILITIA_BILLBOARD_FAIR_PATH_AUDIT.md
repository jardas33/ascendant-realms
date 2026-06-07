# v0.155 Militia Billboard Fair-Path Audit

Status: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_FAIR_PATH_AUDIT`.

Runtime audit proof:

- Selected derivatives and fallback share the same private Militia billboard render path.
- Texture cache entries: `8`.
- Material cache entries: `8`.
- Every selected/context/fallback source is loaded once.
- Every selected/context/fallback material key is created once and then reused.
- No repeated texture creation during steady-state frames.
- No repeated material creation during steady-state frames.
- Metadata parsing during steady-state frames: `false`.
- Initialization and warmup are excluded from measured frames.

Boundary proof:

- Zero new AI images for v0.155.
- Same v0.154 Militia source only.
- No new runtime-art slot.
- No fifth runtime-art slot.
- No animations.
- No normal Salto player-slice mutation.
- No browser runtime wiring.
- No production package, save path, stable ID, manifest, or art-slot registry mutation.

Audit JSON:

```text
artifacts/desktop-spikes/godot-salto/v0155/evidence/militia-billboard-repair-fair-path-audit.json
```
