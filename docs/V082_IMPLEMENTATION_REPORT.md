# v0.82 Implementation Report

Status: runtime prototype implemented and locally verified for checkpoint closeout.

## Scope

v0.82 implements the smallest mission-local Lume Network runtime slice recommended in v0.81.

The prototype is limited to `aether_well_ruins` on `broken_ford` and uses exactly the approved sites and links. It adds one defensive benefit, one HUD row, one selected-site summary, one Results block, focused tests, package inclusion, and docs.

## Runtime Changed

- Added content data in `src/game/data/lumeNetworks.ts`.
- Added validation in `src/game/data/validation/validateLumeNetworks.ts`.
- Added battle-local resolver/director in `src/game/battle/LumeNetworkDirector.ts`.
- Added battle-session Lume telemetry fields to `BattleStats`.
- Added BattleRuntime record/clone helpers for Lume telemetry.
- Added a CombatSystem incoming-damage adjustment hook.
- Wired the director into Aether Well Ruins campaign battles only.
- Added the Lume HUD row to the existing objective panel.
- Added eligible selected-site Lume status to the existing side panel.
- Added a compact Results Lume Network block.
- Added one campaign briefing line for Aether Well Ruins.

## Mission Gate

Lume Network is enabled only when:

- mode: `campaign_node`;
- campaign node: `aether_well_ruins`;
- map: `broken_ford`;
- rewards disabled: false.

It is not enabled in Tutorial, no-reward routes, skirmish, unrelated campaign nodes, or unrelated maps.

## Sites And Links

Eligible sites:

- `west_stone_cut`
- `ford_toll`
- `north_aether_spring`

Links:

- `west_stone_cut_to_ford_toll`
- `ford_toll_to_north_aether_spring`

## Linked Ward

Player-facing name: `Linked Ward`.

Effect:

- Friendly player units and buildings near active linked endpoint sites take 8% less incoming damage.
- Runtime multiplier: `0.92`.
- Non-stacking.
- Battle-local only.
- Removed immediately when the link is no longer active.

## Results And Telemetry

Results shows:

- Lume Network;
- links activated;
- links severed;
- objective completed/incomplete;
- benefit summary;
- after-action telemetry;
- battle-local wording.

Telemetry fields:

- `lumeNetworkId`
- `lumeLinkActivatedIds`
- `lumeLinkSeveredIds`
- `lumeObjectiveCompleted`
- `lumeTelemetryLabels`

## Save Format

No save-version bump.

No hero/campaign save fields were added. Old saves and replay state remain governed by existing systems.

## Tutorial, Replay, AI, Art

- Tutorial/no-reward routes are excluded.
- Replay can show the battle-local Lume objective but cannot duplicate campaign rewards.
- No new AI targeting bump was added.
- No new runtime art/assets were added.
- No desktop packaging, engine, or display-copy migration was started.

## Verification

Focused checks already passed:

```text
npx tsc -p tsconfig.json --noEmit PASS.
npx vitest run src/game/battle/LumeNetworkDirector.test.ts src/game/battle/BattleRuntime.test.ts src/game/systems/CombatSystem.test.ts --reporter=dot PASS.
npx vitest run src/game/data/contentValidation.test.ts src/game/ui/hudPanels/ObjectivePanel.test.ts src/game/ui/hudPanels/SelectedEntityPanel.test.ts src/game/campaign/CampaignPresentationViewModels.test.ts src/game/results/ResultsViewModel.test.ts --reporter=dot PASS.
```

Full v0.82 closeout verification:

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
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 8 tests, including the Aether Well Lume proxy.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 console errors / 0 screenshot retries.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-1e3f94b-dirty` generated.
npm run verify:playtest-package PASS, 251 checks against the dirty pre-commit package.
git diff --check PASS.
```

## Deferred

- v0.83.
- Jardas binding.
- Worker binding.
- Hero binding command.
- Living Mines.
- Race-specific Lume Networks.
- Runtime display-copy migration.
- New AI Lume-target scoring.
- New maps, factions, art, or desktop work.
