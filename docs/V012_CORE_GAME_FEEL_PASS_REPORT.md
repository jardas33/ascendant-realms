# v0.12 Core Game Feel Pass Report

Date: 2026-05-16

Scope: v0.12 Core Game Feel and Battle Readability Pass. This was a player-facing readability/feedback pass after the v0.11.12 hosted release matrix green closeout. It was not CI plumbing, not an art overhaul, not a faction/content expansion, not a save migration, and not a broad AI rewrite.

## Green-State Rules Preserved

- Final remote green truth remains GitHub Actions `CI Release Matrix Dry Run #39` on commit `dadb241`.
- Hosted release groups still use `playwright.hosted-release.config.ts` and `npm run preview:hosted`.
- Local full release lanes remain separate.
- `clickReady` was not replaced with force clicks.
- Canvas/world clicks still avoid DOM fallback.
- Moving, minimap, no-save/no-reward tutorial, battle command, side-panel reachability, settings runtime-application, and hosted release assertions were not weakened.
- Tutorial smoke semantic advancement was not turned back into raw `tutorial-next` click chains.

## Audits Created

- `docs/V012_CORE_GAME_FEEL_AUDIT.md`
- `docs/V012_BATTLE_READABILITY_AUDIT.md`

The audits found that the existing slice already had useful foundations: selected rings, selected panels, order summaries, command buttons, objective rows, pressure priority, minimap pings, floating damage, and results summaries. The highest-value v0.12 fixes were wording, hierarchy, read windows, and acknowledgement timing.

## Implemented Changes

### Selection Clarity

- Multi-selection now starts with a selected-count block and `Commands apply to this group.`
- Multi-unit order summaries are labeled `Current Orders`.
- The side-panel order-summary treatment is visually stronger through existing CSS only.
- Objective rows and order summaries keep stable DOM/test IDs.

### Command Feedback

- Added a `command` battle-status priority between routine `normal` messages and `pressure`/`objective`.
- Command acknowledgements get a longer read window than routine income/status messages but remain below pressure and objective warnings.
- Valid movement, attack, attack-move, rally, build placement, training, research, ability cast/failure, and path-failure feedback now uses command-priority status where appropriate.
- Resource income can no longer immediately bury accepted command feedback.
- Impossible or blocked train/research/build actions now name the specific issue more clearly, such as `Not enough resources for Militia`.

### Combat Readability

- Ability success/failure messages now use command-priority feedback, so casts such as Cleave, War Cry, Blink, healing, and no-target/mana/cooldown feedback are easier to read.
- Floating damage thresholds and status effect rules were deliberately unchanged to avoid spam and preserve reduced-motion/accessibility behavior.
- Results defeat guidance now points the player toward rebuilding economy, production, and grouped attacks instead of only saying rewards were not saved.

### Objective Clarity

- Objective tracker now marks the first unfinished objective as `Next`; later unfinished objectives remain `Open`.
- Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch objective copy now says what to do and why in shorter language.
- Cinder Shrine, Watch Road, Burned Shrine, Cinder Guardians, and Watchtower sequencing now read more like actionable battlefield guidance.

### Enemy Pressure Readability

- Cinderfen pressure warnings now include player counterplay while preserving the existing warning-only / telemetry-only scope.
- The implementation did not add enemy workers, construction, harvesting, economy AI, route contest behavior, defensive holds, or live reinforcement systems.
- Exact pressure warning tests were updated to protect the new copy and priority behavior.

### Victory / Defeat Feedback

- Defeat status now directs the player to Defeat Tips and clearer retry planning.
- Results guidance for defeat now emphasizes economy, production, holding after waves, and attacking with a larger grouped army.
- Reward/save logic is unchanged.

### Tutorial Usefulness

- No tutorial persistence, rewards, save changes, or new tutorial flow were added.
- Existing tutorial semantic advancement stays intact.
- The improvements help tutorial command readability indirectly through the shared command-status and side-panel changes.

## Tuning Changes

No numeric balance tuning was made.

Evidence and rationale live in `docs/V012_BALANCE_AND_FEEL_TUNING_NOTES.md`. The simulator continues to show 255 deterministic runs across 85 campaign node/profile summaries, no structural `too_easy`, no structural `too_hard`, no Stronghold warnings, no enemy-pressure balance warnings, and Ashen Outpost beatable. Retinue/Stronghold and strategy-spread cases remain human-review watchpoints.

## Deliberately Deferred

- New art, generated art, imported assets, runtime art replacement, icons, destination markers, selection-ring art, projectile VFX, hit flashes, and minimap art.
- New maps, factions, units, workers, enemy economy, construction AI, broad enemy planning, or live reinforcement systems.
- Save format changes.
- Movement/cooldown/wave/reward/retinue numeric tuning without human-play or simulator proof.
- Control groups, command queues, stances, tactical logs, minimap filters, and broader army-management mechanics.
- Cinderfen 2026 visual overhaul, which remains a future art phase.

## Files Changed

Source and tests:

