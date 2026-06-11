# v0.213 Implementation Report

Status: PASS

v0.213 added a full UI QA harness and documentation for the isolated Salto shell-v2 review path. It did not add visual features, generated images, downloaded assets, imported art slots, browser runtime wiring, default-launcher changes, production-slot enablement, gameplay changes, pathing changes, collision changes, objective changes, AI changes, economy changes, save changes, stable-ID changes, or balance changes.

## Implementation

- Added v0.213 deterministic capture checkpoints to `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`.
- Added npm entry points for full UI QA capture, validation, and benchmark.
- Added Windows PowerShell wrappers for packaged capture, validation, and benchmark flows.
- Added `tools/godot/saltoFullUiQaTool.mjs` to assemble the manual review pack, score boundary state, summarize benchmarks, and validate v0.213 outputs.
- Generated the required manual review PNG pack under `artifacts/manual-review/v0213-full-ui-qa/`.
- Executed safe-only cleanup for known Godot-generated sidecars and preserved required art/evidence.

## Repairs During QA

- The capture and validation wrappers now reuse already completed PASS manifests, avoiding a late-write race in forced fallback scenarios.
- The benchmark wrapper now passes flag arrays as actual argument lists instead of a single quoted bundle, preventing mis-launched packaged Godot processes.
- The boundary checker distinguishes approved existing opt-in art paths from new production-slot leakage.

These repairs are limited to v0.213 harness reliability and do not alter the normal Salto gameplay slice.

## Validation Commands

- `node --check tools/godot/saltoFullUiQaTool.mjs`
- `npm run godot:test`
- `npm run godot:capture:salto-full-ui-qa`
- `npm run godot:benchmark:salto-full-ui-qa`
- `npm run godot:validate:salto-full-ui-qa`
- `node scripts/cleanupSaltoExperimentalArtifacts.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0213/cleanup-dry-run`
- `node scripts/cleanupSaltoExperimentalArtifacts.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0213/cleanup-safe-only --apply-safe-only`
- `node scripts/validateSaltoExperimentalArtifactRetention.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0213/artifact-retention-post-cleanup`
- `node scripts/cleanupSaltoExperimentalArtifacts.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0213/cleanup-final-dry-run`
- `node scripts/cleanupSaltoExperimentalArtifacts.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0213/cleanup-final-safe-only --apply-safe-only`
- `node scripts/cleanupSaltoExperimentalArtifacts.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0213/cleanup-final-postcheck`
- `node scripts/validateSaltoExperimentalArtifactRetention.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0213/artifact-retention-final-post-cleanup`
- `npm run validate:runtime-art-slots`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm test`
- `npm run build`

## Outputs

- `docs/V0213_FULL_UI_QA_SCORECARD.md`
- `docs/V0213_ARTIFACT_HYGIENE_REPORT.md`
- `docs/V0213_IMPLEMENTATION_REPORT.md`
- `artifacts/manual-review/v0213-full-ui-qa/01_gap_note.png`
- `artifacts/manual-review/v0213-full-ui-qa/02_initial.png`
- `artifacts/manual-review/v0213-full-ui-qa/03_aster.png`
- `artifacts/manual-review/v0213-full-ui-qa/04_worker_barracks.png`
- `artifacts/manual-review/v0213-full-ui-qa/05_production.png`
- `artifacts/manual-review/v0213-full-ui-qa/06_objective_log.png`
- `artifacts/manual-review/v0213-full-ui-qa/07_minimap.png`
- `artifacts/manual-review/v0213-full-ui-qa/08_ashen_pressure.png`
- `artifacts/manual-review/v0213-full-ui-qa/09_fallbacks.png`
- `artifacts/manual-review/v0213-full-ui-qa/10_replay.png`
- `artifacts/manual-review/v0213-full-ui-qa/11_resolution_matrix.png`
- `artifacts/manual-review/v0213-full-ui-qa/12_contact_sheet.png`

## Decision

PASS. The v0.213 isolated review path has packaged Windows evidence, benchmark evidence, fallback evidence, safe cleanup evidence, and scope-boundary evidence for checkpoint closeout.
