# Tutorial Playable Shell Report

Date: 2026-05-08

Status: first playable Tutorial / Proving Grounds shell implemented with existing content only.

## Summary

Tutorial / Proving Grounds is now a playable no-reward onboarding shell. It launches from the main menu, reuses the existing First Claim battlefield and existing Aster/Warlord content, shows a lightweight objective overlay, progresses through twelve guided steps, and returns to the main menu on completion or exit.

This is a tutorial shell, not a campaign expansion. It does not add maps, units, factions, workers, enemy construction, crafting, diplomacy, procedural generation, rewards, campaign nodes, save-version changes, persisted tutorial completion, desktop packaging, external assets, or broad systems.

## What Was Implemented

- Main-menu `Tutorial` launch surface.
- Tutorial metadata upgraded to a validated playable no-reward definition.
- `tutorial` battle launch mode with `rewardsDisabled: true`.
- Transient tutorial hero launch data using existing Warlord Aster.
- BattleScene tutorial-mode integration that reuses existing First Claim systems.
- Lightweight HUD tutorial overlay with current objective, instruction, hint, progress, completion condition, Next Objective, Complete Tutorial, and Exit Tutorial.
- Pure tutorial step/view-model helpers for step lookup, progress labels, completion labels, and linear next-step transitions.
- Live tutorial completion signals for hero selection, hero movement, capture site ownership, resource income, building selection, Barracks construction, Militia training, rally point setting, Rally Banner use, safe Raider pressure, and finish.
- No-reward runtime completion path that returns the starting hero data, zero XP, and empty rewards.
- XP/veterancy guard for rewards-disabled tutorial kills.
- Direct main-menu return on tutorial completion and exit.
- Smoke, layout, unit, content-validation, and save-persistence coverage.

## What Was Not Implemented

- No new tutorial map.
- No new tutorial units, buildings, abilities, factions, enemies, art, audio, or assets.
- No campaign rewards, tutorial rewards, XP, items, campaign resources, or campaign node completion.
- No persisted tutorial-completed flag.
- No save-version bump.
- No ResultsScene reward screen for tutorial completion.
- No tutorial branching, voiceover, cinematics, cutscenes, quest system, or asset-heavy tutorial panels.
- No workers, enemy construction, diplomacy, procedural generation, crafting, durability, multiplayer, monetization, desktop packaging, or broad army-management systems.

## Launch Path

The tutorial is launched from the main menu through the `Tutorial` button (`data-testid="menu-tutorial"`). It is independent of New Campaign, Continue Campaign, Skirmish Setup, Hero Inventory, and campaign progression.

The launch creates a tutorial `BattleLaunchRequest` for:

- Mode: `tutorial`.
- Source: `proving_grounds_basics`.
- Map: `first_claim`.
- Difficulty: Story.
- Rewards disabled: true.
- Hero: transient existing Warlord Aster data.

## Reused Content

- Existing map: `first_claim`.
- Existing hero class and ability: Warlord with `rally_banner`.
- Existing player building chain: Command Hall and Barracks.
- Existing trainable unit: Militia.
- Existing capture site: Crown Shrine.
- Existing battle resources: Crowns, Stone, Iron, Aether.
- Existing enemy pressure unit: Raider.
- Existing BattleScene, HUD, resource, capture, building, training, rally, combat, and ability systems.

## Tutorial Steps

1. Camera Controls.
2. Select Hero.
3. Move Hero.
4. Capture Crown Shrine.
5. Gather Resources.
6. Select Command Hall.
7. Build Barracks.
8. Train Militia.
9. Set Rally Point.
10. Use Hero Ability.
11. Hold Safe Pressure.
12. Finish Training.

The shell is linear by design. It does not branch, skip into campaign, or unlock future content.

## No-Reward Policy

Tutorial / Proving Grounds is a training mode. It must not award:

- Hero XP.
- Skill points.
- Items or item instances.
- Campaign resources.
- Campaign node rewards.
- Retinue entries.
- Rival rewards or trophies.
- Reputation changes.
- Stronghold changes.

