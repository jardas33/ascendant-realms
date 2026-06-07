# v0.151 Implementation Report

Status: implementation and evidence checkpoint for human review.

Implemented:

- Added `GODOT_ASTER_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat`.
- Added npm scripts under `godot:aster-billboard:*`.
- Added `tools/godot/asterBillboardSingleSlotTool.mjs`.
- Added private Godot comparator dispatch and `aster_billboard_single_slot_comparator.gd`.
- Added tracked diagnostic fallback contract support.
- Added docs `docs/V0151_*`.

Evidence is recorded under ignored `artifacts/desktop-spikes/godot-salto/v0151/` paths.

Final local evidence:

- Gate marker: `PASS_V0151_ASTER_BILLBOARD_SINGLE_SLOT_GATE`
- Evidence marker: `PASS_V0151_ASTER_BILLBOARD_SINGLE_SLOT_EVIDENCE_RECORDED`
- Fair-path marker: `PASS_V0151_ASTER_BILLBOARD_FAIR_PATH_AUDIT`
- Selected approach: `HYBRID_ASTER_LOCAL_STATIC_BILLBOARD`
- Selected SHA-256: `aa1572e26dcbfeaddd0b53c48a2c5e4713ddb35a002af5939f54b271621a3b72`
- Dimensions: `1024 x 1536`
- Tier L local-vs-fallback FPS ratio: `0.9273`
- Tier L local-vs-fallback p95 frame-time ratio: `1.1081`
- Screenshot count: `32`
- Benchmark row count: `35`
- Texture cache entries: `4`
- Material cache entries: `4`
- Exactly one AI-generated image.
- No fourth runtime-art slot.
- No normal Salto player slice mutation.
- No browser runtime wiring.

Local closeout commands must pass before commit and push:

- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run art:reference:init`
- `npm run art:reference:validate`
- `npm run art:reference:contact-sheet`
- `npm run art:reference:review-pack`
- `npm run godot:aster-billboard:metadata`
- `npm run godot:aster-billboard:fallback:reproduce`
- `npm run godot:aster-billboard:validate`
- `npm run godot:aster-billboard:benchmark:headed`
- `npm run godot:aster-billboard:audit`
- `npm run godot:aster-billboard:capture`
- isolation scans
- `git diff --check`

No v0.152 work is part of this checkpoint.
