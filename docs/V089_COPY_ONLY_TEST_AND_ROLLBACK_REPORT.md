# v0.89 Copy-Only Test and Rollback Report

Checkpoint: v0.89 Controlled Display-Copy Migration Batch A

## Risk Model

This is a display-copy-only runtime milestone. It does not alter saves, reward math, battle stats, map content, campaign progression, stable IDs, runtime title, class IDs, resource keys, or package folder naming.

## Regression Guards Added

- Content validation asserts:
  - `free_marches` still exists and displays as Barrosan Freeholds.
  - `sylvan_concord` still exists and displays as Rootbound Concord.
  - `border_marches` still exists and displays as Chapter 1: The Barrosan Marches.
  - `border_village` still exists and displays as Salto Outskirts.
  - `mission_aether_surge` and `aether_surge` still use stable IDs while displaying Lume Surge.
  - `Aether`, `Aether Well Ruins`, `Aether Lens`, `Aether Flow`, `Mana`, and `CURRENT_SAVE_VERSION` remain preserved.
- Existing campaign, results, e2e, and visual QA expectations were updated to the new approved visible copy.
- Existing save-fixture tests remain part of `npm test`.

## Rollback Plan

If v0.89 needs rollback, revert only the v0.89 commit. Because no save or gameplay schema changed, old and current saves remain compatible with either side of the rollback. Package rollback is selecting the previous clean package.

## Verification Status

Post-fix verification evidence is recorded in `docs/V089_IMPLEMENTATION_REPORT.md`. The full matrix confirms the copy-only migration did not change save schema, reward logic, campaign flow, replay safety, Tutorial safety, combat balance, controls, Act 1 telemetry, hosted release lanes, or visual QA coverage.

One hosted deep-battle rerun exposed a pre-existing readability conflict where a battlefield event status line could obscure active building-placement copy. v0.89 fixed that as presentation priority only: while a building ghost is active, the HUD status line shows the placement instruction and the event remains available through event/objective UI. The exact failing hosted test and the full hosted deep-battle lane passed after the fix.
