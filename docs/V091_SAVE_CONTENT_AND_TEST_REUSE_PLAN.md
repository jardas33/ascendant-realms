# v0.91 Save, Content, And Test Reuse Plan

Status: docs-only reuse plan. This document does not change saves, rename IDs, add dependencies, export content, or implement desktop runtime behavior.

## Purpose

The current browser prototype contains valuable content definitions, save-normalization discipline, and automated tests. A future desktop transition should reuse that value deliberately while avoiding silent schema drift or engine-specific rewrites that discard working design evidence.

## Save Reuse Plan

Current facts:

- `CURRENT_SAVE_VERSION` is `2`.
- V1 saves can migrate to V2.
- V2 saves normalize hero, campaign, settings, Retinue, rival, relic, skill, inventory, and campaign state.
- Browser storage is currently localStorage-oriented through the runtime save system.

Future desktop rule:

- Treat current save data as a prototype-compatible source model, not as the final desktop storage implementation.

Recommended future steps:

1. Freeze stable runtime IDs before any translation experiment.
2. Collect representative V1 and V2 fixtures:
   - fresh hero,
   - Act 1 in progress,
   - relic/equipment state,
   - skill tree state,
   - Retinue ready/recovering state,
   - completed/replay campaign state,
   - settings with UI scale/accessibility toggles.
3. Define a desktop save envelope:
   - profile slot,
   - created/updated timestamp,
   - engine/build version,
   - content version,
   - save version,
   - corruption-safe metadata.
4. Write translation tests before any desktop runtime writes saves.
5. Keep unknown IDs safe:
   - unknown content IDs ignored or quarantined,
   - unknown save fields preserved only if intentionally supported,
   - no silent renames.
6. Add import/export policy:
   - browser prototype saves may become import fixtures,
   - desktop saves should use explicit file locations and backup posture.

Do not do now:

- No `CURRENT_SAVE_VERSION` change.
- No save-field migration.
- No desktop save path.
- No profile UI.

## Content Reuse Plan

Current content islands:

- Units, buildings, abilities, upgrades, hero classes, origins, factions.
- Campaign nodes, chapters, rewards, modifiers, mission objectives.
- Relics, skills, Retinue rules, rival rules.
- Enemy doctrines, elite squads, tactical plans, battlefield events.
- Lume network definitions.
- Visual asset manifest and intake metadata.

Recommended future approach:

- Keep TypeScript definitions as the prototype source of truth while the browser remains active.
- Add a future content-export experiment only when an engine candidate needs it.
- Export data to deterministic JSON or an engine-specific import format from existing definitions, not by hand-copying content into a second source.
- Keep stable IDs unchanged across export:
  - map IDs,
  - node IDs,
  - faction IDs,
  - class IDs,
  - unit IDs,
  - building IDs,
  - relic IDs,
  - skill IDs,
  - modifier/event/doctrine IDs.
- Preserve validation:
  - missing references fail,
  - duplicate IDs fail,
  - display-copy changes do not rename serialized IDs.

Do not do now:

- No content-export tool.
- No engine-native database.
- No ID migration.
- No runtime rebrand.

## Test Reuse Plan

Directly reusable tests:

- Pure-rule Vitest coverage for data validation, save normalization, campaign rules, Retinue, results, relics, skills, and presentation view models.
- Deterministic playtest and Act 1 telemetry as design-safety evidence.
- Content and art-intake validation.

Conceptually reusable tests:

- Playwright campaign, battle, Results, layout, and visual QA tests.
- Hosted release lanes.
- Package verification.

Likely replacement or adaptation:

- Browser DOM selectors.
- Phaser canvas-world action helpers.
- Vite private-package launch flow.
- Browser console checks.

Future engine test gate should include:

- Rule/data unit tests that still run outside the engine where possible.
- Engine automation for launch, campaign, battle, Results, settings, and save/load.
- Screenshot or frame capture comparison for desktop viewport acceptance.
- Deterministic battle telemetry or a comparable headless/simulation path.
- Performance benchmark output in machine-readable form.

Do not lose:

- Baseline-first checkpoint discipline.
- Save compatibility tests.
- Reward/replay safety tests.
- Act 1 telemetry.
- Visual QA review rules.
- `git diff --check` and build validation as closeout habits.

## Practical Extraction Seams

Good candidates for future extraction:

- `src/game/data/*`
- `src/game/core/*Rules.ts`
- `src/game/save/SaveNormalization.ts`
- `src/game/save/SaveMigrations.ts`
- `src/game/playtest/*Telemetry*`
- content validation helpers

Risky candidates to copy directly:

- Phaser scenes.
- DOM rendering helpers.
- Browser input handlers.
- CSS layout.
- Package scripts tied to Vite output.
- AssetLoader behavior tied to browser CSS URLs.

## Review Questions Before A Desktop Experiment

- Which content format should the candidate engine consume?
- Can current TypeScript data remain authoritative during the experiment?
- What minimum save fixtures must translate?
- Which tests still run unchanged in CI?
- Which browser e2e tests become acceptance descriptions instead of executable tests?
- What evidence proves the future engine did not break campaign/reward/save safety?
