# v0.150 Implementation Report

Status: implementation and evidence checkpoint for human review.

Implemented:

- Added `GODOT_BARROSAN_BARRACKS_MATERIAL_SEAM_REPAIR_WINDOWS.bat`.
- Added npm scripts under `godot:barracks-material-seam-repair:*`.
- Added deterministic same-source derivative commands to `tools/godot/barracksMaterialSingleSlotTool.mjs`.
- Added private Godot comparator dispatch and `barracks_material_seam_repair_comparator.gd`.
- Added docs `docs/V0150_*`.

Evidence is recorded under ignored `artifacts/desktop-spikes/godot-salto/v0150/` paths.

Final local evidence:

- Selected repair: `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND`
- Selected SHA-256: `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f`
- Gate marker: `PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_GATE`
- Evidence marker: `PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_EVIDENCE_RECORDED`
- Fair-path marker: `PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_FAIR_PATH_AUDIT`
- Screenshot count: `62`
- Benchmark row count: `49`
- Tier L selected FPS ratio: `1.0048`
- Tier L selected p95 frame-time ratio: `0.9681`
- Texture cache entries: `6`
- Material cache entries: `18`

Local closeout commands must still pass before commit and push:

- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run art:reference:init`
- `npm run art:reference:validate`
- `npm run art:reference:contact-sheet`
- `npm run art:reference:review-pack`
- `npm run godot:barracks-material-seam-repair:derivatives:reproduce`
- `npm run godot:barracks-material-seam-repair:validate`
- `npm run godot:barracks-material-seam-repair:audit`
- `npm run godot:barracks-material-seam-repair:benchmark:headed`
- `npm run godot:barracks-material-seam-repair:capture`
- isolation scans
- `git diff --check`

No v0.151 work is part of this checkpoint.
