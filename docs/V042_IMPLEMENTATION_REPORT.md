# v0.42 Mission Variety Foundation Implementation Report

Date: 2026-05-28

## Scope

v0.42 adds mission-type metadata to existing campaign battle nodes. The work uses current maps, objectives, rewards, campaign UI, Results UI, and hero build identity copy. It does not add new maps, factions, runtime art/assets, a quest journal, or new win-condition mechanics.

## Mission Types

Initial mission types are data-driven in `src/game/data/missionTypes.ts`:

- Assault: enemy base, commander, or fortified position pressure.
- Control: resource-site and economy contest emphasis.
- Defense: protect the base, hold pressure, then counterattack.
- Skirmish / Training: basic low-noise early battle route.

Every current campaign battle node now declares a mission type and compact briefing metadata. Story, town, shrine, and event nodes remain unchanged.

## Campaign UI

Campaign selected-node details now show:

- mission type;
- concise briefing;
- primary objective;
- scenario modifier names and effect summaries;
- reward preview;
- recommended build hint where useful;
- existing first-clear/replay reward and optional-objective state.

## Save Format

No save-version bump. Mission type, briefing, reward-preview, and pacing metadata are content-driven and are not stored in saves. Existing v0.39-v0.41 completion, replay, reward-claim, and optional-objective save state remains intact.

## Verification

Focused verification completed:

```text
npx tsc -p tsconfig.json --noEmit PASS.
npm run validate:content PASS.
npx vitest run src/game/data/campaignModifiers.test.ts src/game/core/CampaignRules.test.ts src/game/campaign/CampaignPresentationViewModels.test.ts src/game/results/ResultsViewModel.test.ts PASS, 4 files / 71 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Ashen Outpost special objectives|Old Stone Road victory" --reporter=line PASS after a fresh build, 2 hosted tests.
```

Full checkpoint verification is recorded in `LLM_GAME_HANDOFF.md`, `DEVELOPMENT_CHECKPOINT.md`, and `docs/V044_IMPLEMENTATION_REPORT.md`.

## Deferrals

- New mission maps.
- Dynamic mission branching.
- Full campaign journal.
- Mission scoring ranks or medals.
