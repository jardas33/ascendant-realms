# v0.12.1 Human-Paced Playtest Report

Date: 2026-05-17

Scope: v0.12.1 Human-Paced Core Feel Playtest Review. This pass played and inspected the existing slice after v0.12 at a slower, player-like pace, then applied only tiny evidence-backed polish. It was not a feature expansion, CI-plumbing goal, art overhaul, save migration, new content pass, or broad AI/economy rewrite.

## Reviewed Areas

- First launch and main menu.
- Tutorial / Proving Grounds.
- New campaign start and campaign map entry.
- Border Village / First Claim early battle flow.
- Ashen Outpost objective/result readability.
- Cinderfen Crossing battle readability and results.
- Cinderfen Watch route readability.
- Skirmish setup and Broken Ford setup context.
- Defeat guidance in a disposable skirmish defeat flow.
- Victory results and campaign return flow.

## What Felt Good After v0.12

- Selection and order state were much easier to read. The selected panel's count, `Commands apply to this group.`, and `Current Orders` block made group control feel more deliberate.
- Move command acknowledgement stayed visible long enough to register in Tutorial / Proving Grounds and battle starts.
- Objective tracker `Next` state helped Cinderfen and Ashen objectives read as actions rather than only lore.
- Campaign return guidance was clear after victory; `Strengthen Your Hero` gave a good next-action cue.
- Pressure and result guidance were more useful than pre-v0.12 because they named the problem and suggested practical counterplay.

## What Still Felt Rough

- Results screens are still dense when rewards, retinue, objectives, and hero stats all appear together.
- Main menu baseline/version copy still reads like a long-lived prototype surface rather than a polished front door.
- Battle art, map landmarks, minimap icon language, fog edges, shrine/tower silhouettes, command destination markers, and results presentation remain prototype-level visual debt.
- Border Village still relies more on command feedback and side-panel state than on a dedicated battle objective tracker.
- Longer balance questions remain unresolved: retinue plus Training Yard II, Greedy Economy timeouts, Fast Army clear speed, and pressure readability under repeated human play.

## Fixes Made

- Aligned player-facing Cinderfen battle names with the campaign route:
  - `Cinderfen Causeway` display name is now `Cinderfen Crossing`.
  - `Cinderfen Watchpost` display name is now `Cinderfen Watch`.
  - Map ids, file names, routes, rewards, layout, mechanics, and save data are unchanged.
- Reworded the Cinder Shrine objective so the small tracker says to claim the shrine for a one-time +20 Aether surge, then hold it.
- Made defeat guidance context-aware:
  - Campaign-node defeats still point toward camp or Chapel support.
  - Skirmish defeats now say `Hold after each wave`, avoiding unavailable campaign-only advice.
- Updated reward/report naming so telemetry and reward tables use the same player-facing Cinderfen names.
- Kept release-lane assertions intact after verification exposed two deep-flow timing issues:
  - Deep-flow scene-start buttons now use the same scene-transition click options already used by smoke and Chapter 2 helpers, followed by unchanged `expectBattleLoaded` assertions.
  - Deep-flow building selection now refreshes the HUD after direct scene selection, matching the Command Hall helper and avoiding stale construction-panel reads.

## Tests Added Or Updated

- `src/game/results/ResultsViewModel.test.ts` now protects campaign-vs-skirmish defeat guidance.
- Campaign/map launch, battle launch request, smoke, layout, and visual QA tests were updated for the player-facing Cinderfen names and objective copy.
- `tests/e2e/deep-flow.spec.ts` was updated only where full release verification proved scene transitions/HUD refresh could race; no force clicks or canvas/world DOM fallback were added.

## Tuning Result

No numeric tuning was made because the playtest issues were readability/friction rather than balance failures.

`npm run playtest:sim` passed after the copy changes with 255 simulated runs across 85 campaign battle nodes. The simulator remains useful structural evidence, but it is not a substitute for longer human balance review.

## Visual QA Result

`npm run visual:qa` passed with 5 tests, 18 screenshots, 0 browser console errors, and 0 screenshot retries. The shorter Cinderfen names and objective copy did not create visible layout regressions.

## Verification

Final local verification:

```text
npm test: PASS, 47 files / 356 tests.
npm run build: PASS, known Phaser vendor chunk-size warning only.
npm run validate:content: PASS.
npm run validate:art-intake: PASS.
npm run test:e2e:smoke:fast: PASS, 6 tests.
npm run test:e2e:smoke: PASS, 12 tests.
npm run visual:qa: PASS, 5 tests, 18 screenshots, 0 browser console errors, 0 screenshot retries.
npm run smoke:preview: PASS, production preview, 0 browser console errors.
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

## Deferred

- New art, generated art, runtime art replacement, map thumbnails, VFX, minimap icon redesign, and the broader 2026 visual overhaul.
- New maps, factions, units, campaign nodes, rewards, mechanics, AI/economy systems, enemy workers/construction, multiplayer, procedural generation, monetization, and save migrations.
- Results-screen density and broader HUD layout redesign.
- Numeric balance tuning until a longer human playtest shows repeated unfairness rather than readability friction.

## Remaining Risks

- Human review covered representative slow flows, not every possible pacing path.
- Local full release initially exposed release-test timing races before the deep-flow helper alignment; final full release and refreshed hosted deep groups are green.
- GitHub Actions should be rerun manually on the final pushed v0.12.1 checkpoint to confirm remote parity.

## Next Recommended Goal

Next long goal: **v0.12.2 Human Balance Watchpoint Review**. Focus narrowly on repeated human and simulator evidence for retinue plus Training Yard II, Greedy Economy timeouts, Fast Army clear speed, early campaign defeat causes, and pressure-warning fairness. Keep visual overhaul work separate until the future 2026 art pipeline is explicitly opened.
