# v0.82 Lume Network Test And Safety Report

Status: focused verification and checkpoint release-gate verification passed locally.

## Safety Model

The Lume Network is battle-local. It does not alter save schema, campaign progression, hero progression, rewards, replay claim state, Tutorial state, art assets, maps, factions, or desktop packaging.

The runtime gate requires:

- `mode === "campaign_node"`
- `campaignNodeId === "aether_well_ruins"`
- `mapId === "broken_ford"`
- `rewardsDisabled !== true`

Tutorial, rewards-disabled, skirmish, scenario, and unrelated campaign battles receive no Lume Network.

## Content Validation

Added validation for:

- unique Lume network ids;
- campaign node existence;
- battle-node attachment;
- map id matching the campaign node;
- eligible site ids existing on the map;
- link endpoints existing and belonging to the eligible site set;
- no self-links;
- duplicate undirected link prevention;
- maximum three eligible sites;
- maximum two links;
- recognized activation and benefit ids;
- explicit Tutorial/no-reward exclusions;
- modest Linked Ward multiplier and non-stacking flag.

## Focused Tests Added

- `src/game/battle/LumeNetworkDirector.test.ts`
- `src/game/battle/BattleRuntime.test.ts`
- `src/game/systems/CombatSystem.test.ts`
- `src/game/data/contentValidation.test.ts`
- `src/game/campaign/CampaignPresentationViewModels.test.ts`
- `src/game/ui/hudPanels/ObjectivePanel.test.ts`
- `src/game/ui/hudPanels/SelectedEntityPanel.test.ts`
- `src/game/results/ResultsViewModel.test.ts`
- `tests/e2e/deep-flow.spec.ts`

## Focused Evidence So Far

```text
npx tsc -p tsconfig.json --noEmit PASS.
npx vitest run src/game/battle/LumeNetworkDirector.test.ts src/game/battle/BattleRuntime.test.ts src/game/systems/CombatSystem.test.ts --reporter=dot PASS, 55 tests.
npx vitest run src/game/data/contentValidation.test.ts src/game/ui/hudPanels/ObjectivePanel.test.ts src/game/ui/hudPanels/SelectedEntityPanel.test.ts src/game/campaign/CampaignPresentationViewModels.test.ts src/game/results/ResultsViewModel.test.ts --reporter=dot PASS, 92 tests.
npx vitest run src/game/battle/LumeNetworkDirector.test.ts src/game/data/contentValidation.test.ts --reporter=dot PASS, 46 tests.
```

Full requested verification:

```text
npm test PASS, 87 files / 654 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npx vitest run src/game/playtest/PlaytestPackageValidation.test.ts --reporter=dot PASS, 1 file / 3 tests.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle PASS, 29 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 8 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 console errors / 0 screenshot retries.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-1e3f94b-dirty` generated.
npm run verify:playtest-package PASS, 251 checks against the dirty pre-commit package.
git diff --check PASS.
```

## Hosted Proxy

Added a hosted deep-campaign proxy:

`Aether Well Lume Network activates, severs, and summarizes in Results @hosted-deep-campaign`

It:

- opens Aether Well Ruins;
- verifies briefing copy;
- starts the campaign battle;
- uses the existing scene test hook to capture `west_stone_cut` and `ford_toll`;
- verifies the HUD row becomes active;
- simulates enemy recapture by using the live `CaptureSite.setOwner` API;
- verifies severed telemetry;
- completes the battle and checks the Results Lume block.

This does not add force clicks or DOM fallback for canvas/world clicks.

## Rollback

Runtime rollback is isolated to:

- `src/game/data/lumeNetworks.ts`
- `src/game/battle/LumeNetworkDirector.ts`
- small hooks in BattleRuntime, BattleScene, BattleSceneSystems, CombatSystem, CampaignNodePanel, HUD panels, Results, and validation.

No save cleanup is required.