The final overlay step explicitly tells the player that no rewards or campaign progress were granted. Current e2e coverage checks that tutorial completion and exit do not create a save, and the safe-pressure step does not grant hero XP or runtime XP.

## Save And Persistence Policy

The current shell is non-persistent:

- It does not create a hero save.
- It does not write campaign progress.
- It does not write inventory, equipment, XP, skills, resources, event choices, town services, Stronghold upgrades, retinue, rivals, or trophies.
- It does not write settings.
- It does not bump the save version.

If future work wants a tutorial-completed flag, it should be a separate save-compatibility phase with fixture coverage and an explicit reason. It must still avoid rewards and campaign progression.

## Tests Added

- Tutorial metadata validation and failure tests in `src/game/data/contentValidation.test.ts`.
- Tutorial launch/no-reward request tests in `src/game/battle/BattleLaunchRequest.test.ts`.
- Tutorial no-reward runtime completion tests in `src/game/battle/BattleRuntime.test.ts`.
- Tutorial step/view-model unit tests in `src/game/tutorial/TutorialStepModel.test.ts`.
- Tutorial overlay render tests in `src/game/ui/hudPanels/TutorialPanel.test.ts`.
- Smoke e2e coverage for full twelve-step tutorial completion, no-save/no-XP behavior, and tutorial exit.
- Layout e2e coverage for Tutorial entry and first overlay reachability across desktop, tablet-short, mobile-tall, and mobile-short viewports.

## E2E Lane Impact

- Smoke lane: 12 tests, latest Phase 12 run passed in 4.8m. The full tutorial completion path remains in smoke for now because it protects the first onboarding vertical slice and verifies no save, no XP, no campaign reward, and no campaign progression pollution.
- Layout lane: 25 tests after adding four tutorial overlay viewport checks; latest Phase 11 full layout run passed in 13.1m.
- Expected full release lane: 65 tests after the Phase 11 layout guard. The final full gate should refresh exact release and shard runtimes.

If smoke runtime grows materially beyond the current 6-7 minute range, move the deeper twelve-step tutorial completion path into deep/release coverage and keep only launch/exit in smoke.

## Known Risks

- The tutorial is twelve steps long and may feel slow in human-paced play.
- The mobile-short overlay is width-safe and scrollable, but it should still be human-reviewed on a real device-sized viewport.
- Completion returns directly to the main menu; some players may miss the no-reward completion message if they click quickly.
- The safe-pressure step is intentionally small and may still rely on stable existing Raider behavior.
- The tutorial overlay shares the battle HUD space, so future HUD additions could crowd it.
- Smoke/release runtime increased and should be watched before adding more tutorial e2e depth.

## Next Recommended Improvement

Run a human-paced Tutorial / Proving Grounds playtest in a browser:

- Confirm the twelve-step length feels acceptable.
- Confirm building/training/rally timing is understandable without test hooks.
- Confirm mobile-short overlay readability.
- Confirm no-reward completion is clear before the return to menu.
- Collect any copy tightening needed before adding new tutorial steps.

After that, the safest implementation follow-up is a small tutorial polish pass: clearer hints, optional completion toast, and layout tightening only. Do not add content, rewards, maps, units, factions, or save persistence before that human review.

## Explicitly Postponed Systems

- Workers.
- Enemy construction or rebuilding.
- New factions.
- New maps.
- New units.
- Campaign reward expansion.
- Tutorial rewards.
- Tutorial save persistence.
- Diplomacy.
- Procedural generation.
- Crafting, durability, and affix rerolling.
- Broad loot complexity.
- Full trophy rooms.
- Broad army management.
- Multiplayer.
- Desktop packaging.
- External generated assets.

## Phase 12 Verification

```text
npm test
PASS: 42 test files, 315 tests.

npm run build
PASS: TypeScript compile and Vite production build.
App JS: assets/index-BArZgVc-.js, 459.27 kB / gzip 123.49 kB.
Vendor JS: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB.
CSS: assets/index-EaFx5BCM.css, 43.77 kB / gzip 9.02 kB.
Known Phaser vendor chunk warning remains.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 4.8m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.
Telemetry regenerated with no git diff.
```
