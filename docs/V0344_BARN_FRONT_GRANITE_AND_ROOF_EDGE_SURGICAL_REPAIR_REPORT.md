# v0.344 Barn Front Granite and Roof-Edge Surgical Repair

## Outcome

`READY FOR HUMAN V0344 BARN MATERIAL-AND-ROOF VISUAL PREFLIGHT REVIEW`

The five real source renders are visually coherent enough to pass the internal material-and-roof gate. Automated approval remains false; the result is explicitly held for human review.

## Scope and baseline

- Base HEAD: `1fa77d99837861b2b54ba5564b73905b2120226e`
- Branch: `codex/v0215-v0226-recovery`
- v0.343 was preserved byte-for-byte and remains rejected internally as its own checkpoint.
- Frozen House02 Blend: `3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6`
- Frozen House02 GLB: `ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89`
- v0.343 source Blend: `ecb268c7a4f69c914951a0dbd9494fb332003566073b2311b47a348ba9f831e9`
- v0.343 source GLB: `d4d780510b1812e7e4f082f24dfee049ab21f905acbaaeaa4f54d6f67b4118b9`

## Diagnosis

The v0.343 front objects had the correct House02 granite material slot, but copied Blender boxes retained compressed default cube UV charts while the material expected the House02 wall-specific UV contract. On the Y-facing front surfaces this collapsed the granite sample into the pale vertical band seen in the rejected v0.343 renders. The complete binding diagnosis is preserved in `art-source/blender/v0344/v0344-front-material-binding-ledger.json`.

## Repair

- Created a new isolated working copy: `art-source/blender/v0344/v0343_source_duplicate_for_v0344.blend`.
- Assigned one continuous House02 granite material to the front/elevation masonry and applied explicit `V0344GraniteProjectionUV` charts.
- Kept timber limited to doors and subordinate trim; no timber wall sheet was introduced.
- Removed the inherited v0.343 roof system and authored exactly two principal slate slopes, two restrained dark eaves, and one continuous ridge.
- Removed the nonessential verge strips that read as bright/floating roof pieces.
- Preserved doors, openings, rear wall, gables, terrain contact, and scale workers.
- Merged the isolated visual into one render object for a compact prototype: 5 material slots, 1 render object, 1 draw call, 3,336 visible triangles.

## Visual gate evidence

The five renders were made in the temporary neutral-overcast Godot fixture. The front three-quarter and close views show continuous irregular granite across the front wall, while the side/gable view shows the two-slope roof and single ridge without the v0.343 layered roof-system failure. The matched House02 comparison is a true 256x256 crop, not a stretched 16:9 image.

The temporary internal diagnostic modes were generated under `artifacts/runtime/v0344-diagnostics` during capture for normal/albedo-only, normal-disabled, flat-material, and granite-only inspection. They are not part of the human upload pack.

## Source captures

| File | SHA-256 | Bytes | Size |
|---|---|---:|---:|
| `01_front_three_quarter_granite_roof.png` | `f0ba71cf698f76c6155a6e5aa63a5297de262050388591d474b2680838b830cc` | 486562 | 1920x1009 |
| `02_rear_three_quarter_granite_roof.png` | `bb2fb12f71ad09670ea08aa2de7253f773d6c0e4f1110e88f783774ccca3974a` | 431080 | 1920x1009 |
| `03_front_close_granite_continuity.png` | `e8da2d62ed8a996636e0f59f0af895f66348af796dc299f936b06f2f211ffa0e` | 1302357 | 1920x1009 |
| `04_direct_side_gable_roof.png` | `0302b97cff78af426dcebcff5b2fb886a63d53636a17b05a3f94c3f01cac73bf` | 778252 | 1920x1009 |
| `05_house02_barn_matched_true_256.png` | `39c8a9cbaf54b3244a92522b31c67fbb228f91a454a7fa969f699c0ad459b8c1` | 37449 | 256x256 |

## Isolation and preservation

The prototype scene is `desktop-spikes/godot-salto/scenes/review/V0344BarnFrontGraniteRoofEdgeVisualPreflight.tscn`. Capture command: `npm run godot:capture:salto-v0344-barn-front-granite-roof-edge-visual-preflight`. Blender generation command: `npm run blender:generate:salto-v0344-barn-front-granite-roof-edge-visual-preflight`.

The scene is opt-in and prototype-only. It does not instantiate the accepted runtime, change true-default presentation, add gameplay, alter stable IDs/saves, or modify movement, pathfinding, combat, pressure, economy, or resources. The accepted v0.287-v0.343 chain remains untouched. The v0.343 fallback/rejected proof renderer remains available.

## Review pack

The human upload pack is exactly six files at:
`artifacts/manual-review/v0344-barn-front-granite-roof-edge-visual-preflight/UPLOAD_TO_CHAT/`

It contains the read-me, lineage/diagnosis board, unlabelled front/rear board, granite/roof-edge board, matched House02/true-256 board, and compact evidence JSON. No video or technical diagnostic is included.

## Validation

Dedicated command: `npm run godot:validate:salto-v0344-barn-front-granite-roof-edge-visual-preflight`.

The dedicated validator checks frozen and v0.343 hashes, the pre-repair binding ledger, explicit granite UV repair, exactly two roof slopes and one ridge, compact metrics, five nonblank captures, true 256x256 comparison evidence, prototype isolation, the exact human-gate outcome, and the exact six-file upload pack.

The v0.343 validator remains retained and is run separately. Full local validation for this checkpoint includes `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run validate:runtime-art-slots`, `npm run godot:validate:salto-experimental-artifact-retention`, `npm run godot:all`, and `git diff --check`.

## Final state

- Commit: `38b7e3fddd0962816d6ce07a909e69d39e4baa1b`
- GitHub Actions: run `29696310880` — success for the exact SHA.
- Repository: clean and synced with origin, 0 ahead / 0 behind.

<!-- V0344_CAPTURE_LEDGER_JSON
{"captures":[{"fileName":"01_front_three_quarter_granite_roof.png","sha256":"f0ba71cf698f76c6155a6e5aa63a5297de262050388591d474b2680838b830cc","bytes":486562},{"fileName":"02_rear_three_quarter_granite_roof.png","sha256":"bb2fb12f71ad09670ea08aa2de7253f773d6c0e4f1110e88f783774ccca3974a","bytes":431080},{"fileName":"03_front_close_granite_continuity.png","sha256":"e8da2d62ed8a996636e0f59f0af895f66348af796dc299f936b06f2f211ffa0e","bytes":1302357},{"fileName":"04_direct_side_gable_roof.png","sha256":"0302b97cff78af426dcebcff5b2fb886a63d53636a17b05a3f94c3f01cac73bf","bytes":778252},{"fileName":"05_house02_barn_matched_true_256.png","sha256":"39c8a9cbaf54b3244a92522b31c67fbb228f91a454a7fa969f699c0ad459b8c1","bytes":37449,"width":256,"height":256}]}
V0344_CAPTURE_LEDGER_JSON -->
