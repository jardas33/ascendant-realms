# v0.146 Runtime-Art Pipeline Recommendation

Status: human decision packet for Emmanuel.

## Recommendation

Recommend `HYBRID_3D_WORLD_BILLBOARD_UNITS` for the next carefully bounded single-slot runtime-art experiment, if Emmanuel approves a follow-up milestone.

Reason: it gives Salto the richest terrain, landmark, structure, lighting, and VFX path while keeping units readable at RTS distance and avoiding the full immediate burden of 3D unit animation. It can borrow from the approved reference directions without importing any generated reference image.

## Fallback Comparator

Keep `ORTHO_3D_MESH` as the fallback comparator.

Reason: it has the highest long-term 3D material and animation ceiling, and it remains useful if billboard units prove too flat or directionally ambiguous. It should not receive the next slot first because the unit animation and production burden are too large for a narrow runtime-art experiment.

## Deferred / Rejected For Next Slot

Defer `BILLBOARD_2D_ATLAS` as a fallback comparator only.

Reason: it is readable and cheap, but pure billboard posture weakens Salto terrain and architecture richness and increases future atlas/directional-readability pressure. It is useful evidence, not the best next production-oriented experiment.

## Explicit Boundaries

- This is not final engine selection.
- This is not runtime-art integration approval.
- No generated reference image was imported.
- No downloaded asset was used.
- No production texture, sprite, atlas, model, animation, manifest entry, art-slot assignment, save field, or stable ID was added.
- The normal Salto player-facing slice remains the default human-review path.
- The browser runtime remains preserved.
- v0.147 is not started.

## Human Decision

Emmanuel should decide whether the next single-slot runtime-art experiment should proceed with `HYBRID_3D_WORLD_BILLBOARD_UNITS`, stay in fallback comparison, or pause for more visual review. Any actual runtime-art integration still requires a separate explicit milestone.
