# v0.430 — Tesana Full-Source Canonical Production Rebase

## Executive result

v0.430 rehabilitates a complete Tesana Godot export into a separately named, production-facing copy without changing the accepted Ascendant Realms runtime or the original immutable export. The copy is import-clean, source-preserving, explicitly validated, and exercised through real headed runtime flows. This is a production candidate and evidence checkpoint; it does not silently merge a new default runtime.

## Scope and safety

- Branch: `codex/v0430-tesana-canonical-production-rebase`
- Canonical repository: `D:/Code for projects/WB game like/ascendant-realms-v0223-recovery`
- Accepted base: `4a2de384b2f0c3f348f24ff549ab2293f29e3b7f`
- Original immutable source: `D:/Code for projects/WB game like/WB_tesana`
- Production copy: `production/ascendant-realms-godot/`
- No v0.431 work is included.
- The paused-work audit found no tracked interrupted v0.430 implementation to restore and no safety branch was required.

The original export was copied without modifying `WB_tesana`. Its generated `.qa/` bucket remains physically present in the original source but is excluded by the source ignore policy as generated QA output; this is recorded explicitly rather than treated as source loss.

## Rights and provenance basis

The project owner declaration recorded for this checkpoint is:

> Emmanuel confirms that Ascendant Realms was created and exported from Tesana while his account had an active Pro paid subscription. It is his own Ascendant Realms project. He intends to use, modify, develop, publish and commercially distribute the exported game, source code and included assets.

The official reference set is recorded in `docs/legal/TESANA_PRO_PAID_PLAN_RIGHTS_BASIS.md` and the review pack snapshots:

- https://tesana.ai/en/terms
- https://docs.tesana.ai/building/exports
- https://docs.tesana.ai/support/faq
- https://docs.tesana.ai/building/remixing

The export is treated as the canonical source intake for this production candidate. No protected third-party game asset was imported during the rebase; the source asset set is preserved and catalogued with SHA-256 records.

## Source and production inventory

The immutable source audit found 628 files / 85,283,160 bytes, including 75 GLB, 19 PNG, 120 JPG, 40 GDScript, 10 scenes, 45 TRES, 14 MP3, one TTF, two shaders, 231 import sidecars and two webp files. The physical production copy is 632 files / 85,520,384 bytes after adding the production validator, gallery, catalog and evidence support. The version-controlled production source intentionally excludes generated `.qa/` logs while retaining raw assets and their import sidecars.

The source-preservation audit reports zero source drift. `project.godot` remains Godot 4.3, retains `scenes/main.tscn` as the production entry scene, and has no automatic `TesanaWorldEditor` autoload. The editor addon source remains present for explicit editor use; removing only the production autoload prevents loopback services from starting in the standalone player copy.

## Import, runtime and asset validation

Godot `4.3.stable.official.77dcf97d8` was used. Three import passes were completed; the final pass is stable. The dedicated headless resource scan reports 75 GLB, 141 textures, 14 audio files and one font with zero import-sidecar gaps and zero blocking load failures. The initial scanner's source-GDScript parse noise was removed from the resource scan because it was not a resource import failure; the corrected scan is the retained result.

Real headed runtime evidence covers:

- title screen and clean menu launch;
- Skirmish setup, with race and battlefield selection frames;
- Begin Battle into the actual gameplay map;
- worker selected and worker moved;
- build menu / placement state;
- Campaign map and first campaign node;
- Hero and Settings screens;
- clean headless exit and no Tesana editor listener startup.

The gameplay frame is a real 1920x1080 render, not a title card. Its presentation has a known washed-out/high-value lighting issue in the map scene; this is recorded as a visual QA limitation, not hidden by synthetic evidence. Menu and campaign views are materially stronger and the actual gameplay state, units, structures, minimap and HUD are visible.

## Review pack

`artifacts/manual-review/v0430-tesana-canonical-production-rebase/`

The pack contains the 18 required named production captures, real runtime and source-asset contact sheets, source/production manifest comparison, import logs, network audit, runtime flow matrix, asset-load scan, rights basis, repair log, branding audit, performance observation, readiness validator output and runtime-error report. The runtime contact sheet is composed from real local frames. The asset galleries are composed from the actual exported source textures and are labeled as source-asset galleries, not gameplay screenshots. The black-frame/title-card rejection condition is satisfied for the player-facing runtime frames.