- `PLAYTEST_TELEMETRY.json`
- `src/game/battle/BattleSceneAlerts.ts`
- `src/game/battle/BattleSceneSystems.ts`
- `src/game/battle/BattleStatusPriority.test.ts`
- `src/game/battle/BattleStatusPriority.ts`
- `src/game/battle/EnemyPressureRuntime.test.ts`
- `src/game/core/FirstExperienceGuidance.ts`
- `src/game/data/enemyPressurePlans.ts`
- `src/game/data/maps/ashenOutpost.ts`
- `src/game/data/maps/cinderfenCauseway.ts`
- `src/game/data/maps/cinderfenWatchpost.ts`
- `src/game/results/ResultsViewModel.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/styles/battle-hud.css`
- `src/game/systems/AbilitySystem.ts`
- `src/game/systems/BuildingSystem.ts`
- `src/game/systems/InputSystem.ts`
- `src/game/systems/TrainingSystem.ts`
- `src/game/systems/UpgradeSystem.ts`
- `src/game/ui/hudPanels/ObjectivePanel.test.ts`
- `src/game/ui/hudPanels/ObjectivePanel.ts`
- `src/game/ui/hudPanels/SelectedEntityPanel.ts`
- `tests/e2e/chapter2-helpers.ts`
- `tests/e2e/deep-flow.spec.ts`
- `tests/e2e/enemy-pressure.spec.ts`
- `tests/e2e/layout.spec.ts`
- `tests/e2e/shared-helpers.ts`
- `tests/e2e/smoke.spec.ts`

Docs and handoff:

- `CHANGELOG.md`
- `DEVELOPMENT_CHECKPOINT.md`
- `LLM_GAME_HANDOFF.md`
- `README.md`
- `ROADMAP.md`
- `docs/V012_BATTLE_READABILITY_AUDIT.md`
- `docs/V012_BALANCE_AND_FEEL_TUNING_NOTES.md`
- `docs/V012_CORE_GAME_FEEL_AUDIT.md`
- `docs/V012_CORE_GAME_FEEL_PASS_REPORT.md`
- `docs/V012_VISUAL_READABILITY_NOTES.md`

`RELEASE_CHECKLIST.md` was not changed because no verification commands, release scripts, hosted groups, or workflow expectations changed.

## Tests Added / Updated

- Added `src/game/ui/hudPanels/ObjectivePanel.test.ts` for `Next` objective state.
- Updated `src/game/battle/BattleStatusPriority.test.ts` for command-priority replacement and duration behavior.
- Updated `src/game/battle/EnemyPressureRuntime.test.ts` for revised pressure warning copy.
- Updated `tests/e2e/deep-flow.spec.ts` to assert visible move-command acknowledgement while preserving the existing `Moving` assertion, and to keep command/choice checks tied to deterministic state after preview timing churn.
- Updated `tests/e2e/enemy-pressure.spec.ts` to preserve pressure priority and warning-copy coverage.
- Updated `tests/e2e/shared-helpers.ts`, `chapter2-helpers.ts`, `layout.spec.ts`, and `smoke.spec.ts` with targeted transition/success checks for real DOM UI buttons that can detach or disable after successful clicks. No force clicks were added, and canvas/world clicks still do not use DOM fallback.

## Verification Results

```text
npm test: PASS, 47 files / 355 tests.
npm run build: PASS, known Phaser vendor chunk-size warning only.
npm run validate:content: PASS.
npm run validate:art-intake: PASS, 1 candidate metadata JSON / 0 review manifests.
npm run test:e2e:smoke:fast: PASS, 6 tests.
npm run test:e2e:smoke: PASS, 12 tests.
npm run visual:qa: PASS, 5 tests, 18 screenshots, 0 browser console errors, 0 screenshot retries.
npm run smoke:preview: PASS, production preview smoke, 0 browser console errors.
npm run playtest:sim: PASS, 255 simulated runs across 85 campaign battle nodes.
npm run test:e2e:release:hosted:deep-meta: PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle: PASS, 11 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure: PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core: PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen: PASS, 12 tests.
npm run test:e2e:release:hosted:smoke: PASS, 12 tests.
npm run test:e2e:release: PASS, 74 tests.
git diff --check: PASS.
```

Initial local smoke/full-release attempts exposed real actionability races in long campaign/layout flows. The fixes stayed test-harness scoped, used `clickReady`, preserved follow-up assertions, avoided force clicks, and did not add DOM fallback for canvas/world clicks.

## Remaining Risks

- Status-line copy is still transient by design; deterministic tests should keep asserting stable behavior, not ephemeral text, where possible.
- Command feedback is clearer but not yet supported by new destination-marker art.
- Results guidance is more useful, but a future human playtest should still judge whether defeat tips match actual frustration points.
- Retinue + Training Yard II and some Greedy/Fast strategy outcomes remain human-review watchpoints.
- Future visual debt remains substantial and belongs to the 2026 visual overhaul, not v0.12.

## GitHub Actions Guidance

After this checkpoint is pushed, rerun the manual GitHub Actions release matrix on the new commit. Expect the same production-preview hosted groups and release simulator. Do not rerun old failed jobs from pre-v0.12 commits.

## Next Recommended Goal

Next best long goal: a human-paced v0.12.1 playtest/readability review of Ashen Outpost, Cinderfen Crossing, Cinderfen Watch, Results, and campaign return flow using the new command/objective/pressure feedback. Keep it review-first and small: capture player confusion, adjust copy or tiny HUD spacing if evidence supports it, and defer visual art replacement to the later 2026 art overhaul.