Key files:

- `01_PRODUCTION_TITLE_SCREEN.png` through `13_PRODUCTION_SETTINGS_SCREEN.png`
- `14_PRODUCTION_ASSET_GALLERY_UNITS.png`
- `15_PRODUCTION_ASSET_GALLERY_BUILDINGS.png`
- `16_PRODUCTION_RUNTIME_CONTACT_SHEET.png`
- `17_PRODUCTION_ASSET_CONTACT_SHEET.png`
- `18_ORIGINAL_EXPORT_PRODUCTION_COPY_HASH_COMPARISON.png`
- `v0430-source-preservation-audit.json`
- `v0430-runtime-flow-matrix.json`
- `v0430-production-readiness.json`
- `v0430-asset-load-scan.json`
- `v0430-runtime-errors.txt`

## Tooling and commands

- Launch headed production: `npm run godot:play:production`
- Import production copy: `npm run godot:import:production`
- Headless production smoke: `npm run godot:smoke:production`
- Canonical production validator: `npm run godot:validate:production`
- Catalog and import-sidecar scan: `npm run godot:asset-scan:production`
- Tool source: `tools/godot/tesanaProductionTool.mjs`
- Capture/contact-sheet helper: `tools/godot/buildV0430ContactSheets.ps1`

The validator fails closed on missing production paths, missing main scene, wrong engine feature, an automatic editor-service autoload, source drift, or missing raw export assets. The source catalog and evidence files make the intake auditable without changing gameplay code.

## What changed

1. Added a canonical production copy of the complete Tesana export.
2. Added the rights/provenance record and official documentation snapshots.
3. Removed the editor-service autoload from the production copy only.
4. Added explicit production launch/import/smoke/validate/asset-scan commands.
5. Added headless GLB/texture/audio/font resource-load validation.
6. Added a deterministic source catalog and production readiness validator.
7. Added an opt-in source-asset gallery scene not referenced by the production main scene.
8. Added real runtime evidence and contact sheets.

## What did not change

The accepted Phaser/runtime gameplay implementation, stable IDs, saves, economy, resources, pressure behavior, movement, pathfinding, combat, AI and default runtime were not modified by this checkpoint. The original export remains immutable. No Tesana editor service is started automatically by the production copy, and no deployment or publishing action was performed.

## Known limitations and recommendation

The gameplay map currently renders with excessive high-value/washed-out lighting compared with the title and campaign screens. Race/battlefield changes are captured as observed selection states rather than claimed as a full visible semantic redesign. FPS, memory and minimum-frame instrumentation were not available in this checkpoint; the performance observation records that limitation honestly. These are reasons to treat this as a rehabilitated production candidate requiring a deliberate visual/runtime stabilization decision, not as an automatic final adoption.

Recommended next decision: a separately scoped production-candidate stabilization checkpoint focused on gameplay-scene lighting/value calibration and explicit runtime-flow assertions, after reviewing this pack. No v0.431 implementation is started here.

## Validation evidence

The dedicated production validator, corrected asset scan, Godot import/smoke checks, repository tests/build/content/art/runtime/artifact-retention checks, `npm run godot:all`, and `git diff --check` are required before the closeout commit. Exact commit and Actions results are appended to this report at closeout so the document remains tied to the pushed SHA.

## Final state target

The checkpoint is complete only when the scoped v0.430 commits are pushed, the exact pushed SHA's GitHub Actions run is successful, and the intentional historical untracked backlog remains untouched. The final handoff reports the tracked worktree state separately from that preserved backlog.

## Closeout evidence

- Production intake commit: `c73629648b1270b0e5458c74c4359545e9fc514e`
- Production tooling commit: `9fdc4592`
- Evidence/report commit before this closeout appendix: `9d66f47b`
- Validation-record commit: `a0ba25131ed96f5f30cc2fdbc482e7799e2087ba`
- Exact-SHA GitHub Actions: run `30481447624` — success for `a0ba25131ed96f5f30cc2fdbc482e7799e2087ba`
- Draft PR: https://github.com/jardas33/ascendant-realms/pull/4

The tracked working tree was clean after the validation-record commit. The checkout also contains a pre-existing, intentionally preserved untracked historical artifact backlog outside the v0.430 scope; it was not staged, deleted, or rewritten. The production branch is pushed with upstream tracking and the scoped commits are synchronized with origin.
