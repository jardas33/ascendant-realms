# Ascendant Realms LLM Handoff

Last updated: 2026-05-04 19:55 -04:00

This file is the main continuation note for future LLMs working on Ascendant Realms. It supersedes older scattered status notes when they disagree.

## Project Identity

Ascendant Realms is a Phaser 3, TypeScript, and Vite browser-game prototype for a fantasy RTS/RPG hybrid.

The current playable loop:

1. Create or load a persistent hero.
2. Enter the Border Marches mini-campaign or a standalone skirmish.
3. Play an RTS battle with hero abilities, capture sites, construction, training queues, upgrades, rally points, pathfinding, fog of war, live minimap, and enemy pressure waves.
4. Resolve victory or defeat through the shared Results scene.
5. Persist hero XP, skill points, inventory item instances with affixes, equipment, campaign node progress, event choices, town purchases, Stronghold upgrades, retinue units, rival state, rival trophy records, campaign modifiers, campaign resources, settings, and save migrations in localStorage.

The project is now a v0.2.1 prototype baseline candidate. The visible in-game menu still says `Prototype v0.2`, while v0.2.1 documents the current release baseline after Unit Veterancy V1, Retinue Camp V1, Enemy Hero / Rival Commander V1, Rival / Nemesis Persistence V1, Rival Rewards and Trophies V1, Stronghold Development Tier II, reputation hooks, randomized item affixes V1, safe HeroProgressionRules and CampaignRules module splits, HUD interaction polish, captured-site fog polish, and permanent Playwright regression coverage for the reported HUD/fog issues. It is still a prototype, but it has a broad playable RTS/RPG spine and a clearer verification baseline. Preserve that work. Do not reset, delete, checkout, or revert changes unless the user explicitly asks.

The next recommended milestone is **human-verifying the current Chapter 2 Cinderfen route including the new aftermath event before adding more content**. Chapter metadata exists, `cinderfen_overlook` is now a playable preparation event after `ashen_outpost`, `cinderfen_waystation` is a compact town/support node after the event, `cinderfen_crossing` launches the authored `Cinderfen Causeway` map after the event is completed, `cinderfen_watch` launches the compact `Cinderfen Watchpost` map after Cinderfen Crossing victory, and `cinderfen_aftermath` is a compact non-battle consequence event after Cinderfen Watch. Chapter/campaign data is now split into focused node and reward modules, with `campaignNodes.ts` and `rewards.ts` kept as compatibility barrels. Keep further Chapter 2 implementation compact; do not move to workers, enemy construction, full new factions, diplomacy, procedural campaign, crafting, durability, broad loot complexity, full trophy rooms, or broad army-management systems.

## Current Git State

Project root:

```text
D:\Code for projects\WB game like\ascendant-realms
```

Current branch:

```text
main
```

Latest checkpoint feature commit:

```text
e52636729f05f0b54c2896200aa57ceebc13e6b1
```

Recent checkpoint stack:

```text
e526367 Checkpoint Cinderfen two-battle Chapter 2 slice
6543f21 Checkpoint Chapter 2 Cinderfen event battle and balance slice
df318e0 Sync v0.2.1 checkpoint branch status
b79e0f8 Record v0.2.1 checkpoint metadata
2d5b0cd Checkpoint v0.2.1 baseline and Chapter 2 scaffold
```

Known shell/tool note:

- `rg.exe` has returned access-denied errors in this workspace. Use PowerShell `Select-String`, `Get-ChildItem`, and targeted `Get-Content` if `rg` fails.
- Latest user-provided in-app browser context for this handoff refresh was `http://127.0.0.1:4184/`. The previous Browser Use smoke check after the Cinderfen balance pass saw title `Ascendant Realms`, main menu present, and browser console errors at 0. Playwright remains the deterministic browser verification surface for gameplay flows.

Current branch status for this handoff update:

```text
Checkpoint commit e52636729f05f0b54c2896200aa57ceebc13e6b1 preserves the Chapter 2 Cinderfen two-battle slice and remains the latest named checkpoint. The checkpoint and metadata follow-ups are pushed to origin/main.

As of 2026-05-04 19:20 -04:00, the worktree is intentionally dirty with the Chapter 2 reward-economy audit, regenerated telemetry, docs/report updates, and the Chapter 2 Playwright helper cleanup. New files include docs/CINDERFEN_AUTOMATED_REVIEW.md and tests/e2e/chapter2-helpers.ts. Preserve these dirty changes unless the user explicitly asks for a reset/revert.
```

The checkpoint commit `e52636729f05f0b54c2896200aa57ceebc13e6b1` was created with message `Checkpoint Cinderfen two-battle Chapter 2 slice`. This metadata follow-up records that checkpoint. Do not reset or revert future edits unless the user explicitly asks.

Feature checkpoint commit:

```text
e52636729f05f0b54c2896200aa57ceebc13e6b1
```

Current branch sync status:

```text
Before checkpoint commit e52636729f05f0b54c2896200aa57ceebc13e6b1, `git rev-list --left-right --count origin/main...HEAD` reported `0 0`. The checkpoint commit and metadata follow-ups were pushed to origin/main. Final post-push `git status -sb` reported `## main...origin/main`, and `git rev-list --left-right --count origin/main...HEAD` reported `0 0`.
```

The pushed checkpoint preserves the Chapter 2 battle-slice edits. Preserve future dirty work unless the user explicitly asks for a different git action.

## Clean Checkpoint - 2026-05-04 19:53 -04:00

Scope: create a clean checkpoint for the current Chapter 2 Cinderfen route reward audit and Chapter 2 Playwright helper cleanup. No gameplay, balance, maps, units, factions, UI behavior, systems, resets, checkouts, deletes, or reverts were added during the checkpoint pass.

Current preserved dirty-work scope:

- Cinderfen Overlook, Cinderfen Waystation, Cinderfen Crossing, Cinderfen Watch, and Cinderfen Aftermath exist and remain the current Chapter 2 route.
- Chapter 2 reward-economy audit is preserved: Cinderfen first clears stay useful, while repeat clears pay only tiny XP/resources and no repeat battle item roll.
- Chapter 2 Playwright helper cleanup is preserved in `tests/e2e/chapter2-helpers.ts`; smoke specs retain the meaningful copy, reward, save, and duplicate-prevention assertions.
- Regenerated telemetry, balance docs, Cinderfen route reports, reward tests, campaign data updates, and e2e updates are preserved.
- Chapter 1 remains unchanged by this checkpoint pass.

Verification completed:

```text
npm test
PASS: 37 test files, 259 tests, 18.56s.

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only. Latest output: assets/index-MCPD5UO4.js, 1,914.22 kB minified / 456.45 kB gzip.

npm run test:e2e -- --reporter=line
PASS: 52 Playwright tests in 24.2m. Slow files noted by Playwright: tests/e2e/deep-flow.spec.ts and tests/e2e/layout.spec.ts.

npm run playtest:sim
PASS: 255 deterministic battle runs across 85 campaign battle node/profile summaries. PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated.
```

Branch and commit status:

```text
Pre-checkpoint `git status -sb`: ## main...origin/main
Pre-checkpoint `git rev-list --left-right --count origin/main...HEAD`: 0 0
Checkpoint commit message: Checkpoint Cinderfen route reward audit and e2e helper cleanup
Checkpoint commit hash: b8ab7e0e474f6020a2823cabfadd8b2a3e20f919
Post-checkpoint, pre-metadata `git status -sb`: ## main...origin/main [ahead 1]
Post-checkpoint, pre-metadata `git rev-list --left-right --count origin/main...HEAD`: 0 1
Post-push branch sync: after pushing the checkpoint and metadata update, `git status -sb` reported `## main...origin/main`, and `git rev-list --left-right --count origin/main...HEAD` reported `0 0`.
```

Remaining known risks:

- Human playtesting is still needed for the full Cinderfen route with no retinue, light retinue, Training Yard II, Quartermaster II, and mixed Chapter 1 upgrade states.
- Fast Army and retinue plus Training Yard II can still clear Cinderfen quickly; repeat farming value is reduced, but quick clear feel still needs human review.
- Cinder Shrine, Shrine Attunement, Cinderfen Waystation, and Cinderfen Aftermath need live browser/mobile readability review.
- `tests/e2e/chapter2-helpers.ts` should stay a setup/fast-forward helper module; future specs should keep behavior and reward assertions visible in spec files.
- The known Vite large chunk warning remains.
- Full Playwright e2e remains slow.

Next recommended milestone: human-verify the current Cinderfen route end to end: Overlook, Waystation, Crossing, Cinder Shrine surge/attunement, Watch, Aftermath, Results, and return-to-campaign persistence. Add no further Chapter 2 content until the current route stays green in human readability and balance review.

## Chapter 2 Reward Economy Audit - 2026-05-04

Scope: audit Chapter 2 rewards after the current Cinderfen chain: Cinderfen Overlook, Cinderfen Waystation, Cinderfen Crossing, Cinderfen Watch, and Cinderfen Aftermath. No systems, maps, units, factions, broad loot mechanics, enemy construction, or Chapter 1 values were added or changed.

Reward read:

- Cinderfen Crossing first clear remains 125 XP / 170 campaign+battle resources, one first-clear battle item roll, and fixed `Scout's Bow`.
- Cinderfen Watch first clear remains 128 XP / 170 campaign+battle resources and one first-clear battle item roll.
- The two mandatory Cinderfen battle/node first clears therefore grant 253 XP and 340 resources before event choices.
- With one normal Overlook choice and one normal Aftermath choice, the route grants 285-290 gross XP and 346-360 gross rewarded resources before Waystation service spending. After event costs, the same normal-choice route nets about 242-306 resources depending on choices.
- Waystation service costs stayed unchanged: Marsh Guides 35 Crowns, Ash Filters 35 Crowns + 15 Aether, Refugee Scouts 25 Crowns once, Shrine Attunement 12 Aether.
- Aftermath choice rewards stayed unchanged and modest: each normal choice grants 12 XP plus a small resource/reputation result; Display Malrec's Standard grants only +1 Free Marches.

Telemetry read:

- Cinderfen Crossing remains structurally reasonable at 26 wins / 0 defeats / 13 timeouts.
- Cinderfen Watch remains structurally reasonable at 25 wins / 0 defeats / 11 timeouts.
- Fast Army remains the repeat-farm risk: 12/13 Crossing wins at about 98.8s average winning duration, and 10/12 Watch wins at about 86.8s average winning duration.
- Retinue + Training Yard II remains the strongest Chapter 2 profile at 6 wins / 0 defeats / 0 timeouts across the current Cinderfen battle pair.
- Chapter 1 telemetry remains stable and no Chapter 1 data was touched.

Tuning applied:

- `src/game/data/campaignRewards.ts`: Cinderfen battle weighted item pools and base battle XP/resources are now first-clear-only.
- Repeat clears now pay only the explicit repeat bonus: Cinderfen Crossing 4 XP / 11 resources / no battle item roll; Cinderfen Watch 3 XP / 8 resources / no battle item roll.
- `src/game/core/progression/ItemRewardRules.ts`: deterministic reward selection now respects existing weighted-pool first/repeat metadata, so simulator/test paths match live reward filtering.
- `src/game/playtest/PlaytestReportWriter.ts`: regenerated telemetry copy now calls out the reward-economy audit and reduced repeat value.
- `src/game/core/HeroProgressionRules.test.ts`: added coverage proving Cinderfen first clears keep their useful reward while repeat deterministic rewards grant no item and only the tiny repeat bonus.

Verification completed:

```text
npm test
PASS: 37 test files, 259 tests, 7.77s.

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only. Latest output: assets/index-MCPD5UO4.js, 1,914.22 kB minified / 456.45 kB gzip.

npm run test:e2e -- --reporter=line
PASS: 52 Playwright tests in 22.6m.

npm run playtest:sim
PASS: 255 deterministic battle runs across 85 campaign battle node/profile summaries. PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated.
```

Remaining risks:

- Fast Army still clears Cinderfen quickly; the farm payout is reduced, but human play should still verify whether quick clears feel too dominant.
- Retinue + Training Yard II is still the strongest Chapter 2 profile and should not receive more reward-adjacent buffs before human review.
- Cinderfen Waystation, Cinderfen Aftermath, and Cinder Shrine readability still deserve a live mobile/browser pass.
- Keep future Chapter 2 rewards modest until another sink or consequence exists.

## Chapter 2 Playwright Helper Cleanup - 2026-05-04

Scope: clean up duplicated Chapter 2 e2e setup without changing gameplay, balance, maps, units, factions, intentional UI behavior, selectors, or test IDs.

What changed:

- Added `tests/e2e/chapter2-helpers.ts`.
- Moved repeated post-Ashen and post-Crossing localStorage seed setup into explicit test-only helper functions.
- Moved Cinderfen Overlook choice clicks, Cinderfen Waystation service purchases, Cinderfen Crossing launch, and Cinderfen Watch launch into UI-path helpers that keep using the same stable Playwright test IDs and `data-campaign-choice` selectors.
- Moved the Cinder Shrine capture into `captureCinderShrineWithHook`, which uses the existing safe Playwright-only `__ASCENDANT_TEST_HOOKS__.captureSite` hook.
- Moved the Cinderfen Crossing and Cinderfen Watch battle fast-forwards into clearly commented test-only helpers. These still directly mutate `BattleScene` state only after launch/map/objective assertions have covered the relevant gameplay wiring.
- Updated `tests/e2e/smoke.spec.ts` to use the helpers while keeping meaningful coverage in the spec: Chapter 2 copy, lock/unlock state, Waystation costs, reward values, active-modifier consumption, Cinder Shrine first-capture and duplicate prevention, Results copy, save persistence, and Aftermath duplicate prevention remain asserted.

Verification completed after the helper cleanup:

```text
npm test
PASS: 37 test files, 259 tests, 9.30s.

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only. Latest output: assets/index-MCPD5UO4.js, 1,914.22 kB minified / 456.45 kB gzip.

npm run test:e2e -- --reporter=line
PASS: 52 Playwright tests in 21.3m. The Chapter 2 smoke flows pass using the extracted helpers.

npm run playtest:sim
PASS: 255 deterministic battle runs across 85 campaign battle node/profile summaries. PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated by the command.
```

Current e2e file shape:

- `tests/e2e/smoke.spec.ts`: 754 lines after moving duplicated Chapter 2 helpers out of the spec.
- `tests/e2e/chapter2-helpers.ts`: 454 lines, purpose-built for Chapter 2 e2e setup and fast-forward helpers.

Remaining risks:

- The helpers intentionally make the smoke spec easier to maintain, but they should not absorb gameplay assertions. Future tests should keep behavior, reward, and persistence checks in the spec.
- The direct victory helpers are test-only shortcuts, not gameplay APIs. Use them only after the test has asserted that the correct Cinderfen battle loaded.
- If Chapter 2 node IDs, reward IDs, or Cinderfen objective IDs change later, update the helper and the visible assertions together.

## Clean Checkpoint - 2026-05-03 19:28 -04:00

Scope: create a clean checkpoint before new feature work. No gameplay, balance, map, faction, unit, worker, enemy construction, diplomacy, procedural generation, crafting, or save-format changes were made during the checkpoint pass. The checkpoint preserves the current Chapter 2 Cinderfen two-battle slice, including Cinderfen Overlook, Cinderfen Waystation, Cinderfen Crossing, Cinderfen Watch, Cinder Shrine, Malrec trophy consequence, Chapter 2 docs/report updates, e2e/simulator coverage, telemetry, and the focused campaign data split.

Verification completed:

```text
npm test
PASS: 37 test files, 251 tests, 11.94s.

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only. Latest output: assets/index-DHOLAhSV.js, 1,911.42 kB minified / 455.81 kB gzip.

npm run test:e2e -- --reporter=line
PASS: 52 Playwright tests in 21.5m, including Cinderfen Overlook, Cinderfen Waystation Shrine Attunement, Cinderfen Crossing victory/reward persistence, Cinder Shrine duplicate prevention, Cinderfen Watch victory/reward persistence, and Malrec trophy consequence coverage.

npm run playtest:sim
PASS: 255 deterministic battle runs across 85 campaign battle node/profile summaries. PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated.
```

Branch and commit status:

```text
Pre-checkpoint sync check: `origin/main...HEAD` reported `0 0`.
Checkpoint commit: e52636729f05f0b54c2896200aa57ceebc13e6b1
Checkpoint message: Checkpoint Cinderfen two-battle Chapter 2 slice
Post-push status: `main...origin/main`, with `origin/main...HEAD` reporting `0 0`.
```

Remaining known risks:

- Human playtesting still needs to check Cinderfen Crossing and Cinderfen Watch with no retinue, light retinue, Training Yard II, Quartermaster II, and mixed Chapter 1 upgrade states.
- Fast Army and retinue plus Training Yard II can still clear Cinderfen quickly, so future Chapter 2 rewards should stay modest.
- Cinder Shrine and Shrine Attunement need a live readability pass even though tests and simulator cover the Aether surge and duplicate prevention.
- Cinderfen Overlook and Waystation choice/service density should be spot-checked on mobile.
- The Malrec trophy consequence is intentionally compact; broader returning-rival arcs remain future work.
- The focused campaign data split depends on node arrays, reward tables, chapter metadata, compatibility barrels, and content validation staying aligned.
- The known Vite large chunk warning remains.
- Full Playwright e2e remains slow at about 21-22 minutes.

Next recommended milestone: human-verify the current Cinderfen route end to end, including Cinderfen Aftermath, before adding more Chapter 2 content. Avoid workers, enemy construction, new factions, diplomacy, procedural generation, crafting, and broad army-management systems.

## Clean Checkpoint - 2026-05-03 14:31 -04:00

Scope: create a clean checkpoint before continuing Chapter 2. No gameplay, balance, map, faction, unit, worker, enemy construction, diplomacy, procedural generation, or crafting changes were made during the checkpoint pass.

Verification completed:

```text
npm test
PASS: 37 test files, 233 tests, 12.56s.

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only.

npm run test:e2e -- --reporter=line
PASS: 51 Playwright tests in 21.8m, including Cinderfen Overlook, Cinderfen Crossing victory/reward persistence, and Malrec trophy consequence coverage.

npm run playtest:sim
PASS: 216 deterministic runs across 72 campaign battle nodes; PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated.
```

Branch and commit status:

```text
Pre-commit sync check: `origin/main...HEAD` reported `0 0`.
Checkpoint commit: 6543f212431e18a5cbe916f9984797313513fe57
Checkpoint message: Checkpoint Chapter 2 Cinderfen event battle and balance slice
Push status: checkpoint commit pushed successfully to origin/main.
```

Remaining known risks:

- Human playtesting still needs to check Cinderfen Crossing with no retinue, light retinue, Training Yard II, Quartermaster II, and mixed Chapter 1 upgrade states.
- Fast Army can still clear Cinderfen quickly, so further Chapter 2 reward additions should stay modest.
- Cinder Shrine readability needs a live human pass even though tests and simulator model the +20 Aether first-capture surge.
- Event choice mobile density, Results readability, and Cinderfen fog/capture-site legibility still deserve browser spot checks.
- The known Vite large chunk warning remains.
- Full Playwright e2e remains slow at about 22 minutes.

Next recommended milestone: human-play the current Cinderfen vertical slice, including Cinderfen Aftermath, before adding more Chapter 2 content. Avoid workers, enemy construction, new factions, diplomacy, procedural generation, crafting, and broad army-management systems.

## Chapter 2 Aftermath Event - 2026-05-03

Scope: add one compact non-battle Chapter 2 aftermath node after Cinderfen Watch. No map, worker, enemy construction, faction, diplomacy, procedural generation, crafting, broad loot, or save-format changes were added.

What changed:

- Added `cinderfen_aftermath` / **Cinderfen Aftermath** in `src/game/data/cinderfenRoadNodes.ts`.
- `cinderfen_watch` now unlocks `cinderfen_aftermath` after Watchpost victory.
- `campaignChapters.ts` now lists the Chapter 2 chain as Overlook, Waystation, Crossing, Watch, and Aftermath.
- The node uses the existing event/choice system and does not launch a battle.
- Added three baseline once-only completing choices:
  - Secure the Watch Road: costs 45 Crowns and 18 Stone; grants 12 XP, 10 Stone, +4 Free Marches reputation, and the existing Local Support modifier.
  - Aid the Fenfolk: costs 40 Crowns; grants 12 XP, 8 Iron, and +5 Common Folk reputation.
  - Study the Ashen Marks: costs 18 Aether; grants 12 XP, 6 Aether, Pilgrim Crook, +4 Old Faith reputation, and -1 Ashen Covenant reputation.
- Added one optional Malrec trophy aftermath choice, Display Malrec's Standard, gated by `trophy_malrec_outpost_standard`; it grants only +1 Free Marches reputation and completes the node.
- Secure the Watch Road intentionally uses `local_support` rather than a new next-Cinderfen-battle modifier because there is no third Cinderfen battle in the current slice. The aftermath node is event-only and excluded from battle simulator profiles.
- Added/updated unit tests for unlock, availability, cost payment, insufficient resources, reward grant, reputation changes, duplicate prevention, presentation, content validation, and save/load.
- Extended Cinderfen Playwright smoke coverage so Watch victory unlocks Aftermath, one Aftermath choice resolves, rewards/reputation persist, and revisiting the completed node does not duplicate rewards.

Verification for this pass:

```text
npm test
PASS: 37 test files, 258 tests, latest duration 7.25s.

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only.

npm run test:e2e -- --reporter=line
PASS: 52 Playwright tests in 20.9m, including the Cinderfen Aftermath unlock/choice/duplicate-prevention flow.

npm run playtest:sim
PASS: 255 deterministic battle runs across 85 campaign battle node/profile summaries. Aftermath is event-only and did not add a battle simulator profile.
```

Remaining known risks:

- Cinderfen Aftermath adds another event-choice panel after a dense Chapter 2 route, so human mobile/scroll readability still needs review.
- Secure the Watch Road can leave Local Support active until a later resource-reward node exists. That is intentional for now and should be rechecked when adding the next Chapter 2 node.
- Rewards are deliberately modest; do not inflate aftermath payouts until Fast Army and retinue plus Training Yard II are human-reviewed.

Next recommended milestone: human-verify the current Cinderfen route end to end before adding any more Chapter 2 content.

## Chapter 2 Event Gate, Support, And Two Battle Slice - 2026-05-03

Scope: implement the playable `cinderfen_overlook` event gate, optional `cinderfen_waystation` support node, `cinderfen_crossing` on `cinderfen_causeway` / **Cinderfen Causeway**, `cinderfen_watch` on `cinderfen_watchpost` / **Cinderfen Watchpost**, and the later compact `cinderfen_aftermath` event. This is not full Chapter 2.

What changed:

- Added `src/game/data/maps/cinderfenCauseway.ts` and registered it in the map index.
- Added `src/game/data/maps/cinderfenWatchpost.ts` and registered it in the map index.
- Converted `cinderfen_crossing` from a locked placeholder into a playable Normal battle after `ashen_outpost`.
- Added `cinderfen_watch` as a second compact Chapter 2 Normal battle that unlocks after `cinderfen_crossing` and launches Cinderfen Watchpost.
- Converted `cinderfen_overlook` from a placeholder into a playable event after `ashen_outpost`.
- Added three baseline one-time Cinderfen Overlook choices: Scout the Causeway, Aid the Marsh Refugees, and Study the Cinders.
- Added one optional Malrec trophy consequence choice: Raise Malrec's Standard appears when `trophy_malrec_outpost_standard` is present, grants 10 XP, +3 Free Marches reputation, and the existing Well Rested next-battle modifier, then completes the event.
- Added `cinderfen_waystation` as a compact Chapter 2 town/support node after Cinderfen Overlook. It stays open, uses existing town-service choice rules, and offers Marsh Guides, Ash Filters, Refugee Scouts, and Shrine Attunement without adding a shop/vendor system.
- Added three Cinderfen-only one-battle campaign modifiers for Waystation services: Marsh Guides grants +60 player-building vision and +20s enemy warning lead on the next Cinderfen battle; Ash Filters grants +8% hero HP/Mana on the next Cinderfen battle; Shrine Attunement adds +5 Aether to the next Cinderfen battle's first Cinder Shrine capture.
- Each Cinderfen Overlook choice uses existing campaign costs, XP/resources/items, reputation changes, and campaign modifiers, then completes the event and unlocks `cinderfen_crossing`.
- Used existing Ashen Covenant units, existing Ashen structures, and the existing `hexfire_cult` AI personality.
- Added objectives for destroying the enemy Stronghold, claiming the Cinder Shrine, clearing the central Cinder Guardians Brute, and destroying the Enemy Barracks.
- Added the Cinder Shrine tactical identity feature on the existing `cinder_crossing` capture site: first capture by a side grants one battle-local `Cinder Shrine Surge` of +20 Aether, then normal +16 Aether/6s income continues.
- Added `cinderfen_causeway_rewards` with one existing-item weighted roll, modest XP/resources, and lower payoff than Ashen Outpost.
- Added `cinderfen_watchpost_rewards` with one existing-item weighted roll, modest XP/resources, and no rival trophy-level reward.
- Cinderfen Watchpost uses three capture sites, two neutral camps, one central Watchtower objective, existing Ashen units/structures, the existing Hexfire Cult AI personality, fog/minimap readability, and no Cinder Shrine.
- Added/updated content validation for the new map, node, reward table, objectives, capture sites, neutral camps, and enemy references.
- Added e2e coverage that seeds post-Ashen progress, resolves Cinderfen Overlook, buys Shrine Attunement at Cinderfen Waystation, verifies service cost/modifier persistence, launches Cinderfen Crossing, verifies BattleScene map/objective/resource/minimap state, captures the Cinder Shrine through a safe hook, verifies the attuned +25 Aether first-capture surge, and verifies the surge does not duplicate.
- Added Cinderfen Crossing and Cinderfen Watch to the scripted playtest simulator as Chapter 2 scenarios, reported separately from Chapter 1. The simulator models capture-site first-capture bonuses, including the Cinder Shrine Surge, and includes one Waystation: Shrine Attunement profile that applies only to Cinderfen battles with the Cinder Shrine site.
- Telemetry balance pass trimmed Cinderfen player start resources, capture-site income, battle XP/resources, campaign-node rewards, and event-choice payouts while giving the Ashen staging camp a slightly stronger starting bank and faster training.
- Added Cinderfen-specific defeat tips for side income, Cinder Guardians, and Enemy Barracks sequencing.
- Created `docs/CHAPTER_2_CINDERFEN_SLICE_REPORT.md` as the current v0.3 Cinderfen slice report covering content, explicit non-goals, telemetry, risks, and exactly two recommended small next additions.
- Updated roadmap, balance, content, and Chapter 2 implementation docs.

Explicitly not implemented:

- No workers, enemy construction, full new faction, diplomacy, procedural generation, crafting, additional Chapter 2 maps beyond the compact Causeway/Watchpost slice, new unit types, Chapter 2 named rival, rematch logic, or new rival system.
- The only returning-rival consequence is the existing Malrec trophy gating one optional Cinderfen event choice.
- The only Cinderfen-specific tactical feature is the Cinder Shrine first-capture Aether surge on the existing map/site.
- No additional Chapter 2 battle maps beyond the event gate, Waystation support node, Cinderfen Causeway, and Cinderfen Watchpost.

Verification for this slice should include:

```text
npm test
Latest PASS: 37 test files, 259 tests after the Chapter 2 reward-economy audit and Playwright helper cleanup.

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only.

npm run test:e2e -- --reporter=line
Latest PASS: 52 Playwright tests in 21.3m after the helper cleanup, including Cinderfen Overlook choice flow, Malrec trophy consequence coverage, Cinderfen Waystation Shrine Attunement coverage, Cinderfen Crossing launch/victory coverage, Cinder Shrine +25 attuned first-capture coverage, Cinderfen Watch launch/victory/reward persistence coverage, and Cinderfen Aftermath unlock/choice/duplicate-prevention coverage.

npm run playtest:sim
Latest PASS: 255 deterministic battle runs across 85 campaign battle node/profile summaries. Cinderfen Overlook, Waystation services, and Aftermath remain covered by unit/e2e save flow, including the Malrec trophy option and Shrine Attunement, while Cinderfen Crossing and Cinderfen Watch are both in the Chapter 2 simulator baseline.
```

## Chapter 2 Telemetry Balance Pass - 2026-05-03

Source: `PLAYTEST_TELEMETRY.md`, `PLAYTEST_TELEMETRY.json`, `BALANCE.md`, and `docs/CHAPTER_2_IMPLEMENTATION_SPEC.md`.

Telemetry read:

- Cinderfen Crossing remains structurally reasonable in the current simulator read at 26 wins / 0 defeats / 13 timeouts.
- Cinderfen Watch is structurally reasonable at 25 wins / 0 defeats / 11 timeouts, slightly below Crossing and above Ashen Outpost's 22 wins / 0 defeats / 14 timeouts.
- Safe Beginner won 12/12 with fair first contact around 4:16.
- Watchpost first contact averages about 3:57; the simulator marks it fair, but human play should verify the raised-road/tower opening feels readable.
- Greedy Economy mostly timed out, preserving the staging lesson.
- Fast Army remains the reward-farm watchpoint: it wins 12/13 Cinderfen Crossing runs and 10/12 Cinderfen Watch runs, often before first-wave pressure matters.
- Retinue + Training Yard II swept Cinderfen and remains a human-review watchpoint; Retinue + Quartermaster II did not sweep.
- Cinderfen has no named rival in this slice and 0 simulator runs applied rival persistence modifiers.
- Cinder Shrine impact is modest and battle-local: 26/39 Cinderfen Crossing simulator runs captured the shrine, with two Waystation-attuned captures at +25 Aether instead of +20; Fast Army often skips it, so the shrine does not explain quick rush wins. Cinderfen Watch has no shrine and does not consume Shrine Attunement.
- Chapter 1 telemetry stayed stable because the pass touched only Cinderfen values and Cinderfen-specific result copy.

Tuning applied:

- Cinderfen player starting bank reduced to 480 Crowns, 325 Stone, 195 Iron, and 110 Aether.
- Cinderfen enemy starting bank increased to 250 Crowns, 195 Stone, 140 Iron, and 100 Aether.
- Cinderfen enemy income per tick increased slightly to 80 Crowns, 40 Stone, 36 Iron, and 30 Aether.
- Cinderfen enemy train interval tightened from 6.8s to 6.4s.
- Cinderfen capture site income reduced to 30 Crowns/5s, 22 Stone/6s, 18 Iron/6s, and 16 Aether/6s.
- Cinderfen battle first-clear reward reduced to 65 XP and 30 Crowns, 20 Stone, 16 Iron, 12 Aether.
- `cinderfen_crossing` campaign node reward reduced to 60 XP and 40 Crowns, 20 Stone, 20 Iron, 12 Aether plus Scout's Bow.
- Cinderfen repeat reward reduced to 34 XP and 22 Crowns, 10 Stone, 11 Iron, 8 Aether plus the existing item roll path.
- Cinderfen event choices now cost more and pay less raw XP/resources: Scout 30 Crowns for 20 XP/8 Stone, Aid 55 Crowns for 25 XP/10 Iron, Study 24 Aether for 20 XP/Emberglass Wand.
- Later Cinder Shrine feature adds one battle-local +20 Aether first-capture surge on the existing central Aether site after the post-feature telemetry pass trimmed it from +24. It does not add campaign rewards, save schema, a new map, units, workers, enemy construction, diplomacy, procedural generation, or crafting.
- Post-feature telemetry pass left Cinderfen enemy pacing, wave size, AI income/training interval, starting resources, capture-site income, battle rewards, event costs/rewards, and the Malrec trophy consequence unchanged because Cinderfen stayed structurally reasonable and the only over-generous new knob was the shrine tempo burst.
- The Cinderfen Watchpost addition uses a 195s first attack delay, 6-unit attack wave target, 6.4s enemy training, 80/40/36/30 enemy income, and 4-unit base defense squad. The compact post-Waystation balance pass trimmed Watchpost full first-clear value to 128 XP / 170 resources and lowered Shrine Attunement to 12 Aether to reduce fast-clear/repeat-farm pressure without touching enemy pacing.
- No systems, units, factions, faction mechanics, diplomacy, crafting, or Chapter 1 values changed; the only new map in this phase is the compact authored Cinderfen Watchpost battle map.

## Chapter 2 Data Organization Cleanup - 2026-05-03

Scope: small technical cleanup after the Chapter 2 expansion. No gameplay behavior, balance values, maps, units, factions, workers, enemy construction, diplomacy, crafting, procedural generation, or save format changed.

What changed:

- Split Chapter 1 campaign nodes into `src/game/data/borderMarchesNodes.ts`.
- Split Chapter 2 campaign nodes into `src/game/data/cinderfenRoadNodes.ts`.
- Kept `src/game/data/campaignNodes.ts` as the public compatibility barrel exporting `CAMPAIGN_NODES`, `BORDER_MARCHES_NODES`, and `CINDERFEN_ROAD_NODES`.
- Moved campaign battle reward tables into `src/game/data/campaignRewards.ts`, grouped as `BORDER_MARCHES_REWARD_TABLES`, `CINDERFEN_ROAD_REWARD_TABLES`, and `CAMPAIGN_REWARD_TABLES`.
- Kept `src/game/data/rewards.ts` as the public compatibility barrel exporting `REWARD_TABLES`.
- Added content-validation coverage that confirms focused chapter node arrays match `campaignChapters.ts` ordering and that the focused reward-table arrays flow through the public barrel.
- Updated `CONTENT_GUIDE.md` so future chapter/node work goes into focused chapter node modules and future campaign reward tables go into `campaignRewards.ts`.

Verification completed:

```text
npm test
PASS: 37 test files, 251 tests.

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only.

npm run test:e2e -- --reporter=line
PASS: 52 Playwright tests in 21.5m.

npm run playtest:sim
PASS: 255 deterministic battle runs across 85 campaign battle node/profile summaries.
```

## v0.2.1 Prototype Baseline Candidate - 2026-05-03

Scope: document the v0.2.1 baseline candidate after v0.2 features, Rival/Nemesis Persistence V1, Rival Rewards and Trophies V1, the CampaignRules module split, HUD/fog polish, and permanent HUD/fog regression coverage.

What v0.2.1 means:

- No gameplay, balance, save format, faction, worker, enemy construction, diplomacy, crafting, or map content was added for this release-baseline pass.
- The visible product copy remains `Prototype v0.2`; v0.2.1 is the release/checkpoint label for docs, verification expectations, and stability work.
- Rival/Nemesis Persistence V1, Rival Rewards and Trophies V1, CampaignRules split, and HUD/fog polish are completed baseline work, not open next milestones.
- The v0.3 Chapter 2 Cinderfen vertical slice is now underway: Cinderfen Overlook, Cinderfen Waystation, Cinderfen Crossing, Cinderfen Watch, Cinderfen Aftermath, Cinder Shrine, and the Malrec trophy consequence exist. The current next phase is human verification of the route, not broad system work.

Latest verification status:

```text
npm test
Latest result after the 2026-05-04 reward audit and Chapter 2 helper cleanup: PASS, 37 test files and 259 tests.

npm run build
Latest result after the 2026-05-04 reward audit and Chapter 2 helper cleanup: PASS, known Vite large-chunk warning only.

npm run test:e2e -- --reporter=line
Latest full recorded result after Cinderfen Overlook, Malrec trophy consequence, Cinderfen Waystation, Cinderfen Crossing, Cinder Shrine, Cinderfen Watch, Cinderfen Aftermath, and Chapter 2 helper extraction: PASS, 52 Playwright tests in 21.3m.

npm run playtest:sim
Latest simulator baseline after the 2026-05-04 reward audit/helper cleanup run: PASS, 255 deterministic runs across 85 campaign battle node/profile summaries; no structural too-hard nodes; no structural too-easy nodes; Ashen Outpost beatable; no Stronghold warnings; Cinder Shrine first-capture bonuses modeled at +20 Aether and +25 Aether when Shrine Attunement is active; Cinderfen repeat clears now pay only tiny XP/resources and no battle item roll.
```

Known risks for v0.2.1:

- Human-style readability still matters: retinue recruitment, rival/trophy rewards, HUD hover feel, side-panel scrolling, captured-site fog readability, and Ashen Outpost pressure need human-paced review even with automated coverage.
- The Vite production build still reports the known large Phaser chunk warning.
- Full e2e is slow and should be run with a long timeout.
- `BattleScene`, `HUD`, `battle-hud.css`, `PlaytestRunner.ts`, `PlaytestAnalyzer.ts`, `CampaignChoiceRules.ts`, `CampaignRewardRules.ts`, `RivalRules.ts`, and reward/results save paths remain the areas to treat carefully.

Recommended next milestones:

1. Human-verify the current Chapter 2 Cinderfen route in the browser before adding more content: Overlook, Waystation, Crossing, Shrine/Attunement, Watch, and Aftermath.
2. Add no further Chapter 2 content until the current route stays green in human readability and balance review.
3. Keep human-paced v0.2.1 campaign readability and balance review in mind while implementing Chapter 2 content, especially retinue, rival/trophy, HUD/fog, and Ashen Outpost readability.
4. Avoid workers, enemy construction, full new factions, diplomacy, procedural campaign, crafting, durability, broad loot complexity, full trophy rooms, and broad army-management systems.

## Clean Checkpoint - 2026-05-03 08:58 -04:00

Scope: checkpoint the v0.2.1 baseline candidate plus the minimal non-playable Chapter 2 scaffold before any Chapter 2 gameplay implementation.

Checkpoint commit:

```text
2d5b0cd58da7ed61967d41b02c3b17b28c1fcbf2
Checkpoint v0.2.1 baseline and Chapter 2 scaffold
```

Verification:

```text
npm test
PASS: 36 test files, 217 tests, latest duration 11.91s

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only

npm run test:e2e -- --reporter=line
PASS: 49 Playwright tests in 19.2m

npm run playtest:sim
PASS: 180 deterministic simulated runs across 60 campaign battle nodes
```

Branch sync status:

```text
`git fetch origin` completed before commit, and `main` was aligned with `origin/main`.
Checkpoint commit `2d5b0cd58da7ed61967d41b02c3b17b28c1fcbf2` was pushed successfully to `origin/main`.
The checkpoint metadata follow-up was pushed successfully; final `git status -sb` reported `## main...origin/main`.
```

Remaining known risks:

- Human-style readability still matters for retinue recruitment, rival/trophy rewards, HUD hover feel, side-panel scrolling, captured-site fog readability, and Ashen Outpost pressure.
- The minimal Chapter 2 scaffold has no playable battle content yet; keep the first Chapter 2 implementation small.
- The Vite production build still reports the known large Phaser chunk warning.
- Full e2e is slow and should be run with a long timeout.
- `BattleScene`, `HUD`, `battle-hud.css`, `PlaytestRunner.ts`, `PlaytestAnalyzer.ts`, `CampaignChoiceRules.ts`, `CampaignRewardRules.ts`, `RivalRules.ts`, and reward/results save paths remain the highest-risk areas.

Next recommended milestone: Chapter 2 vertical slice implementation.

## Minimal Chapter 2 Scaffold - 2026-05-03

Scope: add only a harmless Chapter 2 campaign scaffold so the map can preview the next phase without disturbing the Border Marches mini-campaign.

What changed:

- Added chapter metadata for `border_marches` and `cinderfen_road`.
- Added campaign-map chapter cards and save normalization for `selectedChapterId`.
- Added `cinderfen_overlook` as a non-playable Chapter 2 event placeholder.
- Added `cinderfen_crossing` as a locked future battle placeholder that names the future `Cinderfen Causeway` map but cannot launch it.
- Kept playable Chapter 1 progress at 8 current nodes; placeholder nodes are excluded from current progress and playtest scenarios.
- Added content validation and tests for chapter/node references, old-save normalization, placeholder launch blocking, and browser smoke visibility.
- No Chapter 2 battle map, units, full faction, workers, enemy construction, diplomacy, procedural generation, crafting, or balance changes were added.

Verification:

```text
npm test
PASS: 36 test files, 217 tests

npm run build
PASS: known Vite large-chunk warning only

npm run test:e2e -- --reporter=line
PASS: 49 Playwright tests

npm run playtest:sim
PASS: 180 deterministic simulated runs
```

Recommended next milestones:

1. Keep the scaffold harmless and green.
2. Human-paced v0.2.1 campaign readability and balance review before adding Chapter 2 gameplay content.
3. v0.3 Chapter 2 vertical slice implementation only after the scaffold remains green.
4. Keep future additions compact and data-driven; avoid workers, enemy construction, new factions, diplomacy, procedural campaign, crafting, durability, broad loot complexity, full trophy rooms, and broad army-management systems.

## Full Verification Checkpoint - 2026-05-02 22:56 -04:00

Scope: checkpoint Rival / Nemesis Persistence V1, Rival Rewards and Trophies V1, the CampaignRules module split, and the HUD interaction / captured-site fog polish before any new feature work.

Verification run:

```text
npm test
PASS: 36 test files, 210 tests, latest duration 11.43s

npm run build
PASS: TypeScript compile and Vite production build. Known large-chunk warning only.
Latest bundle: assets/index-jewPzW0W.js, 1,883.55 kB minified / 449.61 kB gzip.

npm run test:e2e -- --reporter=line
PASS: 45 Playwright tests in 20.3m.

npm run playtest:sim
PASS: 180 simulated runs across 60 campaign battle nodes. PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated.
```

Important verification note:

- The first full Playwright run in this checkpoint failed 6 battle-HUD/status assertions after the narrow HUD/fog polish.
- A small UI-only fix was applied: `HUD.ts` now allows forced command/test-hook refreshes plus a short deferred flush; `UISystem.ts` treats explicit zero-delta HUD refreshes as forced; the enemy-hero scout test hook re-announces and refreshes its status.
- The 7 affected Playwright paths then passed in a focused rerun, and the full 45-test suite passed afterward.
- No gameplay balance, maps, factions, workers, enemy construction, diplomacy, or save format changed.

Checkpoint commit:

```text
59113746a09f5f1c2cbf053c640a24ab21e92b9b
```

## HUD Interaction And Captured-Site Fog Polish - 2026-05-02

Goal: fix player-reported live battle UX issues where hovering construction/unit command options flickered and became hard to click, scrollable panels jumped back up, and some conquered mines stayed under fog after capture.

What changed:

- `src/game/ui/HUD.ts` now defers routine DOM rebuilds while pointer/focus is inside stable HUD interaction panels (`.side-panel` and `.objectives-panel`). This prevents Build/Train/Research command buttons from being replaced under the mouse while the player is trying to click them.
- `HUD.ts` now captures and restores scroll positions for scrollable battle HUD panels when a rebuild is necessary.
- `src/game/styles/battle-hud.css` now contains side/objective panel overscroll, instant scroll behavior, and stable scrollbar gutter rules to reduce scroll chaining and layout jitter.
- `src/game/scenes/BattleScene.ts` now includes player-owned capture sites as small vision sources, so captured mines/resource sites stay locally revealed after the capturing units move away.
- No balance values, unit stats, AI, economy values, save format, maps, factions, workers, or enemy construction changed.

Verification completed in this focused UX pass:

```text
npm test
PASS: 36 test files, 210 tests

npm run build
PASS: production build; known Vite large-chunk warning only

Targeted Playwright sanity against http://127.0.0.1:4182/
PASS: hovered build command button stayed as the same DOM node across HUD refresh; side-panel scroll remained at 120 across HUD refresh; captured Aether site became fog-visible.

Browser Use status check at http://127.0.0.1:4182/
PASS: current in-app browser tab title Ascendant Realms; browser console errors 0
```

Full Playwright e2e and `npm run playtest:sim` were rerun during the 2026-05-02 22:56 checkpoint after the HUD stale-refresh fix above. A later permanent-regression coverage pass expanded the full suite to 49 Playwright tests, and that full suite passed. Latest simulator baseline remains 180 passing runs.

## CampaignRules Module Split - 2026-05-02

Goal: safely refactor `src/game/core/CampaignRules.ts` into focused pure-rule modules without changing gameplay, balance, save format, or UI.

What changed:

- `CampaignRules.ts` is now a 1-line compatibility facade: `export * from "./campaign";`.
- Added focused modules under `src/game/core/campaign/`:
  - `CampaignNodeRules.ts`: started campaign saves, node status, prerequisites, unlock refresh, node completion, progress summary.
  - `CampaignChoiceRules.ts`: choice availability and choice application orchestration.
  - `CampaignRewardRules.ts`: campaign node rewards, campaign resource add/subtract/spend helpers, duplicate reward-resource reconciliation.
  - `CampaignReputationRules.ts`: reputation delta application and clamping.
  - `CampaignModifierRules.ts`: compatibility re-exports for campaign modifier helpers.
  - `CampaignTownRules.ts`: choice claim ids, town-service claim checks, town-service use tracking.
  - `CampaignRivalRules.ts`: compatibility re-export for rival rule helpers.
  - `index.ts`: focused campaign rules barrel.
- Existing imports from `../core/CampaignRules` and `./CampaignRules` continue to work.
- No formulas, reward values, costs, save shape, UI copy, or gameplay behavior intentionally changed.

Verification completed in this refactor pass:

```text
npm test
PASS: 36 test files, 210 tests

npm run build
PASS: production build; known Vite large-chunk warning only

npm run test:e2e -- --reporter=line
PASS: 45 Playwright tests in 24.4m

npm run playtest:sim
PASS: 180 simulated runs; too_easy none, too_hard none, Ashen Outpost beatable yes, Stronghold warnings none
```

## Rival Persistence Balance Pass - 2026-05-02

Goal: tune rival persistence so it adds drama without unfair snowballing, while avoiding new systems, maps, workers, enemy construction, factions, diplomacy, crafting, durability, broad loot complexity, or a full trophy room.

Telemetry read before tuning:

- `PLAYTEST_TELEMETRY.json` had 180 deterministic runs and 108 commander-node runs.
- Current structural result was already clean: `too_easy: none`, `too_hard: none`, Stronghold warnings `none`, and Ashen Outpost beatable `yes`.
- Rival modifiers were not active in the baseline suite because scripted commander battles are modeled as first encounters.
- Rival outcomes by commander:
  - Veyra: 36 runs, 12 wins / 12 defeats / 12 timeouts, commander defeated 24 times, joined attacks 17 times, 12 non-winning pressure runs, 12 one-time first rewards.
  - Gorak: 36 runs, 12 wins / 23 defeats / 1 timeout, commander defeated 13 times, joined attacks 12 times, 12 non-winning pressure runs, 12 one-time first rewards.
  - Captain Malrec: 36 runs, 22 wins / 0 defeats / 14 timeouts, commander defeated 36 times, joined attacks 14 times, 14 non-winning pressure runs, 22 one-time first rewards.
- Escaped-rival victories were 0 in deterministic runs because current scripted victories defeat the commander before the Stronghold falls. Keep the escape condition unchanged until human play shows a confusing escape case.
- Duplicate first-defeat rewards were 0 in the baseline suite because it runs first encounters; duplicate prevention is covered by save/unit/e2e tests through `rivalTrophies`.

What changed:

- No rival HP, damage, ability, map assignment, XP reward, resource reward, item reward, trophy effect, retinue, Stronghold, or escape-condition balance values changed.
- Kept persisted rematch modifiers at the current tiny ceiling: escaped rivals get +5% HP; triumphant rivals get +5% damage.
- Tightened Results copy from `First-defeat reward` to `One-time first-defeat reward`, and repeat defeats now say the reward was already claimed for this campaign.
- Tightened Campaign Map Rival Intel copy so first-defeat rewards are described as one-time and trophies as cosmetic save-backed records.
- Tightened trophy effect copy in `rivalRewards.ts` to call rewards one-time.
- Updated the playtest Markdown writer so regenerated telemetry includes a `Rival Persistence Balance Pass Result` section with commander-run counts, reward/trophy counts, duplicate-prevention observations, and modifier-run counts.

Current balance result:

- The rival system remains useful and readable through saved outcomes, small rematch modifiers, and one-time reward/trophy payoffs.
- No structural too-hard or too-easy node was introduced by this pass.
- First-defeat rewards remain meaningful but not repeatable or farmable. If later campaign play shows the reward package becoming mandatory, reduce XP/resources before touching rival combat stats.

Verification completed in this balance/readability pass:

```text
npm test
PASS: 36 test files, 210 tests

npm run build
PASS: production build; known Vite large-chunk warning only

npm run test:e2e -- --reporter=line
PASS: 45 Playwright tests in 23.1m

npm run playtest:sim
PASS: 180 simulated runs; too_easy none, too_hard none, Ashen Outpost beatable yes, Stronghold warnings none
```

## Rival Rewards And Trophies V1 - 2026-05-02

Goal: make first victories over persistent rivals feel rewarding without adding crafting, durability, new factions, diplomacy, broad loot complexity, new maps, workers, enemy construction, or a full trophy room.

What changed:

- Added `src/game/data/rivalRewards.ts` with data-driven first-defeat reward definitions for Gorak Emberhand, Veyra of the Cinders, and Captain Malrec.
- Added three unique rival-themed item definitions in `src/game/data/items.ts`: `ember_raider_blade`, `cinderseer_lens`, and `malrecs_bastion_sigil`.
- Campaign saves now persist `rivalTrophies` records with trophy id, enemy hero id, earned timestamp, source node id, label, description, and optional effect copy. Old saves normalize safely to an empty trophy list.
- `RivalRules.updateRivalAfterBattle` now grants first-defeat rewards only when the rival had not been defeated before and the trophy has not already been claimed. Repeat defeats set duplicate-prevention telemetry/copy instead of granting another reward.
- First-defeat rewards are intentionally post-battle only:
  - Gorak: +80 XP, +25 Crowns, +15 Iron, Ember Raider Blade, +2 Free Marches reputation, Gorak's Emberbrand trophy.
  - Veyra: +90 XP, +20 Aether, Cinder-Seer Lens, +1 Old Faith reputation, Cinder-Seer's Cracked Lens trophy.
  - Captain Malrec: +140 XP, +60 Crowns, +25 Iron, Malrec's Bastion Sigil, +4 Free Marches reputation, Malrec's Outpost Standard trophy.
- Results now shows `Rival Defeated`, the first-defeat reward, trophy label, and trophy note when a new rival trophy is earned. Repeat defeats show the first-defeat reward as already claimed.
- Campaign Map Rival Intel now shows whether each known rival's first-defeat reward is claimed and includes a compact Rival Trophies section.
- Playtest telemetry now includes `rivalFirstDefeatRewardEarned`, `rivalDuplicateRewardPrevented`, and `rivalTrophyEarned`; `PLAYTEST_TELEMETRY.md` and `.json` were regenerated.
- Added/updated unit, save, presentation, content-validation, e2e, and simulator coverage for first-defeat rewards, duplicate prevention, trophy persistence, Results copy, Campaign Map trophy display, and telemetry.

Current balance read:

- No enemy hero HP, damage, cooldown, join timing, map assignment, retinue, or Stronghold values changed.
- Rewards are one-time and save-backed, so they should make commander victories satisfying without becoming a repeat farm.
- Trophy effects are copy-only in V1; the actual small rewards are granted immediately on first defeat.
- Simulator structural result after telemetry regeneration remains unchanged: no structural `too_easy`, no structural `too_hard`, no Stronghold warnings, and Ashen Outpost remains beatable.

Verification completed in this implementation pass:

```text
npm test
PASS: 36 test files, 210 tests

npm run build
PASS: production build; known Vite large-chunk warning only

npm run test:e2e -- --reporter=line
PASS: 45 Playwright tests in 23.0m

npm run playtest:sim
PASS: 180 simulated runs; too_easy none, too_hard none, Ashen Outpost beatable yes, Stronghold warnings none
```

## Rival / Nemesis Persistence V1 - 2026-05-02

Goal: make the existing Enemy Hero / Rival Commander V1 commanders persist as campaign rivals without adding workers, enemy construction, new factions, diplomacy, procedural campaign, new maps, or a large nemesis system.

What changed:

- Added `src/game/core/RivalRules.ts` for initial state, outcome updates, campaign preview/intel view models, small launch modifiers, stat application, copy labels, and telemetry snapshots.
- Campaign saves now persist `rivals` records with enemy hero id, encounters, defeats, victories against the player, last node, last outcome, disposition, active modifiers, and known/unseen state. Old saves normalize safely to an empty rival list.
- Battle completion now updates rival state after campaign battles with enemy heroes:
  - player victory plus defeated commander => `defeated`, first defeat `humiliated`, +35 Crowns, +2 Free Marches reputation once;
  - player victory with surviving commander => `escaped`, `wary`, +5% HP next encounter;
  - player defeat => `triumphant`, `emboldened`, +5% damage next encounter.
- Campaign Map now shows Rival Intel and selected-node rival status/effect copy.
- Campaign battle launch aggregates rival modifiers; `BattleSceneSpawner` applies the small HP/damage modifier only to the named enemy hero unit.
- Battle start copy can warn about active rival rematch modifiers.
- Results now show Rival Outcome with encountered commander, outcome, disposition, record, consequence, and one-time reward text when applicable.
- Playtest simulator telemetry now includes `rivalStateBefore`, `rivalOutcome`, `rivalStateAfter`, `rivalModifiersApplied`, and `lossesAgainstRival`.
- Added unit/presentation/e2e coverage for initial rival state, defeated/escaped/triumphant outcomes, save/load normalization, campaign preview/intel, launch modifier aggregation, Results copy, and a seeded known-rival campaign flow.

Current balance read:

- No enemy hero base HP/damage/ability/cooldown/XP numbers changed for this slice.
- Persistence modifiers are deliberately tiny and future-encounter-only: escaped +5% HP, triumphant +5% damage.
- The simulator still treats every commander battle as a first encounter, so baseline structural results remain directly comparable to the Enemy Hero V1 balance pass.
- Latest simulator pass after the feature still reports no structural `too_easy`, no structural `too_hard`, no Stronghold warnings, and Ashen Outpost beatable.

Verification completed in this implementation pass:

```text
npm test
PASS: 36 test files, 208 tests

npm run build
PASS: production build; known Vite large-chunk warning only

npm run test:e2e -- --reporter=line
PASS: 45 Playwright tests in 23.7m. A focused rival flow passed first, then the full suite passed after increasing one existing slow campaign-choice test timeout from 70s to 100s.

npm run playtest:sim
PASS: 180 simulated runs; too_easy none, too_hard none, Ashen Outpost beatable yes, Stronghold warnings none
```

## Playtest Simulator Module Split - 2026-05-02

Goal: refactor the deterministic automated playtest simulator into focused modules without changing gameplay, balance, simulation schema, or intended simulator outcomes.

What changed:

- Replaced `src/game/playtest/ScriptedBattlePlaytest.ts` with an 8-line compatibility facade.
- Added focused modules in `src/game/playtest/`: `PlaytestTypes.ts`, `PlaytestProfiles.ts`, `PlaytestScenarios.ts`, `PlaytestStrategies.ts`, `PlaytestRunner.ts`, `PlaytestTelemetry.ts`, `PlaytestAnalyzer.ts`, `PlaytestReportWriter.ts`, and `index.ts`.
- Kept existing imports working through `ScriptedBattlePlaytest.ts`, so `tools/runPlaytestSim.ts` and `ScriptedBattlePlaytest.test.ts` still import the same public API.
- Preserved the telemetry JSON schema at schema version 2 and regenerated `PLAYTEST_TELEMETRY.md` / `PLAYTEST_TELEMETRY.json` with 180 deterministic runs.
- Preserved the generated enemy-hero telemetry read in `PLAYTEST_TELEMETRY.md` so future simulator runs do not drop the current docs-consolidation note.
- No gameplay, balance, campaign, map, faction, worker, enemy construction, or Rival/Nemesis Persistence behavior was added.

Verification:

```text
npm test
PASS: 35 test files, 200 tests

npm run build
PASS: production build; known Vite large-chunk warning only

npm run test:e2e -- --reporter=line
PASS: 44 Playwright tests in 23.0m. Use a long timeout; line reporter output is quiet until completion when redirected.

npm run playtest:sim
PASS: 180 simulated runs across 60 campaign battle node/profile summaries; too_easy none, too_hard none, Ashen Outpost beatable yes, Stronghold warnings none
```

## Randomized Item Affixes V1 - 2026-05-01

Goal: add a small, safe affix layer to item instances without crafting, durability, item art, inventory rewrites, or large loot complexity.

What changed in this pass:

- Added `src/game/data/itemAffixes.ts` with 9 data-driven affixes: Sturdy, Sharp, Guarding, Aether-Touched, Commanding, Faithful, Swift, Embered, and Ranger's.
- Added `ItemAffixDefinition` to `ItemTypes.ts`: affixes have `id`, `name`, `tier`, `allowedSlots`, `statMods`, `tags`, and `weight`.
- Added rarity-based affix counts: common 0-1, uncommon 1, rare 1-2, epic 2, legendary 2-3. Deterministic mode picks weighted slot-filtered affixes for tests.
- Reward-generated item instances now roll and persist affix IDs when item definitions are available. Old empty-affix instances remain valid.
- Equipment stat calculation now applies base item stats plus valid equipped affix stats. Unknown or slot-invalid saved affix IDs are ignored by stat application.
- Results and Inventory UI now show affix names, base stats, affix stat contribution, total item stats, and equip preview deltas.
- Content validation now checks affix IDs, names, tiers, slots, tags, stat values, and weights.
- E2E adds a deterministic affixed reward path: earn an affixed Weathered Command Sword, verify Sharp and total stats in Results, equip it, verify save persistence and Inventory stats.

Verification completed for this pass:

```text
npm test
PASS: 33 test files, 178 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 41 Playwright tests in 16.1m

npm run playtest:sim
PASS: 105 simulated runs across 35 campaign battle nodes; no structural too_hard nodes, no too_easy nodes, Ashen Outpost beatable, no Stronghold warnings

Browser Use preview smoke at http://127.0.0.1:4182/
PASS: main menu visible, browser console errors: 0
```

## Campaign Consequences And Reputation Hooks - 2026-05-01

Goal: make campaign choices and reputation visibly affect play without adding a broad diplomacy system.

What changed in this pass:

- Added `src/game/data/reputation.ts` with data-driven ranks for Free Marches, Common Folk, Old Faith, Ashen Covenant, and Sylvan Concord. Thresholds are Friendly `>= 25`, Honored `>= 50`, Disliked `<= -25`, and Hostile `<= -50`.
- Added four compact reputation effects:
  - Common Folk Friendly: Marcher Camp choice/service costs are 10% cheaper.
  - Free Marches Friendly: Stronghold upgrade Crown costs are 10% cheaper.
  - Old Faith Friendly: Chapel choices with Aether rewards grant +5 extra Aether.
  - Ashen Covenant Hostile: Ashen battle launches include the `ashen_hostile_pressure` modifier, spawning one extra Raider.
- Campaign choice rules now preview and apply adjusted costs/rewards, so discounts and Chapel bonuses are visible before purchase and deterministic when applied.
- Stronghold purchase rules now accept hero reputation context and spend discounted Crown costs when Free Marches Friendly is active.
- Campaign map UI now shows reputation value, rank, active effects, adjusted cost/reward lines, reputation deltas, modifier grants/removals, and whether a choice completes its node.
- Battle launch now merges campaign modifiers, reputation-derived launch modifiers, and Stronghold modifiers. The Ashen hostile pressure effect uses the existing launch-modifier path and battle telemetry.
- Content validation now checks reputation effect references, ranks, modifiers, discount multipliers, bonus values, and scoped node references.
- Save/load needed no schema change; existing reputation values persist through the current save format.

Verification completed for this pass:

```text
npm test
PASS: 32 test files, 170 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 40 Playwright tests in 15.3m

npm run playtest:sim
PASS: 105 simulated runs across 35 campaign battle nodes; no structural too_hard nodes, no too_easy nodes, Ashen Outpost beatable, no Stronghold warnings

Browser Use preview smoke at http://127.0.0.1:4181/
PASS: main menu visible, campaign reputation panel rendered, browser console errors: 0
```

## Stronghold Development Tier II - 2026-05-01

Goal: add a compact second tier of Stronghold upgrades without turning the campaign into a city-builder.

What changed in this pass:

- Added five data-driven Tier II upgrades in `src/game/data/strongholdUpgrades.ts`: Training Yard II, Watch Post II, Quartermaster Stores II, Chapel Corner II, and Ranger Paths II.
- Each Tier II upgrade requires its matching Tier I upgrade through `prerequisites.upgradeRanks`.
- Implemented Tier II effects through existing launch-effect hooks:
  - Training Yard II: Militia and Rangers train 10% faster and Retinue capacity increases by +1.
  - Watch Post II: first enemy wave warning arrives 15s earlier on top of Watch Post I, and player Watchtowers reach +20% total range.
  - Quartermaster Stores II: additional starting battle resources, including Iron and Aether.
  - Chapel Corner II: hero starts with +8% max HP and Mana total.
  - Ranger Paths II: +1 starting Ranger.
- Stronghold UI now exposes the new effects through the existing cost/effect/locked-state cards.
- Content validation now checks that Tier II Stronghold upgrades require their previous tier at rank 1.
- Battle launch support covers Tier II through existing modifier aggregation, runtime starter resources, hero stat modifiers, enemy warning lead, Watchtower range, construction/training modifiers, and extra starting unit spawning.
- The simulator now includes a `tier_two_quartermaster_path` profile and writes aggregated Stronghold effects into telemetry so every launch effect is visible in JSON and Markdown.
- The Stronghold e2e now seeds resources, verifies a locked Tier II card, buys Quartermaster Stores I and II, launches Border Village, and verifies the Tier II starting-resource package in battle.

Verification completed for this pass:

```text
npm test
PASS: 32 test files, 162 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 39 Playwright tests in 14.6m

npm run playtest:sim
PASS: 105 simulated runs across 35 profile-node summaries; no structural too_hard nodes, no too_easy nodes, no Stronghold warnings

Browser Use preview smoke at http://127.0.0.1:4180/
PASS: main menu visible, browser console errors: 0
```

## Commands

Run these from the project root:

```bash
npm install
npm run dev
npm test
npm run build
npm run preview
npm run test:e2e
npm run test:e2e:headed
npm run assets:prompts
npm run assets:ui-kit
npm run assets:process-battle-sprites
npm run assets:manifest
npm run assets:validate
npm run assets:refresh
```

Notes:

- `npm run test:e2e` starts Vite through Playwright.
- The e2e suite intentionally uses one worker for stability.
- Use a long shell timeout for e2e. A 3-minute shell timeout is too short; the latest full run took 23.0 minutes.
- `npm run assets:refresh` is only needed after changing asset registry, manual art, processed sprites, or manifest inputs.

## Latest Verified Status

Fresh focused UX verification completed on 2026-05-02 at 21:58 -04:00 after the HUD interaction / captured-site fog polish:

```text
npm test
PASS: 36 test files, 210 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

Targeted Playwright sanity against http://127.0.0.1:4182/
PASS: hovered command button stable across HUD refresh; side-panel scroll preserved at 120; captured Aether site visible through fog.

Browser Use status check at http://127.0.0.1:4182/
PASS: current in-app browser tab title Ascendant Realms; browser console errors 0
```

Latest full e2e and simulator verification remains the 2026-05-02 21:40 -04:00 CampaignRules module split pass:

```text
npm run test:e2e -- --reporter=line
PASS: 45 Playwright tests in 24.4m. This suite is slow; use a long timeout. Slow files noted by Playwright: tests/e2e/deep-flow.spec.ts and tests/e2e/layout.spec.ts.

npm run playtest:sim
PASS: 180 simulated runs across 60 campaign battle node/profile summaries; too_easy none, too_hard none, Ashen Outpost beatable yes, Stronghold warnings none

Browser Use preview smoke at http://127.0.0.1:4182/
The latest full main-menu copy sanity remains the previous `Prototype v0.2` preview with 0 console errors. The later HUD/fog handoff update checked the current in-app tab and console only.
```

Enemy Hero V1 result
Three data-driven rivals exist: Gorak Emberhand on Bandit Hillfort, Veyra of the Cinders on Aether Well Ruins, and Captain Malrec on Ashen Outpost. Campaign launches carry `enemyHeroId`, the existing `enemy_commander` spawn becomes the named rival, scout/battle/results feedback is visible, the Ashen commander objective is `Defeat Captain Malrec`, and telemetry records hero id, defeated state, join timing, and losses involving the rival.

Enemy Hero balance result
No numeric gameplay changes. Retained current enemy hero HP, damage, ability cooldowns/ranges, Normal commander join timing, XP values, objective credit, and campaign map assignments. Old Stone Road remains unassigned to an enemy hero because all 36 Old Stone Road simulations already win on the Easy lane and adding a rival there would risk early commander noise.

Enemy Hero telemetry read
Veyra appears in 36 runs, is defeated in 24, joins attacks in 17, and is involved in 12 player losses. Gorak appears in 36 runs, is defeated in 13, joins attacks in 12, and is involved in 12 losses. Captain Malrec appears in 36 runs, is defeated in 36, joins attacks in 14, and is involved in 14 losses. No structural too-easy or too-hard node emerged.

Retinue balance result
No numeric gameplay changes. Retained capacity 2/+1 Training Yard II, Seasoned+ eligibility, 55/130/230 XP thresholds, +4%/+8%/+12% rank bonuses, Elite-only +1 armor, Quartermaster II interaction, and permanent retinue removal on death.

Rival Rewards result
First defeats now grant one-time data-driven rewards and trophies for Gorak, Veyra, and Captain Malrec. Repeat defeats are blocked by `rivalTrophies`, Results shows reward/trophy copy, Campaign Map shows earned trophies, and simulator telemetry records first-defeat reward/trophy outcomes.

Rival Persistence balance result
No numeric gameplay changes. Retained +5% HP for escaped rivals, +5% damage for triumphant rivals, current first-defeat XP/resources/items/trophies, current escape condition, and current map assignments. Results, Rival Intel, trophy effect copy, and regenerated telemetry now call first-defeat rewards one-time and surface modifier/reward/trophy counts more clearly.

CampaignRules refactor result
No gameplay, balance, save format, or UI changes. `CampaignRules.ts` is now a 1-line compatibility facade over focused modules in `src/game/core/campaign/`.

HUD/fog polish result
Player-reported command hover flicker, side-panel scroll snap-back, and conquered-site fog readability issues have a focused fix in `HUD.ts`, `battle-hud.css`, and `BattleScene.ts`. Captured player resource sites now provide local vision; routine HUD DOM rebuilds are deferred while the player is interacting with command/objective panels; scroll positions are restored across necessary HUD rebuilds; command/test-hook HUD updates can force a refresh so status and selection copy do not get stuck. Full e2e/sim were rerun in the 2026-05-02 22:56 checkpoint and passed.

Checkpoint commit
59113746a09f5f1c2cbf053c640a24ab21e92b9b

Branch sync
Checkpoint commit `59113746a09f5f1c2cbf053c640a24ab21e92b9b` was pushed successfully to `origin/main`. The checkpoint metadata follow-up was also pushed; final `git status -sb` reported `## main...origin/main`.

Focused item-affix verification on 2026-05-02 during this pass:

- `npm test -- src/game/data/itemAffixes.test.ts src/game/core/HeroProgressionRules.test.ts src/game/progression/ItemComparison.test.ts src/game/core/SaveSystem.test.ts src/game/data/contentValidation.test.ts src/game/battle/BattleRuntime.test.ts`: passed, 6 test files and 57 tests.
- The full e2e suite includes affixed reward display, affix persistence after Equip Now, and Inventory stat display including affix contribution.

Focused reputation/consequence verification on 2026-05-01 during this pass:

- `npm test -- src/game/core/CampaignRules.test.ts src/game/core/StrongholdRules.test.ts src/game/campaign/CampaignMapViewModel.test.ts src/game/core/SaveSystem.test.ts src/game/data/contentValidation.test.ts`: passed, 5 test files and 66 tests.
- The full e2e suite includes reputation rank/effect display, Free Marches Stronghold discount preview, Common Folk Marcher Camp discount preview, and event choice reputation/modifier preview coverage.

Focused Stronghold verification on 2026-05-01 during this pass:

- `npm test -- src/game/core/StrongholdRules.test.ts src/game/core/SaveSystem.test.ts src/game/battle/BattleRuntime.test.ts src/game/data/contentValidation.test.ts src/game/playtest/ScriptedBattlePlaytest.test.ts`: passed, 5 test files and 52 tests.
- `npm run playtest:sim`: passed after the final code/docs update and regenerated both telemetry files.

Recent targeted checks also passed:

```text
npm run test:e2e -- --reporter=line -g "Ashen Outpost landmarks"
PASS: 1 Playwright test, including Normal-fog baseline, scouted Ashen resource sites, neutral camps, fortress buildings, minimap markers, and HUD-overlap guards

npm run test:e2e -- --reporter=line -g "minimap renders marker families"
PASS: 1 Playwright test, including unit/building/site/camp/rally markers, player/enemy/neutral teams, the camera rectangle, and rally/wave/base/resource pings

npm run test:e2e -- --reporter=line -g "unlocked hero ability hotkeys"
PASS: 1 Playwright test, including keyboard casts for Rally Banner, Cleave, and War Cry plus success-feedback stability

npm run test:e2e -- --reporter=line -g "main menu, info"
PASS: 1 Playwright test, including Arcanist and Shepherd save persistence through hero creation, with explicit 60s timeout after the expanded flow measured 35.9s

npm run test:e2e -- --reporter=line -g "battle HUD supports minimap movement"
PASS: 1 Playwright test, including direct canvas click-selection of the live hero and selected-hero HUD state

npm run test:e2e -- --reporter=line -g "all skirmish maps"
PASS: 1 Playwright test after the transient full-suite `net::ERR_NO_BUFFER_SPACE` interruption

npm run test:e2e -- --reporter=line -g "first enemy wave pressure can damage the base and be survived"
PASS: 1 Playwright test, including tracked wave pressure, Command Hall damage, pings, and survival bookkeeping

npm test -- battlePacing
PASS: 1 test file, 3 tests, including ordered difficulty pacing and fog defaults

npm run test:e2e -- --reporter=line -g "skirmish difficulty selection changes fog and starting pressure"
PASS: 1 Playwright test, including Story vs Normal live fog and starting enemy roster differences

npm run test:e2e -- --reporter=line -g "campaign Border Village launches a battle scene"
PASS: 1 Playwright test, including fogged quarry camp/site/unit minimap-marker leak coverage

npm test -- UnitOrderSummary CombatSystem FogOfWarSystem
PASS: 3 test files, 12 tests

npm run test:e2e -- --reporter=line tests/e2e/smoke.spec.ts -g "campaign Border Village launches a battle scene"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line tests/e2e/deep-flow.spec.ts -g "battle HUD supports"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line -g "Ashen Outpost special objectives"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line -g "Ashen Outpost defeat tips"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line -g "alternate Refugee Caravan"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line -g "Old Stone Road victory"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line -g "settings screen persists accessibility options"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line -g "Ashen Outpost objectives do not cover"
PASS: 1 Playwright test

npm test -- ResultsViewModel
PASS: 1 test file, 3 tests

npm run test:e2e -- --reporter=line -g "victory and defeat result actions"
PASS: 1 Playwright test, including defeat Open Hero Inventory navigation to saved hero progress

npm run test:e2e -- --reporter=line -g "victory reward can be kept"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line -g "first campaign battle path"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line -g "Ashen Outpost special objectives"
PASS: 1 Playwright test; the final full-suite run also passes after targeting the visible completed objectives panel
```

## Most Recent Completed Work

### Documentation Consolidation After Enemy Hero V1 - 2026-05-02

Goal: align release, roadmap, README, QA, telemetry, and handoff docs after Enemy Hero / Rival Commander V1 without adding gameplay, changing balance, or refactoring source code.

What changed:

- Updated `CHANGELOG.md`, `README.md`, `RELEASE_CHECKLIST.md`, `ROADMAP.md`, `QA_RUN.md`, `PLAYTEST_TELEMETRY.md`, and this handoff so they consistently describe the v0.2+ state with Unit Veterancy V1, Retinue Camp V1, Enemy Hero / Rival Commander V1, Stronghold Tier II, reputation hooks, and randomized item affixes V1.
- Set the then-current recommended feature milestone to Rival/Nemesis Persistence V1. This is historical; Rival/Nemesis Persistence V1 has since shipped, and the current phase is the v0.3 Chapter 2 Cinderfen slice with Overlook, Waystation, Crossing, Shrine, Malrec trophy consequence, and Watchpost implemented.
- Reiterated that the next slice should not move into workers, enemy construction, new factions, diplomacy, procedural campaign, crafting, or broad army-management systems.
- Added a short current enemy-hero telemetry read to `PLAYTEST_TELEMETRY.md`.

Verification:

```text
npm test
PASS: 35 test files, 200 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning
```

### Checkpoint - Enemy Heroes, Rival Commanders, And v0.2 Polish - 2026-05-02

Goal: create a clean checkpoint before any new feature work while preserving all current dirty work and avoiding gameplay changes.

What changed:

- Re-ran the required verification suite: unit tests, production build, full Playwright e2e, and playtest simulator.
- Hardened the `selectPlayerCommandHallFromScene` e2e helper after the first full Playwright run exposed a slow Command Hall side-panel refresh. This is test-only; no gameplay behavior changed.
- Updated `DEVELOPMENT_CHECKPOINT.md` and this handoff with checkpoint verification status and the then-current recommended milestone.
- Historical next recommended milestone at that checkpoint was Rival/Nemesis Persistence V1. This has since shipped; the current phase is the v0.3 Chapter 2 Cinderfen slice with human verification recommended before more content.

Verification:

```text
npm test
PASS: 35 test files, 200 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 44 Playwright tests in 23.3m

npm run playtest:sim
PASS: 180 simulated runs across 60 campaign battle node/profile summaries
```

### Enemy Hero Balance Pass - 2026-05-02

Goal: use `LLM_GAME_HANDOFF.md`, `BALANCE.md`, `PLAYTEST_TELEMETRY.md`, and `PLAYTEST_TELEMETRY.json` to tune enemy heroes only where telemetry showed unfairness or trivialization.

What changed:

- Applied no numeric gameplay changes. Telemetry shows rival commanders are relevant without creating structural `too_easy` or `too_hard` nodes.
- Kept Old Stone Road without an enemy hero assignment; it is still the Easy second battle lane and already wins 36/36 simulations.
- Kept Veyra on Aether Well Ruins, Gorak on Bandit Hillfort, and Captain Malrec on Ashen Outpost.
- Kept enemy hero HP, damage, ability cooldowns/ranges, Normal commander join timing, XP values, and objective credit unchanged.
- Updated `BALANCE.md` with a before/after knob table and reason for each no-change decision.
- Updated the generated `PLAYTEST_TELEMETRY.md` report through the simulator report writer so future simulator runs preserve the enemy-hero balance read. After the later simulator split, that logic lives in `PlaytestReportWriter.ts`.

Verification:

```text
npm test
PASS: 35 test files, 200 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 44 Playwright tests in 21.5m

npm run playtest:sim
PASS: 180 simulated runs across 60 campaign battle node/profile summaries; too_easy none, too_hard none, Ashen Outpost beatable yes, Stronghold warnings none

Browser Use preview smoke at http://127.0.0.1:4182/
PASS: main menu visible, `Prototype v0.2` present, subtitle present, `Prototype v0.1` absent, browser console errors 0
```

### Enemy Hero / Rival Commander V1 - 2026-05-02

Goal: add a small data-driven enemy hero/rival commander system that makes important battles feel more RPG-like without adding enemy construction, workers, new factions, diplomacy, procedural campaign, or a raid-boss layer.

What changed:

- Added `src/game/data/enemyHeroes.ts` with three named Ashen commanders:
  - Gorak Emberhand, Ashen Raider Captain, assigned to Bandit Hillfort.
  - Veyra of the Cinders, Hexfire Seer, assigned to Aether Well Ruins.
  - Captain Malrec, Outpost Commander, assigned to Ashen Outpost.
- Added Enemy Hero V1 ability definitions for Ember Strike, Rally Raiders, Hexfire Bolt, and Hold the Line.
- Campaign nodes now support optional `enemyHeroId`; campaign battle launches carry that ID through `BattleLaunchRequest`.
- Battle spawning reuses the existing `enemy_commander` slot and replaces its displayed name/stats/XP with the assigned enemy hero. Skirmish remains generic by default.
- Enemy heroes stay under existing commander AI pacing: they defend when the base is threatened and only join attack waves when phase/difficulty/personality commander timing allows it.
- Added `EnemyHeroAbilitySystem` for modest cooldown abilities: short burn strike, small rally damage buff, ranged direct damage, and a short fortress armor aura.
- Added scout feedback, minimap enemy-hero marker, battle-start commander copy, campaign node commander preview, Results commander defeated line, Ashen defeat tip copy, and test hooks for safe Playwright scouting/defeat.
- Ashen Outpost secondary objective copy is now `Defeat Captain Malrec` while still using the existing `defeat_unit` objective target `enemy_commander`.
- Battle stats and simulator telemetry now include `enemyHeroId`, `enemyHeroDefeated`, `timeEnemyHeroJoinedAttack`, and `lossesInvolvingEnemyHero`.
- Updated `DESIGN.md`, `BALANCE.md`, `CONTENT_GUIDE.md`, `ROADMAP.md`, `PLAYTEST_TELEMETRY.md`, `PLAYTEST_TELEMETRY.json`, and this handoff.

Verification for this pass:

```text
npm test
PASS: 35 test files, 200 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 44 Playwright tests in 20.7m

npm run playtest:sim
PASS: 180 simulated runs across 60 campaign battle node/profile summaries; too_easy none, too_hard none, Ashen Outpost beatable yes, Stronghold warnings none

Browser Use preview smoke at http://127.0.0.1:4182/
PASS: main menu visible, `Prototype v0.2` present, subtitle present, `Prototype v0.1` absent, browser console errors 0
```

### Conservative Retinue Balance Pass - 2026-05-02

Goal: use `LLM_GAME_HANDOFF.md`, `BALANCE.md`, `PLAYTEST_TELEMETRY.md`, and `PLAYTEST_TELEMETRY.json` to confirm Unit Veterancy V1 and Retinue Camp V1 are useful without becoming mandatory, tuning only if telemetry clearly showed a structural problem.

What changed:

- Applied no numeric gameplay changes. The telemetry shows no structural `too_easy` or `too_hard` nodes, no-retinue Ashen Outpost remains beatable, one Veteran Militia/Ranger helps without becoming required, and mixed retinue profiles are strong but classified as `needs_human_review`.
- Retained retinue capacity at 2 active units by default and +1 from Training Yard II.
- Retained Seasoned+ eligibility, 55 / 130 / 230 XP thresholds, +4% / +8% / +12% rank bonuses, Elite-only +1 armor, and permanent retinue death/removal.
- Retained Quartermaster II interaction unchanged; the mixed-retinue Quartermaster profile is strong, but not structurally too easy in the deterministic suite.
- Updated `BALANCE.md` with before/after reasoning for each allowed knob.
- Updated the generated `PLAYTEST_TELEMETRY.md` report via the simulator report writer so future simulator runs preserve the no-numeric-change balance result. After the later simulator split, that logic lives in `PlaytestReportWriter.ts`.
- Hardened two slow/flaky Playwright assertions with longer test/wait timeouts only; no gameplay behavior changed.

Verification:

```text
npm test
PASS: 35 test files, 198 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 44 Playwright tests in 21.0m

npm run playtest:sim
PASS: 180 simulated runs across 60 campaign battle node/profile summaries; too_easy none, too_hard none, Ashen Outpost beatable yes, Stronghold warnings none
```

### Veterancy And Retinue Readability UX - 2026-05-02

Goal: make Unit Veterancy V1 and Retinue Camp V1 understandable and satisfying without adding systems, maps, factions, workers, enemy construction, or balance changes.

What changed:

- Selected-unit HUD now shows rank, XP progress to next rank, kills, rank bonuses, and whether the unit is a normal battle unit or a deployed retinue veteran.
- Results `Notable Veterans` now calls out rank-ups, top survivor, retinue candidate count, XP progress, rank bonuses, and eligibility reasons.
- Results `Retinue Camp` recruitment now shows active capacity, base capacity, Training Yard II capacity state, current retinue, eligible recruit count, clear `Add to Retinue` buttons, explicit ineligible reasons, and a full-capacity message instead of a vague disabled state.
- Campaign `Retinue Camp` now shows active capacity, base capacity, Training Yard II capacity bonus state, active saved units with rank/type/XP/kills/bonus copy, the permanent-death V1 rule, and clearer dismiss wording.
- Campaign battle start status now includes `Retinue deployed: ...` when saved retinue units spawn.
- Main menu info copy now explains battle-local ranks, selected surviving veterans, retinue persistence, and permanent death in V1.
- Added pure formatting coverage for veterancy progress/bonus strings, retinue capacity/eligibility labels, Retinue Camp rendering, and Results veteran/retinue rendering.
- Added Playwright coverage for selected-panel veterancy copy, Results veteran summary, visible retinue capacity, eligible add button, full-retinue messaging, and deployed-retinue selected-panel copy.

Verification:

```text
npm test
PASS: 35 test files, 198 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 44 Playwright tests in 18.7m

npm run playtest:sim
PASS: 180 simulated runs across 60 campaign battle node/profile summaries
```

### Product Version Copy Consistency - 2026-05-02

Goal: make visible product/version copy agree with the documented v0.2 prototype baseline without adding gameplay, changing balance, or refactoring unrelated systems.

What changed:

- Main menu eyebrow now says `Prototype v0.2`.
- Main menu now includes the subtitle `v0.2 Prototype - Campaign, Stronghold, Affixes, Veterancy and Retinue`.
- Playwright smoke coverage now asserts the v0.2 label and subtitle are visible and that `Prototype v0.1` is absent from the main menu.
- README, CHANGELOG, RELEASE_CHECKLIST, ROADMAP, DEVELOPMENT_CHECKPOINT, and this handoff now agree with the visible v0.2 product copy.
- The first full e2e run during this pass exposed an existing brittle Ashen Outpost objective-panel assertion. The product-copy change did not touch gameplay; the test now checks the unique `battle-objectives` element with `toContainText("Objectives 3/3")`, matching the rest of that test.

Verification:

```text
npm test
PASS: 35 test files, 194 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line -g "Ashen Outpost special objectives display completed states"
PASS: 1 focused Playwright test after the assertion hardening

npm run test:e2e -- --reporter=line
PASS: 43 Playwright tests in 17.6m

Browser Use preview smoke at http://127.0.0.1:4182/
PASS: main menu visible, `Prototype v0.2` present, subtitle present, `Prototype v0.1` absent, browser console errors 0
```

### Clean Checkpoint Verification - 2026-05-02

Goal: create a clean checkpoint before any new feature work, preserving all current dirty work from Unit Veterancy V1, Retinue Camp V1, Stronghold Tier II, reputation hooks, randomized item affixes V1, the retinue telemetry balance pass, release docs, and the HeroProgressionRules split.

What was verified:

```text
npm test
PASS: 35 test files, 194 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 43 Playwright tests in 18.0m

npm run playtest:sim
PASS: 180 simulated runs across 60 campaign battle node/profile summaries; too_easy none, too_hard none, Ashen Outpost beatable yes, Stronghold warnings none

Browser Use preview smoke at http://127.0.0.1:4182/
PASS: main menu visible, browser console errors: 0; current expected menu label is `Prototype v0.2`
```

Checkpoint commit:

```text
9f96b1f9e5cdf25081c4a817f9c5796000fdfc82
```

Branch sync status:

```text
Post-checkpoint/pre-push: `main...origin/main [ahead 1]` at checkpoint commit `9f96b1f9e5cdf25081c4a817f9c5796000fdfc82`. A small metadata follow-up records this hash before pushing.
```

No gameplay behavior changed during this checkpoint pass; only verification, telemetry regeneration from `npm run playtest:sim`, and checkpoint documentation updates were performed.

### HeroProgressionRules Refactor - 2026-05-02

Goal: split the high-risk hero progression rules file into focused pure-rule modules without changing gameplay, balance, save format, UI, or formulas.

What changed:

- `src/game/core/HeroProgressionRules.ts` is now a 1-line compatibility barrel for existing imports.
- Added focused modules under `src/game/core/progression/`: `HeroStatRules.ts`, `SkillRules.ts`, `EquipmentStatRules.ts`, `ItemRewardRules.ts`, `AffixRules.ts`, `DuplicateRewardRules.ts`, `LevelingRules.ts`, and `index.ts`.
- Public imports through `src/game/core/HeroProgressionRules.ts` still work.
- Important Windows/path note: the compatibility barrel exports from `./progression/index` instead of `./progression` to avoid casing ambiguity with the existing `src/game/core/Progression.ts`.
- No formulas were intentionally changed. This was extraction-only.

Verification completed for this refactor:

```text
npm test -- --run src/game/core/HeroProgressionRules.test.ts src/game/progression/ItemComparison.test.ts src/game/data/itemAffixes.test.ts src/game/core/ResultsFlow.test.ts
PASS: 4 test files, 24 tests

npm test
PASS: 35 test files, 194 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 43 Playwright tests in 18.9m

npm run playtest:sim
PASS: 180 simulated runs across 60 campaign battle node/profile summaries; too_easy none, too_hard none, Ashen Outpost beatable yes, Stronghold warnings none

git diff --check
PASS: no whitespace errors; existing `.gitignore` CRLF warning only

Browser Use preview smoke at http://127.0.0.1:4182/
PASS: main menu visible, browser console errors: 0; current expected menu label is `Prototype v0.2`
```

### Retinue Telemetry Balance Pass - 2026-05-02

Goal: make Unit Veterancy and Retinue Camp V1 useful but not mandatory, using `LLM_GAME_HANDOFF.md`, `BALANCE.md`, `PLAYTEST_TELEMETRY.md`, and `PLAYTEST_TELEMETRY.json` as the source read.

What changed:

- Unit Veterancy thresholds moved from 40 / 100 / 180 XP to 55 / 130 / 230 XP.
- Rank bonuses were softened from +5% / +10% / +15% to +4% / +8% / +12%.
- The +1 armor bonus now starts at Elite instead of Veteran, keeping Veteran useful without making every saved Veteran a small armor upgrade.
- The simulator now includes combined retinue profiles for mixed retinue plus Training Yard II and mixed retinue plus Quartermaster II.
- Simulator retinue deployment now respects live campaign capacity: 2 active units by default, +1 only after Training Yard II is purchased.
- Retinue death handling remains the simple V1 permanent-removal rule. No wounded timer, replacement UI, workers, enemy construction, maps, factions, diplomacy, or crafting were added.

Telemetry read after this pass:

- No retinue baseline: 9-3-3 overall; Ashen Outpost is 1-0-2, with Safe Beginner winning and no structural `too_hard`.
- One Veteran Militia: 10-3-2 overall; Ashen Outpost becomes 2-0-1, useful but not required.
- One Veteran Ranger: 10-3-2 overall; Ashen Outpost becomes 2-0-1, useful but not required.
- Mixed retinue: 11-3-1 overall; Ashen Outpost sweeps 3-0 and stays flagged `needs_human_review`.
- Retinue plus Training Yard II: 11-3-1 overall; third-slot Ashen starts 7 Militia / 3 Rangers and is flagged `needs_human_review`, not structural `too_easy`.
- Retinue plus Quartermaster II: 11-3-1 overall; Ashen sweep is flagged for human review because starter resources plus mixed retinue are visibly strong.
- Early nodes produce no structural `too_easy`; Old Stone Road retinue sweeps remain human-review items because the no-retinue baseline already wins all scripts.

### Retinue Camp V1 - 2026-05-02

Goal: let a small number of surviving campaign veterans persist across battles as the hero's personal retinue without adding workers, enemy construction, diplomacy, crafting, new factions, or a large army-management layer.

What changed:

- Added `src/game/core/RetinueRules.ts` for capacity, eligibility, add/dismiss, deployment, survivor updates, and death removal.
- Campaign retinue capacity is 2 active units by default; Training Yard II adds +1 capacity.
- Eligible recruits come from campaign victory Results Notable Veterans: player-owned surviving non-hero units that are Seasoned or better.
- Campaign saves now persist `retinueUnits` with retinue ID, unit type, optional name, rank, XP, kills, source battle, acquired timestamp, and status. Old saves normalize safely to an empty retinue.
- Results can add eligible surviving veterans to the retinue when capacity is available. Full retinues show current saved units and disable additional adds rather than opening replacement UI.
- Campaign Map now has a Retinue Camp panel with capacity, saved units, rank/type, and a simple Dismiss button.
- Campaign battle launches pass active retinue units through `BattleLaunchRequest`; `BattleSceneSpawner` deploys them near the player start with saved rank, XP, kills, and rank stat bonuses.
- Skirmish stays retinue-free by default.
- V1 death handling is permanent removal after the battle if a retinue unit dies. There is no wounded recovery timer in this slice.
- Retry launches refresh campaign retinue from the current save so dead/dismissed retinue units are not reintroduced from an older Results payload.
- Added deterministic retinue simulator profiles: no retinue, one Veteran Militia, one Veteran Ranger, mixed Veteran Militia plus Seasoned Ranger, mixed retinue plus Training Yard II, and mixed retinue plus Quartermaster II.

Fresh Retinue Camp V1 verification completed on 2026-05-02:

```text
npm test
PASS: 35 test files, 194 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 43 Playwright tests in 18.5m

npm run playtest:sim
PASS: 180 simulated runs across 60 campaign battle node/profile summaries; too_easy none, too_hard none, Ashen Outpost beatable yes, Stronghold warnings none
```

### Unit Veterancy V1 - 2026-05-02

Goal: make ordinary battle units feel like they can become veterans without adding workers, enemy construction, new factions, diplomacy, crafting, maps, or broad army persistence.

What changed:

- Added data-driven unit veterancy rules in `src/game/data/unitVeterancy.ts`.
- Added battle-local unit veterancy state for runtime unit instances: unit instance ID, unit type ID, XP, rank, kills, damage dealt, survived-battle state, and rank-up state.
- Added four ranks: Recruit, Seasoned, Veteran, and Elite.
- Added rank bonuses, currently tuned to Seasoned +4% max HP/damage, Veteran +8% max HP/damage, and Elite +12% max HP/damage plus +1 armor.
- Units earn XP from actual damage dealt, kills using target XP value, and surviving a victorious battle.
- Rank bonuses apply immediately to player non-hero units during battle.
- Selected-unit UI now shows unit rank, unit XP, and kills.
- Rank-ups use the existing floating/status message path.
- Victory Results now show Notable Veterans, including ranked-up units, top surviving unit, kills, damage dealt, and campaign retinue recruitment when eligible.
- Normal units are still not automatically persisted; Retinue Camp V1 only saves selected campaign veterans under a small cap.
- Added pure tests for thresholds, XP rules, stat bonuses, rank-up behavior, and veteran Results summaries.
- Added Playwright coverage that grants deterministic unit XP, verifies the selected-unit panel, forces victory, and verifies the Results veteran summary.

Verification passed for this pass:

```text
npm test
PASS: 34 test files, 186 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 42 Playwright tests in 16.2m

npm run playtest:sim
PASS: 105 simulated runs across 35 campaign battle nodes
```

Next recommended work after Unit Veterancy plus Retinue was human-paced campaign balance and readability review. Enemy Hero / Rival Commander V1, Rival/Nemesis Persistence V1, Rival Rewards and Trophies V1, and the current Chapter 2 Cinderfen slice have since shipped into the dirty workspace; human campaign balance/readability review is still recommended before more gameplay.

### v0.2 Prototype Baseline Documentation - 2026-05-02

Goal: make the current Ascendant Realms prototype easy to understand, share, release-check, and continue from without adding gameplay, changing balance, or refactoring code.

What changed:

- Created `CHANGELOG.md` with the v0.2 prototype baseline summary: campaign/skirmish structure, hero progression, construction/training/upgrades, fog/minimap, Stronghold Tier I/II, reputation effects, randomized item affixes V1, automated playtest simulator, and current verification status.
- Created `RELEASE_CHECKLIST.md` with required release commands, expected v0.2 results, the known Vite chunk warning, optional preview check, and manual QA areas that remain outside automation.
- Updated `README.md` so setup, feature summary, known limitations, and next-feature prompts match the current baseline instead of older Tier I/early simulator status.
- Updated `ROADMAP.md` to name Retinue and Unit Veterancy V1 as the next feature milestone at the time of the v0.2 baseline. Retinue Camp V1, Enemy Hero / Rival Commander V1, Rival/Nemesis Persistence V1, Rival Rewards and Trophies V1, and the current Chapter 2 Cinderfen slice have since been implemented in the working tree.
- Marked this handoff as the v0.2 prototype baseline and corrected the published branch status to `main...origin/main` at `9cd3205e3d1be23ed967bd51f315bab3d39cc52e`.

Verification passed for this docs-only pass: `npm test` and `npm run build`.

### Campaign Reputation Choice Preview Recheck - 2026-05-02

Goal: make reputation consequences more visible on campaign choices without adding diplomacy, new factions, or a broader faction simulation.

What changed:

- Confirmed the existing rank/effect layer remains data-driven for Free Marches, Common Folk, Old Faith, Ashen Covenant, and Sylvan Concord.
- Kept the current compact effects: Common Folk Friendly Marcher Camp discount, Free Marches Friendly Stronghold Crown discount, Old Faith Friendly Chapel Aether bonus, and Ashen Covenant Hostile pressure on Ashen nodes.
- Updated choice reputation previews to show the resulting value and rank after the delta, for example `+8 Common Folk (to +33 Friendly)`.
- Added pure presentation coverage for threshold-crossing choice previews and updated e2e coverage for the visible preview text.
- Updated `DESIGN.md`, `BALANCE.md`, and `CONTENT_GUIDE.md` to document the resulting-rank preview rule.

Verification passed: `npm test`, `npm run build`, `npm run test:e2e -- --reporter=line`, and `npm run playtest:sim`.

### Stronghold Development Tier II Recheck - 2026-05-02

Goal: keep the existing compact Tier II Stronghold layer clear, optional, and fully verified without adding workers, enemy construction, diplomacy, maps, new factions, or new affix work.

What changed:

- Confirmed the current branch already has all five Tier II upgrades: Training Yard II, Watch Post II, Quartermaster Stores II, Chapel Corner II, and Ranger Paths II.
- Kept the existing clean implementation choices: 10% Militia/Ranger training speed, stacked earlier warning and Watchtower reach, a moderate resource package with Iron/Aether, +8% hero HP/Mana, and +1 starting Ranger on the scout path.
- Tightened Tier II UI descriptions so players can read future-battle effects and stacking behavior more easily.
- Left prerequisite, save normalization, launch-effect support, content validation, e2e coverage, and the `tier_two_quartermaster_path` simulator profile intact.
- Updated `DESIGN.md`, `BALANCE.md`, `CONTENT_GUIDE.md`, `ROADMAP.md`, and this handoff with the current Tier II framing and verification.

Verification passed: `npm test`, `npm run build`, `npm run test:e2e -- --reporter=line`, and `npm run playtest:sim`.

### Randomized Item Affixes V1

Goal: add modest item-instance variation while keeping inventory, reward tables, and equipment flow simple.

What changed:

- Added data-driven affix definitions and deterministic rarity/slot-filtered generation.
- Reward-generated item instances can now persist affixes, while old empty-affix saves remain valid.
- Equipped affixes contribute to hero stats through the existing equipment stat path.
- Results and Inventory UI show affix names, base stats, affix stats, total item stats, and equip preview deltas.
- Added unit/content/save/e2e coverage for generation rules, allowed-slot filtering, stat application, persistence, deterministic generation, and browser-visible affix UI.
- Full verification passed: `npm test`, `npm run build`, `npm run test:e2e -- --reporter=line`, `npm run playtest:sim`, and Browser Use preview smoke.

### Campaign Consequences And Reputation Hooks

Goal: make choices and faction reputation visible and mechanically meaningful without adding a full diplomacy layer.

What changed:

- Added rank calculation and active-effect helpers for Free Marches, Common Folk, Old Faith, Ashen Covenant, and Sylvan Concord.
- Added Common Folk Marcher Camp discounts, Free Marches Stronghold Crown discounts, Old Faith Chapel Aether bonuses, and Ashen Covenant Hostile enemy-pressure launches.
- Updated campaign choice cards to show costs, adjusted rewards, reputation changes, modifiers, and completion outcomes.
- Updated campaign reputation UI to show each faction's value/rank and currently active effects.
- Added unit/content/save/e2e coverage for ranks, discounts, hostile pressure, view-model output, persistence, and browser-visible previews.
- Full verification passed: `npm test`, `npm run build`, `npm run test:e2e -- --reporter=line`, `npm run playtest:sim`, and Browser Use preview smoke.

### Stronghold Development Tier II

Goal: add a compact second Stronghold tier that requires matching Tier I upgrades, creates campaign-strategy differences, and stays readable in UI/telemetry.

What changed:

- Added Training Yard II, Watch Post II, Quartermaster Stores II, Chapel Corner II, and Ranger Paths II as data-driven upgrades.
- Added Tier I prerequisite validation for all Tier II Stronghold upgrades.
- Applied Tier II effects at battle launch through existing systems: faster Militia/Ranger training, earlier enemy warning, larger Watchtower range, broader starter resources, hero HP/Mana bonus, and an extra Ranger.
- Expanded pure tests, save normalization tests, content validation, Playwright e2e, simulator profiles, generated telemetry, and design/balance/content docs.
- Full verification passed: `npm test`, `npm run build`, `npm run test:e2e -- --reporter=line`, `npm run playtest:sim`, and Browser Use preview smoke.

### Stronghold Tier I Telemetry Response

Goal: improve Stronghold Development V1 based on simulator telemetry so Watch Post I and Quartermaster Stores I have clear deterministic value, while keeping all Tier I upgrades modest and readable.

Files touched by this follow-up:

- `src/game/data/strongholdUpgrades.ts`
- `src/game/types/CampaignTypes.ts`
- `src/game/campaign/StrongholdPanel.ts`
- `src/game/data/validation/validateStronghold.ts`
- `src/game/ai/EnemyAIController.ts`
- `src/game/ai/EnemyAIController.test.ts`
- `src/game/battle/BattleSceneSpawner.ts`
- `src/game/battle/BattleSceneSystems.ts`
- `src/game/systems/BuildingSystem.ts`
- `src/game/systems/TrainingSystem.ts`
- `src/game/battle/BattleRuntime.test.ts`
- `src/game/core/StrongholdRules.test.ts`
- `src/game/playtest/ScriptedBattlePlaytest.ts`
- `src/game/playtest/ScriptedBattlePlaytest.test.ts`
- `PLAYTEST_TELEMETRY.md`
- `PLAYTEST_TELEMETRY.json`
- `BALANCE.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Watch Post I old issue: +80 player-building vision was readable in fog but did not change deterministic simulator outcomes. It now keeps +80 building vision, makes the first enemy-wave gathering warning 25 seconds earlier, and gives player Watchtowers +10% attack range. Live enemy attack timing is unchanged.
- Quartermaster Stores I old issue: +50 Crowns/+30 Stone mostly increased floated resources. It now grants +60 Crowns, +40 Stone, +20 Iron, and +10 Aether at battle start, and the first player building in each battle completes 10% faster.
- Chapel Corner I now explicitly gives +5% hero maximum HP and +5% maximum Mana; UI copy and aggregation tests match the intended chapel fantasy.
- Ranger Paths I changed from +1 starting Ranger to Rangers training 10% faster, and its Iron cost moved from 45 to 40. A temporary full Ranger profile showed that stacking a free Ranger on top of Training Yard I made Ashen Outpost too easy, so the final version uses the safer training-speed effect.
- Training Yard I stayed mechanically unchanged; copy now uses explicit `+1 Militia`.
- Stronghold UI effect formatting now names enemy warning lead, Watchtower range, first-building construction speed, hero Mana, and unit training speed clearly.
- The simulator now covers six profiles: No Stronghold upgrades, Training Yard path, Defensive Watch Post path, Economy Quartermaster path, Chapel Corner path, and Ranger Paths path.
- Stronghold usefulness analysis now counts earlier first-wave warning, earlier Barracks completion, and earlier first trained unit as deterministic improvements, in addition to result/loss/duration/final-army outcomes.
- Regenerated telemetry is 90 runs across 30 profile-node summaries. Stronghold warnings are none. `too_hard` nodes are none. `too_easy` nodes are none. Ashen Outpost remains beatable.
- Updated `BALANCE.md` with old effect, new effect, reason, expected effect, and telemetry result for every Tier I upgrade.

Final telemetry profile records after this pass:

| Profile | Record | Improved runs | First purchase | Warnings |
| --- | ---: | ---: | --- | --- |
| No Stronghold upgrades | 9-3-3 | 0 | - | none |
| Training Yard path | 10-3-2 | 2 | ashen_outpost | none |
| Defensive Watch Post path | 9-3-3 | 9 | aether_well_ruins | none |
| Economy Quartermaster path | 9-3-3 | 6 | bandit_hillfort | none |
| Chapel Corner path | 9-2-4 | 1 | bandit_hillfort | none |
| Ranger Paths path | 10-3-2 | 2 | ashen_outpost | none |

Verification passed:

```text
npm test
PASS: 32 test files, 159 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 39 Playwright tests in 14.1m

npm run playtest:sim
PASS: 90 simulated runs across 30 profile-node summaries, no structural too-hard nodes, no too-easy nodes, no Stronghold warnings
```

### Automated Stronghold Playtest Profiles

Goal: update the deterministic playtest simulator so Stronghold Development is represented in baseline and upgraded campaign-battle paths without adding gameplay or changing live balance values.

Files touched by this follow-up:

- `src/game/playtest/ScriptedBattlePlaytest.ts`
- `src/game/playtest/ScriptedBattlePlaytest.test.ts`
- `PLAYTEST_TELEMETRY.md`
- `PLAYTEST_TELEMETRY.json`
- `BALANCE.md`
- `tests/e2e/deep-flow.spec.ts`
- `LLM_GAME_HANDOFF.md`

What changed:

- Added four simulator profiles: No Stronghold upgrades, Training Yard path, Defensive Watch Post path, and Economy Quartermaster path.
- Each profile now runs Border Village, Old Stone Road, Aether Well Ruins, Bandit Hillfort, and Ashen Outpost through the existing Safe Beginner, Greedy Economy, and Fast Army scripts, for 60 deterministic runs total.
- Added a conservative simulated campaign bank for profile purchases. It buys each profile's target upgrade only when prior campaign-node rewards can afford it, then records purchase notes and the upgrades active for that node.
- Extended telemetry with Stronghold profile ID/name, target upgrades, purchased upgrades, purchase notes, starting unit counts after upgrade effects, starting resources after upgrade effects, battle result, duration, first-wave survival, resources floated, objective completion, and rewards.
- Updated analyzer output with per-profile records, first purchase node, improved-run counts, too-expensive warnings, useless-upgrade warnings, and overpowered/trivialization warnings.
- Regenerated `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json` as schema version 2.
- At that checkpoint, telemetry said no structural `too_hard` nodes; Training Yard I improved Ashen Outpost; Watch Post I and Quartermaster Stores I were flagged as not improving deterministic outcomes. This was superseded by the later Stronghold Tier I telemetry response above.
- Updated `BALANCE.md` with the early Stronghold simulator read and left live balance values unchanged.
- Hardened one existing Ashen objective e2e assertion to target the visible completed objectives panel after a full-suite stale-HUD-locator failure; the focused test and final full e2e run both pass.

Verification passed after this follow-up:

```text
npm test
PASS: 32 test files, 157 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line
PASS: 39 Playwright tests in 13.7m

npm run playtest:sim
PASS: 60 simulated runs across 20 profile-node summaries, no structural too-hard nodes
```

### Stronghold Development V1

Goal: add a small, data-driven persistent campaign-resource sink that improves future battles without turning the campaign layer into a city builder.

Files touched by this feature:

- `src/game/data/strongholdUpgrades.ts`
- `src/game/core/StrongholdRules.ts`
- `src/game/campaign/StrongholdPanel.ts`
- `src/game/types/CampaignTypes.ts`
- `src/game/save/SaveTypes.ts`
- `src/game/save/SaveDefaults.ts`
- `src/game/save/SaveNormalization.ts`
- `src/game/battle/BattleRuntime.ts`
- `src/game/battle/BattleSceneSpawner.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/scenes/CampaignMapScene.ts`
- `src/game/styles/campaign.css`
- `src/game/data/validation/validateStronghold.ts`
- `src/game/core/StrongholdRules.test.ts`
- `src/game/core/SaveSystem.test.ts`
- `src/game/battle/BattleRuntime.test.ts`
- `tests/e2e/deep-flow.spec.ts`
- `DESIGN.md`
- `BALANCE.md`
- `CONTENT_GUIDE.md`
- `README.md`
- `ROADMAP.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Added a Stronghold panel to the Campaign Map below the campaign bank.
- Added five data-driven upgrades: Training Yard I, Watch Post I, Quartermaster Stores I, Chapel Corner I, and Ranger Paths I.
- Purchases spend campaign Crowns, Stone, Iron, and Aether, record `resourcesSpent`, persist in `campaign.strongholdUpgradeRanks`, and cannot be repeated past `maxRank`.
- Save normalization now safely migrates legacy `strongholdUpgradeIds` arrays into rank 1 purchases and filters unknown upgrade IDs.
- Battle launches now convert purchased Stronghold upgrades into non-consumable launch modifiers.
- Implemented effects: extra starting Militia, extra starting Ranger, extra starting Crowns/Stone, +5% hero max HP, and +80 player-building vision radius.
- Added content validation for Stronghold upgrade IDs, costs, prerequisites, unit references, resource references, and effect values.
- Added pure tests for affordability, duplicate purchase prevention, prerequisites, resource spending, save/load normalization, and battle-launch effect aggregation.
- Added Playwright coverage that seeds campaign resources, buys Training Yard I, launches Border Village, and verifies the extra starting Militia.
- No workers, enemy construction, diplomacy, new maps, randomized affixes, or broad city-builder systems were added.

Verification already passed:

```text
npm test -- src/game/core/StrongholdRules.test.ts src/game/core/SaveSystem.test.ts src/game/battle/BattleRuntime.test.ts src/game/data/contentValidation.test.ts
PASS: 4 test files, 42 tests

npm test
PASS: 32 test files, 157 tests

npm run build
PASS: TypeScript compile and Vite production build with the known Vite large-chunk warning

npm run test:e2e -- --reporter=line -g "stronghold upgrades"
PASS: 1 Playwright test

npm run test:e2e -- --reporter=line
PASS: 39 Playwright tests in 13.7m

npm run playtest:sim
PASS: 60 simulated runs across 20 profile-node summaries
```

### Ashen Outpost Landmark Fog Coverage

Goal: close the remaining automated Ashen Outpost landmark/readability gap without changing gameplay.

Files touched by this follow-up:

- `tests/e2e/layout.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Added a Playwright layout test that launches Ashen Outpost on Normal so fog is active.
- Verifies the enemy Stronghold is hidden from the minimap before scouting.
- Uses test-only unit positioning to scout Burned Shrine, the west/south/north resource sites, all neutral camps, the enemy Stronghold, the enemy Barracks, and the gate Watchtower.
- Verifies each scouted landmark becomes visible in-world and appears on the minimap.
- Verifies each centered landmark is not covered by the top bar, hero panel, side panel, minimap, objectives panel, status line, or hint line.
- No gameplay logic, balance values, fog logic, save format, maps, factions, workers, affixes, or player-facing systems changed in this pass.

### Minimap Marker And Ping Matrix Coverage

Goal: close the remaining automated minimap marker/ping matrix gap without changing gameplay.

Files touched by this follow-up:

- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Added a deep Playwright test that launches First Claim on Story to keep marker families visible for this matrix check.
- The test builds, completes, and selects Barracks, then sets a rally point through right-click input.
- The snapshot now verifies unit, building, capture-site, camp, and rally marker families.
- The snapshot now verifies player, enemy, and neutral marker teams.
- The test verifies concrete Command Hall, Barracks, Crown Shrine, and rally marker IDs.
- The test triggers live minimap pings for rally, enemy wave, Command Hall attack, and Crown Shrine attack.
- The rendered SVG is checked for site, building, unit, camp, rally, ping, and camera elements.
- No gameplay logic, balance values, save format, maps, factions, workers, affixes, or player-facing systems changed in this pass.

### Ability Hotkey Feedback Coverage

Goal: close the remaining automated hero ability hotkey gap and fix confusing duplicate ability feedback.

Files touched by this follow-up:

- `src/game/systems/AbilitySystem.ts`
- `src/game/systems/InputSystem.ts`
- `src/game/battle/BattleSceneSystems.ts`
- `src/game/scenes/BattleScene.ts`
- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Added a deep Playwright test that seeds a level-4 Warlord with Rally Banner, Cleave, and War Cry unlocked.
- The test verifies HUD labels for ability slots `1`, `2`, and `3`, presses each key through the live keyboard path, and confirms mana spend, cooldown start, ally buffing, and enemy damage.
- Fixed successful ability feedback being overwritten by immediate duplicate cooldown retries.
- Ability SFX now plays only after successful casts.
- The expanded menu/hero-creation test has a 60s timeout because the two-class creation flow can exceed Playwright's default 35s timeout on this machine.

### Hero Creation And Direct Hero Click Selection Coverage

Goal: close two remaining player-control coverage gaps without changing runtime behavior.

Files touched by this follow-up:

- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- The main menu/create/reset e2e flow now verifies Arcanist and Shepherd hero class selections persist to save. Warlord remains covered by the first campaign battle path.
- The battle HUD e2e flow now centers the camera on the live hero, click-selects the hero on the canvas, verifies the BattleScene selected entity is the hero, and verifies selected-hero HUD/order state before using `H`.
- No gameplay logic, balance values, save format, maps, factions, workers, affixes, or player-facing systems changed in this pass.

### First Enemy Wave Survival Coverage

Goal: close the remaining automated first-wave pressure gap without changing battle balance or player-facing behavior.

Files touched by this follow-up:

- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Added a deep Playwright test that launches Border Village through the live campaign battle path.
- The test tracks a first Raider wave, puts it in melee range of the Command Hall, and ticks live combat to verify the base takes damage.
- The test verifies incoming-wave and Command Hall under-attack minimap pings.
- The test defeats the tracked wave, verifies `enemyWavesSurvived` increments to 1, confirms the tracked wave clears, and confirms the Command Hall remains alive.
- No gameplay logic, balance values, save format, maps, factions, workers, affixes, or player-facing systems changed in this pass.

### Difficulty Selection, Pacing, And Fog Coverage

Goal: close the remaining automated coverage gap proving difficulty selection changes live battle behavior, not just setup UI state.

Files touched by this follow-up:

- `src/game/data/battlePacing.test.ts`
- `tests/e2e/smoke.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Battle-pacing unit coverage now verifies Story, Easy, Normal, and Hard remain ordered from forgiving to punishing across first attack delay, attack interval, wave size, enemy income multiplier, training interval, and fog defaults.
- Smoke e2e now launches Story and Normal skirmishes through the UI and verifies those choices reach BattleScene.
- The browser test verifies Story has fog off and one starting Raider, while Normal has fog on and a larger starting enemy roster.
- No gameplay logic, balance values, save format, maps, factions, workers, affixes, or player-facing systems changed in this pass.

### Fog And Minimap Visibility Coverage

Goal: close the remaining automated coverage gap where fogged entities could be hidden in-world but still leak through minimap marker data.

Files touched by this follow-up:

- `tests/e2e/smoke.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- The Border Village campaign smoke test now verifies fog is active in both the BattleScene and minimap snapshot.
- The same test verifies minimap fog cells are present.
- The test verifies unseen Stone Quarry, Quarry Imps, and hidden quarry neutral units are absent from minimap marker IDs before scouting.
- No gameplay logic, balance values, save format, maps, factions, workers, affixes, or player-facing systems changed in this pass.

### Reward Keep-In-Inventory Clarity And Objective HUD Refresh

Goal: make the non-equip reward path explicit and remove a timing-sensitive secondary-objective HUD refresh gap found during full e2e.

Files touched by this follow-up:

- `src/game/results/ResultsEquipActions.ts`
- `src/game/results/ResultsRewardPanel.ts`
- `src/game/results/ResultsViewModel.test.ts`
- `src/game/scenes/BattleScene.ts`
- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Victory reward cards now show `Keep in Inventory` beside `Equip Now` for newly earned equippable rewards.
- Results status now confirms the item is kept in inventory and can be equipped later from Hero Inventory.
- Reward-card copy now says the item is already saved to inventory, making the non-equip path obvious.
- Unit coverage verifies the keep-in-inventory Results helper leaves equipment unchanged and returns a useful status message.
- Browser e2e verifies keeping a reward unequipped, opening Hero Inventory, seeing the reward marked `New`, and leaving the weapon slot empty.
- The live first-campaign reward test now verifies rewards are saved without being auto-equipped.
- Battle HUD secondary-objective state now refreshes immediately when an objective completes, which improves player feedback and removed a timing-sensitive Ashen objective e2e failure.
- No rewards, balance values, save format, map, faction, worker, affix, or strategic systems changed in this pass.

### Defeat Inventory Prep Action

Goal: make defeat prep match the advice shown on the Results screen without changing gameplay or reward persistence.

Files touched by this follow-up:

- `src/game/results/ResultsNavigation.ts`
- `src/game/results/ResultsViewModel.test.ts`
- `src/game/scenes/HeroProgressionScene.ts`
- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Defeat Results now include `Open Hero Inventory` alongside Retry and Campaign Map/Main Menu.
- Results inventory navigation now uses the saved starting hero on defeat, matching Retry and preventing unsaved live battle XP or skill points from appearing in prep.
- The progression screen now labels defeat prep as `Hero Inventory` instead of `Victory Progression`.
- Unit coverage verifies defeat inventory data uses the saved hero.
- Browser e2e clicks the defeat inventory action and verifies the inventory screen shows `Hero Inventory`, saved Level 1, and 0 skill points after synthetic unsaved battle XP.
- No gameplay, balance, save format, map, faction, worker, affix, or battle runtime logic changed in this pass.

### Defeat Results Saved Progress Clarity

Goal: make defeat Results honest about unsaved live battle XP after Browser Use found an Ashen Outpost Defeat screen showing a level jump that would not persist.

Files touched by this follow-up:

- `src/game/battle/BattleSceneResults.ts`
- `src/game/results/ResultsViewModel.ts`
- `src/game/results/ResultsObjectiveSummary.ts`
- `src/game/scenes/ResultsScene.ts`
- `src/game/results/ResultsViewModel.test.ts`
- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Defeat Results now display saved hero progress as the after-battle state, because defeat does not persist live battle XP or level-ups.
- The XP summary shows `XP saved: 0` on defeat and labels combat XP as `Battle XP earned ... (not saved)`.
- The top Hero Level badge, defeat tips, and current hero stat strip use the saved hero on defeat.
- The live BattleScene-to-Results handoff now sends saved hero progress for normal defeats, so the Results payload itself is honest.
- Unit coverage now verifies defeat view-model progress does not use unsaved live XP/skill points.
- Browser e2e now verifies defeat Results wording and saved-level display alongside Retry/Campaign actions.
- No gameplay, balance, save format, map, faction, worker, affix, or battle runtime logic changed in this pass.

### Ashen Fortress Readability And Minimap Palette Coverage

Goal: keep Ashen Outpost's objective HUD useful without covering the desktop fortress focus lane, and strengthen colorblind minimap coverage without changing gameplay.

Files touched by this follow-up:

- `src/game/styles/battle-hud.css`
- `tests/e2e/layout.spec.ts`
- `tests/e2e/smoke.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Moved the desktop Objectives panel from the right side under the minimap to the upper-left under resources.
- Added a deterministic Ashen Outpost layout e2e guard that centers the camera on the enemy fortress and verifies the objectives panel does not cover the enemy Stronghold, enemy Barracks, or gate Watchtower focus points.
- Expanded the settings/accessibility e2e test to assert the rendered minimap SVG uses colorblind player/enemy colors (`#56b4e9` and `#d55e00`).
- Browser Use verified the rebuilt preview with Ashen Outpost launch, upper-right minimap camera movement, clear right-side lane, and 0 console errors.
- No gameplay, balance, save format, or battle runtime logic changed in this pass.

### Old Stone Road Live Completion Coverage

Goal: close the remaining browser-coverage gap for Old Stone Road post-victory progression and repeated reward protection without changing gameplay.

Files touched by this follow-up:

- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Added a generic `startCampaignBattle(page, nodeId)` e2e helper and kept `startBorderVillageCampaignBattle` as a wrapper.
- Added a deterministic Playwright test that seeds a Border Village-complete campaign, launches Old Stone Road, forces a live BattleScene victory, and verifies Results plus saved campaign progression.
- The test confirms Old Stone Road first-clear campaign resources, node reward claim recording, and unlocks for Aether Well Ruins, Bandit Hillfort, Refugee Caravan, and Marcher Camp.
- The test returns to the campaign map and verifies completed Old Stone Road disables Start Battle, protecting against repeat live reward claims through the UI.
- Browser Use also visually sanity-checked Ashen Outpost launch and the player-facing Barracks placement feedback loop in the production preview.
- No gameplay, balance, save format, or runtime behavior changed in this pass.

### Alternate Campaign Choice Browser Coverage

Goal: close the remaining browser-coverage gap for early campaign choice branches without changing gameplay.

Files touched by this follow-up:

- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Added a deterministic Playwright test for alternate Refugee Caravan and Chapel of the Marches choices.
- Recruit Volunteers is now browser-tested as locked for level 1 heroes with the visible level requirement.
- Protect Them is now browser-tested for Crown cost, Scout's Bow, Inspired Militia, XP, completion, and reputation rewards.
- Recruit Volunteers is now browser-tested for Crown cost, Iron reward, Marcher Plate, Inspired Militia, XP, completion, and reputation changes.
- Pray for Strength is now browser-tested for Chapel completion, Aether, Blessed Road, XP, reputation, and Ashen Outpost unlock.
- No gameplay, balance, save format, or runtime behavior changed in this pass.

### Ashen Defeat Tip Browser Coverage

Goal: cover the objective-aware Ashen Outpost defeat advice in browser e2e, not only pure unit tests.

Files touched by this follow-up:

- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- The synthetic Results e2e helper can now launch Results for a specific map, campaign node, difficulty, reward table, and completed secondary-objective state.
- A new Playwright test verifies Ashen Outpost defeat Results before Burned Shrine completion and after Burned Shrine completion.
- The test confirms the player-facing tips show Burned Shrine / gate Watchtower advice first, then Enemy Barracks / Stronghold advice after the shrine objective is complete.
- No gameplay, balance, save format, or runtime source behavior changed in this pass.

### Telemetry Verdict And Defeat Tip Refinement

Goal: keep the automated playtest bot useful without overclaiming difficulty failures, and give failed Ashen Outpost runs more actionable Results-screen guidance.

Files touched by this follow-up:

- `src/game/playtest/ScriptedBattlePlaytest.ts`
- `src/game/playtest/ScriptedBattlePlaytest.test.ts`
- `src/game/core/ResultsFlow.ts`
- `src/game/core/ResultsFlow.test.ts`
- `src/game/results/ResultsRewardPanel.ts`
- `.gitignore`
- `BALANCE.md`
- `PLAYTEST_TELEMETRY.md`
- `PLAYTEST_TELEMETRY.json`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- The playtest analyzer now separates structural `too_hard` failures from fair-opening strategy-spread cases.
- The regenerated telemetry report now says: Too hard none; Needs human review Aether Well Ruins, Bandit Hillfort, and Ashen Outpost.
- Suggested tuning now steers future work toward objective route, army timing, and final-assault attrition instead of automatically recommending first-attack/resource tuning.
- Ashen Outpost defeat tips now lead with Burned Shrine advice, then Enemy Barracks advice, then Captain Malrec advice as objectives are completed.
- `.preview-server.pid` was added to `.gitignore` for local Browser Use preview cleanup hygiene.

### Ashen Objective Readability And Live Effect

Goal: make Ashen Outpost's staged Burned Shrine route visible in live play, matching the automated telemetry assumption without adding a new campaign system.

Files touched by this follow-up:

- `src/game/battle/BattleSceneObjectives.ts`
- `src/game/battle/SecondaryObjectiveEffects.ts`
- `src/game/battle/SecondaryObjectiveEffects.test.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/systems/UISystem.ts`
- `src/game/ui/HUD.ts`
- `src/game/styles/battle-hud.css`
- `src/game/styles/responsive.css`
- `src/game/data/maps/ashenOutpost.ts`
- `tests/e2e/deep-flow.spec.ts`
- `BALANCE.md`
- `PLAYTEST_TELEMETRY.md`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Maps with secondary objectives now get a compact in-battle Objectives panel in the HUD.
- Ashen Outpost shows Capture the Burned Shrine, Destroy Enemy Barracks, and Defeat Captain Malrec during live battle.
- Completing `capture_burned_shrine` on Ashen Outpost now weakens the enemy gate Watchtower by 45% max HP without destroying it.
- The Ashen objective description now tells the player that Burned Shrine weakens the gate Watchtower.
- The existing Ashen Outpost e2e test now verifies the objective HUD, the Watchtower weakening effect, and Results objective completion states.

### Enemy AI Config Alignment And Telemetry Balance Follow-Up

Goal: continue the deep systems/balance polish using automated telemetry rather than manual playtesting, while keeping changes numeric or dev-only where possible.

Files touched by this follow-up:

- `src/game/ai/EnemyAIController.ts`
- `src/game/ai/EnemyAIController.test.ts`
- `src/game/playtest/ScriptedBattlePlaytest.ts`
- `src/game/data/maps/firstClaim.ts`
- `src/game/data/maps/ashenOutpost.ts`
- `src/game/data/aiPersonalities.ts`
- `BALANCE.md`
- `PLAYTEST_TELEMETRY.md`
- `PLAYTEST_TELEMETRY.json`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Live enemy AI now uses map-level `scenario.enemyAI` values for initial attack delay, attack interval, wave size, train interval, expansion cadence, expansion squad size, and unit plan after personality modifiers.
- The scripted playtest driver now uses the same map-level enemy AI config, so telemetry matches live battle pacing instead of silently reading only global difficulty defaults.
- First Claim pacing was softened after that alignment: slightly slower training, later first attack, longer interval, and smaller wave target.
- Fortress Keeper and Hexfire Cult assault caps were trimmed because failures happened after first-wave survival.
- Ashen Outpost now starts with one extra Militia and one extra Ranger, one fewer enemy Watchtower, softer enemy economy/training/wave pressure, and smaller defense radius/squad values.
- The Ashen simulator model now treats Burned Shrine capture as a staged fortress-approach advantage. Safe Beginner beats Ashen; Greedy Economy and Fast Army still time out.
- `BALANCE.md` records the before/after values and the remaining risks.

### Battle Feedback, Auto-Attack, Fog, And Order-State Polish

Goal: address player-facing confusion from building placement, unclear research effects, inconsistent troop attack behavior, and fog/readability issues without adding new gameplay systems or changing balance.

Files touched by this pass:

- `src/game/ui/HUD.ts`
- `src/game/ui/UnitOrderSummary.ts`
- `src/game/ui/UnitOrderSummary.test.ts`
- `src/game/styles/battle-feedback.css`
- `src/game/styles/battle-hud.css`
- `src/game/styles/responsive.css`
- `src/game/systems/BuildingSystem.ts`
- `src/game/systems/CombatSystem.ts`
- `src/game/systems/CombatSystem.test.ts`
- `src/game/systems/FogOfWarSystem.ts`
- `src/game/systems/FogOfWarSystem.test.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/battle/BattleSceneSpawner.ts`
- `src/game/battle/BattleSceneSystems.ts`
- `tests/e2e/deep-flow.spec.ts`
- `tests/e2e/smoke.spec.ts`

What changed:

- Building placement now has a clear HUD placement banner, stronger ghost/label feedback, cleaner cancellation state, and placement mode suppresses conflicting first-battle tutorial hints.
- Build, train, and research buttons now show concise descriptions and stat/effect summaries, including upgrade effects such as Infantry Weapons I.
- Player units stop and fight when enemies enter weapon range, idle units guard-chase nearby threats, and normal move orders do not pull troops into distant aggro.
- Selected heroes/troops now show an order strip: Guarding, Moving, Attack-moving, or Attacking; mixed unit selections summarize their orders.
- Fog updates more frequently, uses smaller cells, and applies exact source-distance checks for entity visibility so coarse visible cells no longer reveal entities by accident.
- Neutral camp labels are tracked and hidden by fog unless currently visible; unowned capture-site views require current vision, while player-owned sites remain visible.
- Fog debug now respects settings override and says when fog is disabled for the current battle.

No balance values, campaign rules, maps, factions, workers, or affixes were intentionally changed in this pass.

### GameTypes Domain Split

Goal: split the central cross-domain type file without changing runtime behavior, game logic, balance, or save format.

Files touched by this pass:

- `src/game/core/GameTypes.ts`
- `src/game/types/CampaignTypes.ts`
- `src/game/types/CombatTypes.ts`
- `src/game/types/EconomyTypes.ts`
- `src/game/types/HeroTypes.ts`
- `src/game/types/ItemTypes.ts`
- `src/game/types/MapTypes.ts`
- `src/game/types/UITypes.ts`
- `src/game/types/index.ts`
- `LLM_GAME_HANDOFF.md`

Shape after the split:

- `src/game/core/GameTypes.ts` is now a one-line compatibility barrel:

```ts
export type * from "../types";
```

- Existing `import type { ... } from "../core/GameTypes"` callers still work.
- The new `src/game/types/index.ts` re-exports all domain type modules.
- Cross-module dependencies use type-only imports so no runtime coupling was introduced.
- No direct gameplay/data imports were churned unless needed; this keeps the diff focused and lowers merge risk.

Domain grouping:

- `UITypes.ts`: shared primitives such as `Team`, `EntityKind`, `Position`, `Size`, and `VisibilityState`.
- `EconomyTypes.ts`: resource keys, bags, costs, and resource definitions.
- `CombatTypes.ts`: combat stats, unit/building definitions, factions, status effects, upgrades, pacing, difficulty, and AI personality definitions.
- `HeroTypes.ts`: hero stats, abilities, classes, origins, and skill-tree definitions.
- `ItemTypes.ts`: equipment slots, item definitions/instances, reward tables, battle rewards, duplicate conversions, and level-up summaries.
- `MapTypes.ts`: terrain, capture sites, spawns, battle objectives, scenarios, maps, and battle stats.
- `CampaignTypes.ts`: campaign modifiers, node choices, node rewards, node definitions, and node status.

### Automated Browser Coverage Expansion

Goal: expand deterministic Playwright coverage for implemented systems that were still under-tested without adding gameplay or changing balance.

Files touched by this pass:

- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`
- `tests/e2e/deep-flow.spec.ts`
- `tests/e2e/smoke.spec.ts`

Coverage added:

- Chapel of the Marches: Ask for Guidance scouts/unlocks without completing the node; Repair the Chapel spends resources, grants rewards, removes Angered Raiders, adds Local Support, and completes the node.
- Mystic Lodge and Acolyte: build Mystic Lodge, accelerate construction through existing scene systems, train Acolyte, and verify a live player Acolyte appears.
- Watchtower combat: build/complete Watchtower, reposition an existing enemy into range through Playwright, and verify enemy HP decreases.
- Research UI: verify an insufficient-resource lock reason, then research Infantry Weapons I, Reinforced Armor I, Ranger Training I, and Aether Study I through HUD buttons.
- Ashen Outpost: launch the campaign node, scout Captain Malrec, mark Burned Shrine / Enemy Barracks / Captain Malrec objectives complete through test hooks, force victory, and verify Results shows each objective as Completed.
- Settings/accessibility: persist floating text off, reduced motion, fog override disabled, and colorblind minimap palette; verify those settings reach battle state, fog is inactive, colorblind minimap snapshot is true, and forced damage does not spawn damage-number text while floating text is disabled.

No gameplay behavior, balance values, maps, factions, workers, or affixes were changed in this pass.

### First Real Human-Paced Campaign Balance Pass

Goal: make the first 30 minutes of the mini-campaign coherent, fair, and rewarding without adding systems, maps, factions, workers, enemy construction, affixes, or new strategic layers.

Files touched by this pass:

- `BALANCE.md`
- `src/game/core/FirstExperienceGuidance.ts`
- `src/game/data/aiPersonalities.ts`
- `src/game/data/battlePacing.ts`
- `src/game/data/campaignModifiers.ts`
- `src/game/data/campaignNodes.ts`
- `src/game/data/maps/ashenOutpost.ts`
- `src/game/data/rewards.ts`
- `src/game/ai/EnemyAIController.test.ts`
- `src/game/core/CampaignRules.test.ts`
- `src/game/data/battlePacing.test.ts`
- `tests/e2e/deep-flow.spec.ts`

Core tuning:

- Story is now more clearly the learning/testing lane.
- Easy has more breathing room for Border Village and Old Stone Road.
- Normal remains the first serious baseline but spikes less abruptly.
- Raider Rush still pressures greedy play, but Old Stone Road should be readable.
- Fortress Keeper and Hexfire Cult were trimmed so identity comes more from composition/behavior than raw economy.
- Marcher Camp costs and usefulness were rebalanced.
- Refugee Caravan choices are more distinct and less dominated by Demand Tribute.
- Aether Well Ruins and Bandit Hillfort rewards are stronger for the first Normal branch.
- Chapel guidance now explicitly scouts without completing the node.
- Ashen Outpost player/enemy starting banks and enemy income were softened so fortress/towers/composition create the challenge.
- Reward weights now lean toward understandable early gear on First Claim and slightly more exciting branch/milestone drops later.

`BALANCE.md` now records before/after values, reasons, intended first-30-minute arc, and remaining human testing notes.

### Save System Split

The public import path still works:

```ts
import { SaveSystem } from "../core/SaveSystem";
```

But `src/game/core/SaveSystem.ts` is now a small compatibility re-export:

```ts
export * from "../save/SaveSystem";
```

Focused save modules added before the latest checkpoint:

- `src/game/save/SaveDefaults.ts`
- `src/game/save/SaveImportExport.ts`
- `src/game/save/SaveMigrations.ts`
- `src/game/save/SaveNormalization.ts`
- `src/game/save/SaveSystem.ts`

The facade still owns localStorage IO. Defaults, import/export, migrations, and normalization now live in focused modules. Tests in `src/game/core/SaveSystem.test.ts` cover the split and migration behavior.

### BattleScene System Wiring Split

`BattleScene` is still the live Phaser coordinator, but system construction/wiring has moved into:

- `src/game/battle/BattleSceneSystems.ts`

This helper owns constructor ordering and callback wiring between systems. `BattleScene` still owns Phaser lifecycle, runtime state, entity arrays, fog overlay rendering, rally markers, input callbacks, settings/audio integration, and update order.

### Battle HUD And Responsive Polish

The checkpoint also includes battle HUD and responsive updates:

- `src/game/styles/battle-hud.css`
- `src/game/styles/responsive.css`
- `src/game/ui/HUD.ts`
- `tests/e2e/layout.spec.ts`

The e2e suite verifies command-panel reachability and horizontal overflow across desktop, tablet, and mobile viewports.

## Current Scenes

Scene keys live in `src/game/core/SceneKeys.ts`.

- `BootScene`: loads manifests/assets and enters the menu.
- `MainMenuScene`: New Campaign, Continue Campaign, Skirmish, Hero Inventory, Asset Gallery, Settings, Reset Save, Credits / Info.
- `SettingsScene`: audio, accessibility, UI scale, fog override, minimap palette, and keyboard reference.
- `HeroCreationScene`: hero name/class/origin creation, then campaign or skirmish handoff.
- `CampaignMapScene`: campaign node map, hero summary, campaign bank, reputation, modifiers, selected node details, event choices, town services, and campaign battle launch.
- `SkirmishSetupScene`: map selection, hero summary, difficulty selection, enemy faction placeholder, AI personality selection, and start battle.
- `BattleScene`: main RTS runtime and Phaser entity orchestration.
- `ResultsScene`: victory/defeat summary, rewards, Equip Now, retry/return flow.
- `HeroProgressionScene`: inventory/equipment and skill allocation.
- `AssetGalleryScene`: local/manual asset inspection.

## Current Campaign Flow

Campaign data lives in `src/game/data/campaignNodes.ts`. Rules are exported through the compatibility facade `src/game/core/CampaignRules.ts` and live in focused modules under `src/game/core/campaign/`.

The Border Marches mini-campaign has eight nodes:

| Node | Type | Difficulty | Map | Role |
| --- | --- | --- | --- | --- |
| `border_village` | Battle | Easy | First Claim | Tutorial battle: capture, build, train, defend, win. |
| `old_stone_road` | Battle | Easy | First Claim | First real battle with Raider Rush pressure. |
| `marcher_camp` | Town | Story | First Claim placeholder | First spending sink; reusable services and one-time item purchases. |
| `refugee_caravan` | Event | Story | First Claim placeholder | First consequence choice. |
| `aether_well_ruins` | Battle | Normal | Broken Ford | First Normal branch, Hexfire Cult pressure. |
| `bandit_hillfort` | Battle | Normal | Broken Ford | First Normal branch, Fortress Keeper pressure. |
| `chapel_of_the_marches` | Shrine | Story | First Claim placeholder | Spiritual/support event and route guidance. |
| `ashen_outpost` | Battle | Normal | Ashen Outpost | Milestone fortress assault. |

Unlock shape:

- Start: Border Village.
- Border Village -> Old Stone Road.
- Old Stone Road -> Aether Well Ruins, Bandit Hillfort, Refugee Caravan, Marcher Camp.
- Aether Well Ruins -> Chapel of the Marches.
- Bandit Hillfort + Chapel of the Marches -> Ashen Outpost.
- Chapel guidance can also reveal Refugee Caravan/Ashen Outpost without completing the chapel.

On campaign battle victory:

- `BattleRuntime` grants battle rewards.
- `ResultsScene` applies campaign node completion.
- One-time node rewards are applied if not already claimed.
- Campaign resources go to the persistent campaign bank.
- Unique duplicate item rewards convert into campaign resources.
- Hero and campaign state are saved.

On campaign battle defeat:

- Rewards are not granted.
- Campaign node completion is not granted.
- The player can retry or return to campaign map.

## Intended First-30-Minute Campaign Arc

1. Border Village teaches capture/build/train/defend/win with low pressure.
2. Old Stone Road asks the player to use Barracks and rally behavior against readable Raider Rush pressure.
3. Marcher Camp teaches spending the campaign bank on rest, volunteers, supplies, or early fixed gear.
4. Refugee Caravan teaches that choices trade resources, reputation, modifiers, and item rewards.
5. Aether Well Ruins or Bandit Hillfort introduces the first Normal branch with stronger rewards.
6. Chapel of the Marches supports the player before the milestone and now explains that guidance does not close the node.
7. Ashen Outpost is the current boss-style fortress map. It should feel fortified, not impossible.

Remaining human-feel checks:

- Fresh novice Border Village timing.
- Greedy vs clean Old Stone Road openings.
- Marcher Camp spend preference after two clears.
- Both Normal branches after typical early spending.
- Ashen Outpost with and without Chapel repair.

## Current Maps

Map data is split into per-map modules:

- `src/game/data/maps/firstClaim.ts`
- `src/game/data/maps/brokenFord.ts`
- `src/game/data/maps/ashenOutpost.ts`
- `src/game/data/maps/index.ts`
- `src/game/data/maps.ts` remains a compatibility barrel export.

### First Claim

- ID: `first_claim`
- Size: 2400 x 1600
- Role: balanced tutorial skirmish.
- Player starts west; enemy starts east.
- Capture sites: Crown Shrine, Stone Quarry, Iron Vein, Aether Well.
- Reward table: `first_claim_rewards`.
- Used by Border Village and Old Stone Road.

### Broken Ford

- ID: `broken_ford`
- Size: 2600 x 1700
- Role: contested ruined river crossing.
- Player starts southwest; enemy starts northeast.
- Two main lanes and a risky central ford.
- Capture sites: Ford Toll, West Stone Cut, South Iron Cache, North Aether Spring.
- Reward table: `broken_ford_rewards`.
- Used by Aether Well Ruins and Bandit Hillfort.

### Ashen Outpost

- ID: `ashen_outpost`
- Size: 2600 x 1800
- Role: current mini-campaign milestone fortress assault.
- Player starts lower-left; enemy fortress starts upper-right.
- Capture sites: Burned Shrine, West Supply Pyre, South Iron Pit, North Stone Scar.
- Enemy fortress starts with Enemy Stronghold, Enemy Barracks, and one gate Watchtower.
- Reward table: `ashen_outpost_rewards`.
- Special objectives:
  - Destroy the Ashen Stronghold.
  - Capture the Burned Shrine; in live battle this weakens the gate Watchtower by 45% max HP without destroying it.
  - Destroy Enemy Barracks.
  - Defeat Captain Malrec / Ashen Commander.

Ashen Outpost tuning after the balance pass:

- Player starting bank: 560 Crowns, 390 Stone, 235 Iron, 140 Aether.
- Player starts with 4 Militia and 2 Rangers.
- Enemy starting bank: 240 Crowns, 190 Stone, 135 Iron, 105 Aether.
- Enemy income every 5s: 80 Crowns, 40 Stone, 38 Iron, 30 Aether.
- Enemy AI map pacing: 7s train interval, 78s attack interval, 205s base first attack before Hexfire personality modifiers, 6-unit wave target, 5-unit defense squad, 460 defense radius.
- Burned Shrine is now both telemetry-modeled and live: capturing it softens the fortress approach by damaging the gate Watchtower and showing a status/minimap cue.

## Current Battle Pacing

Pacing data lives in `src/game/data/battlePacing.ts`.

Battle phases:

- Opening, 0:00 to 2:00: no base attacks.
- Expansion, 2:00 to 5:00: small base attacks allowed, no commander.
- Pressure, 5:00 to 8:00: mixed waves, no commander.
- Assault, 8:00 onward: larger waves and commander support allowed.

Difficulty presets after the balance pass:

| Difficulty | Enemy income | First attack | Attack interval | Wave target | Train interval | Commander | Fog |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Story | 0.45x | 300s | 100s | 2 | 9s | 840s | Off |
| Easy | 0.65x | 240s | 82s | 3 | 7s | 750s | On |
| Normal | 0.86x | 195s | 66s | 6 | 5.8s | 570s | On |
| Hard | 1.15x | 150s | 48s | 8 | 3.8s | 480s | On |

First-match tutorial protection:

- No first attack before 150s.
- If the player has not captured a site, first attack waits until 180s.
- Large attacks are capped to 2 units until the player has built production or 240s has passed.
- Enemy commander is excluded from the first attack and cannot join until assault pacing allows it.

Expected Normal waves:

- First wave around 3:15 baseline or around 3:30 on Hexfire Cult.
- First wave is usually 2 Raiders, or 2 Raiders plus 1 Hexer if the player has already built production.
- Mid waves, 5:00 to 8:00: 3 to 5 mixed Raiders, Hexers, and occasional Brutes.
- Late waves, 8:00 onward: Brute and Hexer support, commander after about 9:30 baseline.

## Current Enemy AI Behavior

Enemy AI lives in `src/game/ai/EnemyAIController.ts`.

The AI:

- Gains scaled income on a timer.
- Trains from completed enemy production buildings.
- Expands toward capture sites.
- Defends its base when player units approach.
- Selects phase-limited attack waves.
- Respects difficulty timing, wave size, income, training speed, expansion speed, and commander join timing.
- Sends alerts such as scouts moving, enemy forces gathering, and attack incoming.

AI personality data lives in `src/game/data/aiPersonalities.ts`.

Current personalities:

- Balanced Warlord: mixed expansion and attacks; Border Village default.
- Raider Rush: 0.86x first attack, 0.88x attack interval, 0.82x expansion interval, 0.88x income, mostly Raiders/Hexers, weaker late posture.
- Fortress Keeper: 1.22x first attack, 1.18x attack interval, 1.02x income, defensive reserves, protects captured sites, Brute-heavy later waves.
- Hexfire Cult: 1.08x first attack and attack interval, 1.02x income, more Hexers, burstier caster pressure, thinner frontline.

AI limitations:

- No enemy construction.
- No workers.
- No true scouting memory.
- No retreat logic.
- No counter-unit strategy.
- No pathfinding-aware threat routing.
- No long-term strategy beyond personality/timing/composition modifiers.

## Current Campaign Economy

Campaign resources are saved separately from temporary battle resources.

Bank resources:

- Crowns
- Stone
- Iron
- Aether

Starting battle resources for First Claim/Broken Ford come from `STARTING_PLAYER_RESOURCES`:

- 380 Crowns
- 255 Stone
- 140 Iron
- 75 Aether

Marcher Camp after the balance pass:

- Rest and Recovery: 30 Crowns for Well Rested, next-battle +20% hero max HP.
- Hire Volunteers: 50 Crowns for Inspired Militia, next battle starts with one extra Militia.
- Buy Supplies: 40 Crowns for 30 Stone, 18 Iron, 10 Aether.
- Emberglass Wand: 60 Crowns, one-time common weapon purchase.
- Marcher Plate: 75 Crowns and 15 Iron, one-time uncommon armor purchase.
- Green Chapel Icon: 85 Crowns and 16 Aether, one-time trinket purchase.

Refugee Caravan after the balance pass:

- Protect Them: costs 40 Crowns; grants 40 XP, Scout's Bow, Inspired Militia, +8 Common Folk, +2 Free Marches.
- Recruit Volunteers: requires hero level 2, costs 15 Crowns; grants 25 XP, 30 Iron, Marcher Plate, Inspired Militia, -4 Common Folk, +2 Free Marches.
- Demand Tribute: grants 65 Crowns, Angered Raiders, -8 Common Folk, -2 Free Marches, -3 Ashen Covenant.

Chapel of the Marches:

- Pray for Strength: grants 40 XP, 20 Aether, Blessed Road, +3 Old Faith, +1 Common Folk, completes the node.
- Repair the Chapel: costs 45 Crowns and 55 Stone; grants 35 Aether, Green Chapel Icon, Local Support, removes Angered Raiders, recovers hero placeholder, +2 Free Marches, +6 Old Faith, +2 Common Folk, completes the node.
- Ask for Guidance: grants 15 XP, unlocks/scouts Refugee Caravan and Ashen Outpost, +1 Old Faith, does not complete the node.

## Current Rewards And Items

Item data lives in `src/game/data/items.ts`. Item affixes live in `src/game/data/itemAffixes.ts`. Reward tables live in `src/game/data/rewards.ts`.

Current item model:

- Static catalog item definitions.
- Save inventory stores item instances with `instanceId`, `itemId`, `acquiredAt`, `source`, `affixes`, and optional `locked`/`favorite` flags.
- Equipment references item instance IDs where possible.
- Legacy saves with catalog IDs migrate into instances.
- Unique duplicate rewards convert into campaign resources.
- Non-unique duplicate rewards remain separate instances.
- Reward-generated instances can roll modest affixes by rarity and slot. Current affixes are Sturdy, Sharp, Guarding, Aether-Touched, Commanding, Faithful, Swift, Embered, and Ranger's.
- Equipped item stats combine base item stats plus valid affix stat modifiers.

Reward tables support:

- Guaranteed item IDs.
- Weighted item pools.
- Deterministic item order for tests.
- Deterministic affix generation for tests.
- Map-specific item pool filters.
- First-clear-only and repeat-clear-only entries.
- Resource rewards.
- XP rewards.
- First-clear and repeat-clear bonuses.

Reward pacing after the balance pass:

- First Claim: one weighted item roll, modest resources, 35 base victory XP, 40 first-clear XP, starter resources, weighted toward starter/common gear.
- Broken Ford: one weighted item roll, stronger resources, 55 base victory XP, first-clear Fordbreaker Halberd, 65 first-clear XP, slightly improved rare/epic excitement.
- Ashen Outpost: one weighted item roll, high resources, 85 base victory XP, first-clear Ashbound Censer, 95 first-clear XP, and campaign node Oathbound Aegis.

Affix generation rules:

- Common: 0-1 affix.
- Uncommon: 1 affix.
- Rare: 1-2 affixes.
- Epic: 2 affixes.
- Legendary: 2-3 affixes.

## Current Hero System

Hero data lives in:

- `src/game/data/heroes.ts`
- `src/game/data/heroClasses.ts`
- `src/game/data/origins.ts`
- `src/game/data/abilities.ts`
- `src/game/data/skillTrees.ts`

Current hero classes:

- Warlord
- Arcanist
- Shepherd

Current origins:

- Exiled Noble
- Temple Orphan
- Wildland Raider

Skill trees:

- Combat: damage, HP, Warlord Cleave.
- Magic: mana, armor, Arcanist Arcane Burst/Blink, Shepherd Sanctify Ground.
- Leadership: command, faith, Warlord War Cry, Shepherd Blessing.

Battle hero stats are recalculated from class base stats, origin modifiers, level bonuses, skill ranks, and equipped item stat modifiers, including valid affix modifiers on equipped item instances.

## Current Factions

Faction data lives in `src/game/data/factions.ts`.

Current factions:

- `free_marches`: player baseline faction; balanced economy, reliable Militia/Rangers/Acolytes, defensive Watchtower, leadership and reputation hooks.
- `ashen_covenant`: main enemy faction; aggressive, cheaper early Raiders, harder-hitting but less durable units except Brutes, magic pressure through Hexers, burn/status pressure, and Ashen AI personality preferences.
- `sylvan_concord`: future placeholder faction with early identity hooks and item origins, not yet playable or fully implemented.

Implemented Ashen mechanics:

- `hexfire_burn`: damage over time with floating feedback.
- `ashen_fury`: low-health damage pressure trait.
- `smoke_march`: wave movement-speed modifier for matching Ashen units.

## Current Construction, Training, Research, And Rally

Building data lives in `src/game/data/buildings.ts`.

Player buildings:

- Command Hall
- Barracks
- Mystic Lodge
- Watchtower

Enemy buildings:

- Enemy Stronghold
- Enemy Barracks

Construction times:

- Command Hall: 0s.
- Barracks: 25s.
- Mystic Lodge: 30s.
- Watchtower: 20s.
- Enemy prebuilt structures: 0s.

Construction behavior:

- Player placement uses a ghost preview.
- Resources are paid on final placement.
- Under-construction buildings appear at partial HP and cannot train/research/attack.
- Construction completes automatically.
- There are no workers.

Training:

- Only completed production buildings train.
- Resources are paid when queued.
- Canceling a queued or active unit refunds the full paid cost for now.
- Rally points can be set by right-clicking ground with a rally-capable building selected.

Research:

- Research pays up front and completes after `researchTimeSeconds`.
- Current upgrades: Infantry Weapons I, Ranger Training I, Reinforced Armor I, Aether Study I, Ember Blades placeholder trait.

## Current UI And CSS

`src/game/styles/ui.css` is the import hub. Domain CSS files:

- `asset-gallery.css`
- `base.css`
- `battle-feedback.css`
- `battle-hud.css`
- `campaign.css`
- `forms.css`
- `inventory.css`
- `main-menu.css`
- `minimap.css`
- `responsive.css`
- `results.css`
- `settings.css`

Recent HUD/responsive behavior:

- Battle HUD panels are visually tighter.
- Hero-selected state uses a compact command panel.
- Building command rows were simplified.
- Mobile/tablet rules keep hero/building command panels inside the viewport.
- E2E verifies command reachability and horizontal overflow.

## Current Save Architecture

Current save modules:

- `src/game/core/SaveSystem.ts`: compatibility re-export.
- `src/game/save/SaveDefaults.ts`: versions and fallback/current save creation.
- `src/game/save/SaveImportExport.ts`: JSON parse/stringify boundary.
- `src/game/save/SaveMigrations.ts`: legacy migration.
- `src/game/save/SaveNormalization.ts`: hero/campaign shape checks and normalization.
- `src/game/save/SaveSystem.ts`: public localStorage facade.
- `src/game/save/SaveTypes.ts`: save-facing types.

Current save version is V2. Save normalization protects:

- Settings-only saves.
- Legacy catalog-ID inventory/equipment.
- Item instance migration.
- Campaign resource and resource-spent bags.
- Choice IDs.
- Town service claimed IDs and use counts.
- Active modifier IDs.
- Completed/unlocked/locked/node-reward IDs.
- Negative numeric resource/stat clamping where appropriate.

## Current Helper Architecture

### Types

`src/game/core/GameTypes.ts` is now a compatibility barrel for focused type modules in `src/game/types/`:

- `CampaignTypes.ts`
- `CombatTypes.ts`
- `EconomyTypes.ts`
- `HeroTypes.ts`
- `ItemTypes.ts`
- `MapTypes.ts`
- `UITypes.ts`
- `index.ts`

Prefer importing new type-only dependencies from `src/game/types` or the focused module when touching nearby code, but existing `core/GameTypes` imports are intentionally preserved for compatibility.

### Results

`ResultsScene` is now a coordinator. Helper modules live in `src/game/results/`:

- `ResultsCampaignFlow.ts`
- `ResultsEquipActions.ts`
- `ResultsFormatting.ts`
- `ResultsNavigation.ts`
- `ResultsObjectiveSummary.ts`
- `ResultsRewardPanel.ts`
- `ResultsTypes.ts`
- `ResultsViewModel.ts`

### Campaign Map

`CampaignMapScene` delegates view-model creation and panel rendering to helpers in `src/game/campaign/`:

- `CampaignChoicePanel.ts`
- `CampaignMapViewModel.ts`
- `CampaignNavigation.ts`
- `CampaignNodePanel.ts`
- `CampaignPresentationTypes.ts`
- `CampaignResourcePanel.ts`
- `CampaignTownServicesPanel.ts`

### Hero Progression

`HeroProgressionScene` delegates inventory, equipment, skill tree, comparison, and stat presentation to helpers in `src/game/progression/`:

- `EquipmentPanel.ts`
- `HeroProgressionViewModel.ts`
- `HeroStatsPanel.ts`
- `InventoryPanel.ts`
- `ItemComparison.ts`
- `SkillTreePanel.ts`

### Battle

Battle helpers live in `src/game/battle/`:

- `BattleLaunchRequest.ts`
- `BattleRuntime.ts`
- `BattleSceneAlerts.ts`
- `BattleSceneMapRenderer.ts`
- `BattleSceneObjectives.ts`
- `SecondaryObjectiveEffects.ts`
- `BattleSceneResults.ts`
- `BattleSceneSnapshots.ts`
- `BattleSceneSpawner.ts`
- `BattleSceneSystems.ts`

Several battle helpers changed during earlier checkpoint work, and the current dirty stack includes Chapter 2 reward-economy and Playwright-helper cleanup edits. Preserve future dirty edits unless the user explicitly asks for a reset or revert.

## Current Tests

Latest verified suite status, refreshed after Unit Veterancy V1, Retinue Camp V1, Enemy Hero / Rival Commander V1, the conservative retinue balance pass, the enemy hero balance pass, the readability UX pass, the HeroProgressionRules refactor, the Chapter 2 reward-economy audit, and the Chapter 2 Playwright helper cleanup:

- `npm test`: passed, 37 test files, 259 tests.
- `npm run build`: passed with the known Vite large-chunk warning, which is not a failure.
- `npm run test:e2e -- --reporter=line`: passed, 52 Playwright tests in 21.3m. Use a long timeout.
- `npm run playtest:sim`: passed, 255 simulated runs across 85 campaign battle node/profile summaries, with no structural `too_hard` nodes, no `too_easy` nodes, Ashen Outpost beatable, no Stronghold warnings, and Cinderfen repeat rewards reduced to tiny XP/resources with no repeat item roll.

Current unit/pure test files:

- `src/game/ai/EnemyAIController.test.ts`
- `src/game/battle/BattleLaunchRequest.test.ts`
- `src/game/battle/BattleRuntime.test.ts`
- `src/game/battle/SecondaryObjectiveEffects.test.ts`
- `src/game/campaign/CampaignMapViewModel.test.ts`
- `src/game/core/CampaignRules.test.ts`
- `src/game/core/FirstExperienceGuidance.test.ts`
- `src/game/core/HeroProgressionRules.test.ts`
- `src/game/core/ResultsFlow.test.ts`
- `src/game/core/RetinueRules.test.ts`
- `src/game/core/SaveSystem.test.ts`
- `src/game/core/StrongholdRules.test.ts`
- `src/game/data/aiPersonalities.test.ts`
- `src/game/data/battlePacing.test.ts`
- `src/game/data/campaignModifiers.test.ts`
- `src/game/data/contentValidation.test.ts`
- `src/game/data/itemAffixes.test.ts`
- `src/game/data/unitVeterancy.test.ts`
- `src/game/playtest/ScriptedBattlePlaytest.test.ts`
- `src/game/progression/ItemComparison.test.ts`
- `src/game/results/ResultsViewModel.test.ts`
- `src/game/systems/AudioManager.test.ts`
- `src/game/systems/BuildingPlacementRules.test.ts`
- `src/game/systems/CombatSystem.test.ts`
- `src/game/systems/FogOfWarSystem.test.ts`
- `src/game/systems/PathfindingGrid.test.ts`
- `src/game/systems/PrerequisiteSystem.test.ts`
- `src/game/systems/RallyPointSystem.test.ts`
- `src/game/systems/StatusEffectSystem.test.ts`
- `src/game/systems/UpgradeEffects.test.ts`
- `src/game/systems/UpgradeSystem.test.ts`
- `src/game/ui/MinimapView.test.ts`
- `src/game/ui/UnitOrderSummary.test.ts`
- `src/game/ui/hudPanels/HudFormatting.test.ts`

Current e2e files:

- `tests/e2e/deep-flow.spec.ts`
- `tests/e2e/layout.spec.ts`
- `tests/e2e/smoke.spec.ts`

Browser-level tests currently cover:

- Main menu boot, including visible `Prototype v0.2` label and v0.2 subtitle copy.
- Settings persistence, including floating text, reduced motion, fog override, colorblind minimap persistence, and rendered player/enemy colorblind minimap colors.
- Hero creation.
- Campaign map and locked-node behavior.
- Reputation rank/effect display, active reputation consequences, discounted Marcher Camp/Stronghold previews, and event-choice reputation/modifier previews.
- Stronghold panel purchase flow, resource spending, save persistence, prerequisite lock text, and Quartermaster Stores I/II battle-launch resources.
- Border Village battle launch.
- First enemy wave pressure, Command Hall damage alerts, and wave-survival bookkeeping.
- Campaign choices, including Refugee Caravan Demand/Protect/Recruit, Chapel guidance/repair/pray, and Marcher Camp services/purchases.
- Inventory equip/unequip, including affix display and equipped affix stat contribution.
- Skill spending.
- Results Equip Now, including deterministic affixed reward display and affix persistence after equip.
- Unit Veterancy selected-panel rank display, victory Results Notable Veterans, retinue recruitment, save/load persistence, campaign launch retinue deployment, saved rank bonus preservation, and permanent retinue death removal.
- Defeat tips.
- Defeat Results saved-progress display and unsaved battle XP labeling.
- Ashen Outpost defeat tips for Burned Shrine and Enemy Barracks recovery sequencing.
- Skirmish launches for all maps and AI personalities.
- Skirmish difficulty selection changes live battle fog and starting enemy pressure between Story and Normal.
- Minimap click handling.
- Minimap marker matrix for units, buildings, capture sites, neutral camps, rally markers, camera rectangle, and rally/wave/base/resource pings.
- Fog toggle.
- Hero ability hotkeys `1`, `2`, and `3`, including Warlord Rally Banner, Cleave, and War Cry effects.
- Fog visibility regression for distant neutral camp labels, neutral units, unowned capture sites, minimap fog cells, and hidden minimap marker IDs.
- Building placement cancellation feedback.
- Build Barracks placement ghost near Command Hall.
- Selected-unit order summary for Guarding and Moving states.
- Mystic Lodge construction and Acolyte training.
- Watchtower combat damage against an enemy in range.
- Research UI lock/researched states for Infantry Weapons I, Reinforced Armor I, Ranger Training I, and Aether Study I.
- First-battle loop: capture, Barracks construction, Militia training, rally point, accelerated result.
- Old Stone Road live campaign victory, next-layer unlocks, first-clear campaign resource reward, and completed-node Start Battle disablement.
- Ashen Outpost objective HUD, Burned Shrine gate-Watchtower weakening, Captain Malrec scout/minimap/objective feedback, safe enemy-hero defeat hook, and special objective Results states for Burned Shrine, Enemy Barracks, and Captain Malrec.
- Ashen Outpost desktop objective-panel placement avoiding the enemy stronghold/barracks/gate-Watchtower focus area.
- Ashen Outpost landmark scoutability under Normal fog, including resource sites, neutral camps, fortress buildings, minimap markers, and major HUD-overlap guards.
- Live objective resolution into Results.
- Responsive layout reachability and overflow across desktop, tablet, and mobile.

Full real-time human-style victory from first click to enemy base kill remains manual QA.

### Crown Shrine Selected-Forces Copy Polish

Goal: make the Crown Shrine retake guide accurate for partial combat selections. Browser Use showed that after selecting only Aster, the guide still said to right-click with `hero and troops`.

Files changed in this pass:

- `src/game/battle/BattleSceneAlerts.ts`
- `src/game/battle/BattleSceneAlerts.test.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- The combat-selected Crown Shrine retake prompt now says `Right-click the Crown Shrine with your selected forces.`.
- This wording stays correct for the opening full-squad selection, hero-only selection, or any selected player unit.
- Added focused unit coverage for the hero-only retake state.

Verification in this pass:

- `npm test -- --run src/game/battle/BattleSceneAlerts.test.ts`: passed, 1 file and 4 tests.
- `npm test`: passed, 30 test files and 145 tests.
- `npm run build`: passed with only the known large Phaser bundle warning.
- `npm run playtest:sim`: passed, 15 simulated runs across 5 campaign battle nodes.
- Browser Use: fresh First Claim skirmish starts with `4 units selected` and the selected-forces Crown Shrine prompt.

### Crown Shrine Retake Selection Hint Polish

Goal: prevent the first-battle guide from asking for a combat move while a production building is selected. Browser Use showed that when the enemy recaptured the Crown Shrine and the Barracks was selected, right-clicking the Shrine set the Barracks rally point instead of moving the army.

Files changed in this pass:

- `src/game/battle/BattleSceneAlerts.ts`
- `src/game/battle/BattleSceneAlerts.test.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- `firstBattleTutorialHint` now detects whether a player combat entity is selected before giving the Crown Shrine retake move prompt.
- If no hero or player unit is selected while the Crown Shrine is not player-owned, the guide says `Select your army, then right-click the Crown Shrine.`.
- If the hero or a player unit is selected, the follow-up selected-forces copy pass now uses `Right-click the Crown Shrine with your selected forces.`.
- Added focused unit coverage for the building-selected retake state.

Verification in this pass:

- `npm test -- --run src/game/battle/BattleSceneAlerts.test.ts`: passed, 1 file and 3 tests.
- `npm test`: passed, 30 test files and 144 tests.
- `npm run build`: passed with only the known large Phaser bundle warning.
- `npm run playtest:sim`: passed, 15 simulated runs across 5 campaign battle nodes.
- Browser Use: with Command Hall selected and Crown Shrine not owned, the guide asks for army selection; combat-selected retake wording was tightened in the follow-up selected-forces copy pass.

### First Battle Construction Hint Polish

Goal: keep the first-battle guide synchronized after the player places their first Barracks. Browser Use showed that immediately after placing the Barracks, the construction site became selected but the guide could briefly step backward to `Select your Command Hall.`.

Files changed in this pass:

- `src/game/battle/BattleSceneAlerts.ts`
- `src/game/battle/BattleSceneAlerts.test.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- `firstBattleTutorialHint` now checks for an in-progress player Barracks before requiring Command Hall selection.
- While the unfinished Barracks is selected, the guide stays on `Barracks is under construction. Hold near your base until it completes.`.
- Added focused unit coverage for the in-progress Barracks hint and the earlier no-production Command Hall prompt.

Verification in this pass:

- `npm test -- --run src/game/battle/BattleSceneAlerts.test.ts`: passed, 1 file and 2 tests.
- `npm test`: passed, 30 test files and 143 tests.
- `npm run build`: passed with only the known large Phaser bundle warning.
- `npm run playtest:sim`: passed, 15 simulated runs across 5 campaign battle nodes.
- `git diff --check`: no whitespace errors; existing `.gitignore` CRLF warning only.
- Browser Use: First Claim Easy replayed through capture, Command Hall selection, Barracks placement, construction completion, Militia training, and the first-defense prompt.

### First Claim Neutral Camp Opening Polish

Goal: preserve the First Claim tutorial capture as a clean first beat after full-squad opening selection. Browser Use showed that moving the selected starting squad to the Crown Shrine could pull the nearby Sunken Road Pack into combat before the player had built production.

Files changed in this pass:

- `src/game/data/maps/firstClaim.ts`
- `src/game/data/contentValidation.test.ts`
- `BALANCE.md`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Moved `sunken_road_pack` from `(710, 1110)` to `(650, 1240)`.
- Added a content-validation test that keeps the tutorial Crown Shrine farther from that camp than capture radius plus normal aggro and opening formation spacing.
- No enemy attack timing, unit stats, rewards, campaign economy, or new systems changed.

Verification in this pass:

- `npm test -- --run src/game/data/contentValidation.test.ts`: passed, 1 file and 6 tests.
- `npm test`: passed, 29 test files and 141 tests.
- `npm run build`: passed with only the known large Phaser bundle warning.
- `npm run test:e2e -- --reporter=line -g "battle HUD supports minimap movement"`: passed, 1 focused Playwright test.
- `npm run playtest:sim`: passed, 15 simulated runs across 5 campaign battle nodes.
- Browser Use: First Claim Easy opening captured Crown Shrine cleanly with the neutral camp visible lower on the map and not pulled into combat.

### Opening Squad Selection Polish

Goal: close a small first-click onboarding mismatch found in Browser Use. The first battle hint told the player to right-click the Crown Shrine with hero and troops, but battle startup selected only the hero, so the first command sent Aster alone.

Files changed in this pass:

- `src/game/scenes/BattleScene.ts`
- `tests/e2e/deep-flow.spec.ts`
- `QA_RUN.md`
- `LLM_GAME_HANDOFF.md`

What changed:

- Battle startup now selects every alive starting player unit after the scene systems are created.
- The initial First Claim HUD now visibly starts at `4 units selected` for the default Warlord skirmish: Aster, two Militia, and Ranger.
- The existing battle HUD Playwright test now asserts that the opening selection includes the hero and all starting player units before it continues into click-selection, minimap, fog, and building-placement coverage.
- Browser Use rechecked First Claim Easy from Skirmish, without resetting or replacing the user's campaign save.

Verification in this pass:

- `npm test`: passed, 29 test files and 140 tests.
- `npm run build`: passed with only the known large Phaser bundle warning.
- `npm run test:e2e -- --reporter=line -g "battle HUD supports minimap movement"`: passed, 1 focused Playwright test.
- `npm run playtest:sim`: passed, 15 simulated runs across 5 campaign battle nodes.

## Current Known Bugs

No deterministic runtime bug is currently reproduced by unit tests, build, or Playwright e2e.

Known issues and caveats:

- Player-reported command hover flicker, side-panel scroll snap-back, and captured-site fog issues were fixed in the latest focused HUD/fog pass and then covered by targeted Playwright, full Playwright e2e, playtest sim, and the earlier Browser Use console check. Still do a human spot-check because the bug was tactile.
- Vite reports a large bundle chunk warning.
- Full e2e is slow and can exceed short shell-tool timeouts.
- Full human-paced battle victory/defeat through normal input remains manual.
- Balance remains prototype-level and needs human playtesting after each larger AI/map/economy change.
- Automated Stronghold telemetry currently has no too-expensive, useless-upgrade, overpowered, too-easy, or structural too-hard warnings after the Tier II pass.
- `QA_RUN.md` contains earlier manual QA notes; latest automated verification counts in this handoff are newer.

## Current Known Limitations

- Campaign is still a compact campaign skeleton with a playable Chapter 1 and a Chapter 2 Cinderfen slice, not a full strategic layer.
- Stronghold Development is a compact two-tier persistent-upgrade slice, not a broad city-builder.
- Reputation hooks are compact rank/effect rules, not a diplomacy screen or full faction simulation.
- No broad vendor economy, mercenaries, repairs, diplomacy, invasions, or world simulation beyond Marcher Camp, Stronghold upgrades, reputation hooks, and compact event choices.
- Event choices are compact cards, not a dialogue engine.
- `recoverHero` is a placeholder reward effect.
- Item affixes are V1 stat packages only; crafting, durability, affix rerolling, proc chains, and full item-icon presentation are not implemented.
- Rival trophies are V1 campaign records only; there is no trophy room, trophy equipment slot, crafting use, durability, or long-term trophy upgrade tree.
- Relic slot is typed but not fully used.
- Music is not implemented; `musicVolume` is reserved.
- `screenShakeEnabled` is saved but no active screen shake system currently gates it.
- Fog of war is grid-based and not blocker-aware. Player-owned captured resource sites now reveal their local area, but fog still has no line-of-sight blockers or last-known enemy memory.
- Minimap has no drag-to-pan or last-known enemy memory.
- Enemy AI is paced but simple; it does not construct, retreat, scout intelligently, or adapt composition.
- Player construction is automatic; no workers.
- Pathfinding uses A* waypoints, but it is not formation-aware, flow-field based, or fully dynamic around every temporary obstruction.
- Scene UI is DOM-heavy and still duplicated across several scenes.

## Large Or Risky Files

Current rough line counts:

- `src/game/scenes/BattleScene.ts`: 1124 lines.
- `src/game/playtest/PlaytestRunner.ts`: 1027 lines.
- `src/game/core/SaveSystem.test.ts`: 742 lines.
- `src/game/core/RivalRules.ts`: 462 lines.
- `src/game/battle/BattleSceneSystems.ts`: 411 lines.
- `src/game/systems/PathfindingGrid.ts`: 354 lines.
- `src/game/playtest/PlaytestAnalyzer.ts`: 339 lines.
- `CONTENT_GUIDE.md`: 333 lines.
- `src/game/data/borderMarchesNodes.ts`: 326 lines.
- `src/game/scenes/CampaignMapScene.ts`: 326 lines.
- `src/game/ai/EnemyAIController.ts`: 318 lines.
- `src/game/data/contentValidation.test.ts`: 304 lines.
- `src/game/data/strongholdUpgrades.ts`: 303 lines.
- `src/game/types/CombatTypes.ts`: 304 lines.
- `src/game/data/aiPersonalities.ts`: 279 lines.
- `src/game/scenes/HeroProgressionScene.ts`: 268 lines.
- `src/game/playtest/PlaytestReportWriter.ts`: 409 lines.
- `src/game/data/campaignRewards.ts`: 249 lines.
- `src/game/core/campaign/CampaignChoiceRules.ts`: 244 lines.
- `src/game/core/progression/ItemRewardRules.ts`: 212 lines.
- `src/game/data/cinderfenRoadNodes.ts`: 194 lines.
- `src/game/data/itemAffixes.ts`: 182 lines.
- `src/game/playtest/PlaytestTypes.ts`: 173 lines.
- `src/game/types/CampaignTypes.ts`: 172 lines.
- `src/game/ui/HUD.ts`: 167 lines.
- `src/game/playtest/PlaytestTelemetry.ts`: 158 lines.
- `src/game/types/MapTypes.ts`: 134 lines.
- `src/game/core/StrongholdRules.ts`: 120 lines.
- `src/game/playtest/PlaytestProfiles.ts`: 120 lines.
- `src/game/data/validation/validateRewards.ts`: 117 lines.
- `src/game/core/progression/HeroStatRules.ts`: 107 lines.
- `src/game/playtest/PlaytestStrategies.ts`: 106 lines.
- `src/game/campaign/StrongholdPanel.ts`: 105 lines.
- `src/game/core/campaign/CampaignRewardRules.ts`: 97 lines.
- `src/game/core/progression/SkillRules.ts`: 98 lines.
- `src/game/types/ItemTypes.ts`: 90 lines.
- `src/game/data/rivalRewards.ts`: 89 lines.
- `src/game/data/validation/validateContent.ts`: 82 lines.
- `src/game/core/progression/EquipmentStatRules.ts`: 75 lines.
- `src/game/core/campaign/CampaignNodeRules.ts`: 73 lines.
- `src/game/campaign/RivalIntelPanel.ts`: 71 lines.
- `src/game/core/progression/AffixRules.ts`: 37 lines.
- `src/game/data/campaignChapters.ts`: 35 lines.
- `src/game/core/progression/LevelingRules.ts`: 29 lines.
- `src/game/core/progression/DuplicateRewardRules.ts`: 18 lines.
- `src/game/playtest/PlaytestScenarios.ts`: 15 lines.
- `src/game/core/campaign/CampaignReputationRules.ts`: 14 lines.
- `src/game/data/rewards.ts`: 8 lines.
- `src/game/playtest/ScriptedBattlePlaytest.ts`: 8 lines.
- `src/game/core/campaign/index.ts`: 7 lines.
- `src/game/core/campaign/CampaignModifierRules.ts`: 6 lines.
- `src/game/data/campaignNodes.ts`: 6 lines.
- `src/game/core/progression/index.ts`: 7 lines.
- `src/game/core/HeroProgressionRules.ts`: 1 line.
- `src/game/core/CampaignRules.ts`: 1 line.
- `src/game/core/campaign/CampaignRivalRules.ts`: 1 line.
- `src/game/core/GameTypes.ts`: 1 line.
- `src/game/data/contentValidation.ts`: 1 line.
- `src/game/playtest/index.ts`: 1 line.

Risk notes:

- `BattleScene` is smaller than before but still the highest live-scene integration risk.
- `ScriptedBattlePlaytest.ts` is no longer a large risk file; it is an 8-line compatibility facade over focused modules in `src/game/playtest/`.
- The playtest simulator risk now lives mainly in `PlaytestRunner.ts` and `PlaytestAnalyzer.ts`; keep future simulator additions scoped to the relevant profile/scenario/strategy/telemetry/report module.
- `GameTypes.ts` is no longer a large risk file; it is a 1-line compatibility barrel over focused modules.
- `HeroProgressionRules.ts` is no longer a large risk file; it is a 1-line compatibility barrel over focused modules in `src/game/core/progression/`.
- `ItemRewardRules.ts`, `HeroStatRules.ts`, `SkillRules.ts`, `EquipmentStatRules.ts`, `AffixRules.ts`, `DuplicateRewardRules.ts`, and `LevelingRules.ts` now split the hero progression domain. Keep formulas stable unless the user explicitly asks for tuning.
- `CampaignRules.ts` is no longer a large risk file; it is a 1-line compatibility facade over focused modules in `src/game/core/campaign/`.
- The campaign rules risk now lives mainly in `CampaignChoiceRules.ts` and `CampaignRewardRules.ts`; keep future campaign changes scoped to the relevant node/choice/reward/reputation/modifier/town/rival module.
- `campaignNodes.ts` and `rewards.ts` are now small compatibility barrels. Add campaign nodes to `borderMarchesNodes.ts` or `cinderfenRoadNodes.ts`, add campaign battle reward tables to `campaignRewards.ts`, and keep `campaignChapters.ts` node ordering aligned with the focused node arrays.
- `HUD.ts` owns click delegation plus the latest DOM-rebuild deferral and scroll-state preservation for stable command/objective panel interaction. Selectors and behavior should still be treated as fragile.
- `contentValidation.ts` is now a compatibility export over focused validators; the validation domain remains important even though the old catch-all file is gone.
- `StrongholdRules`, `strongholdUpgrades`, `StrongholdPanel`, and the Stronghold hooks in AI/building/training systems are covered, but should stay small until human campaign-economy feel is checked.
- `reputation.ts`, `CampaignChoicePanel`, `CampaignResourcePanel`, and the reputation hooks inside `src/game/core/campaign/`, `StrongholdRules`, and `CampaignMapScene` are covered, but should remain a compact consequence layer rather than growing into diplomacy.
- `itemAffixes.ts`, `progression/AffixRules.ts`, `progression/ItemRewardRules.ts`, `ItemComparison`, `InventoryPanel`, and `ResultsRewardPanel` now form the compact affix path; keep future affix work data-driven and modest unless the user explicitly asks for deeper loot systems.
- `RivalRules.ts`, `rivalRewards.ts`, `RivalIntelPanel.ts`, `ResultsObjectiveSummary.ts`, and the rival telemetry fields now form the compact rival reward/trophy path; keep future work data-driven and avoid trophy-room, crafting, durability, or broad loot-system growth unless explicitly requested.

## Most Fragile Systems

1. `BattleScene` integration: live scene lifecycle, system update order, input mode overlap, fog/minimap/rally wiring.
2. Results and campaign reward saving: battle rewards, node rewards, rival first-defeat rewards, trophy records, affix generation/display, Equip Now, first-clear, duplicate conversion, campaign bank, and the `progression/ItemRewardRules.ts` handoff into Results.
3. Save migration/normalization: old localStorage saves, item-instance migration, settings-only saves, campaign state, rivals, and rival trophies.
4. Campaign choices and town services: pure rules are covered, but UI crowding can regress.
5. Campaign content data wiring: focused node/reward modules, `campaignChapters.ts` node ordering, public barrels, and validation must stay aligned.
6. Fog/minimap visibility: filters rendering and minimap markers.
7. Input modes: selection, move/attack, rally, placement, minimap, abilities, fog debug, Esc.
8. Enemy AI pacing: data-driven but dependent on milestone gates and phase math.
9. DOM CSS: split by domain but global selectors can still collide.
10. Asset fallback chain: optional manual/final/placeholder assets need validation after art changes.

## Manual QA Checklist

Run this before a checkpoint commit after gameplay/UI changes:

1. Start dev server and open `http://127.0.0.1:5173/`.
2. Main menu appears.
3. Settings opens and persists audio, UI scale, reduced motion, floating text, fog override, and minimap palette.
4. Reset Save works in an isolated test context before using on a real save.
5. New Campaign opens hero creation when no playable save exists.
6. Create Warlord, Arcanist, and Shepherd at least once.
7. Campaign map opens after creation.
8. Campaign bank, reputation, active modifiers, and Retinue Camp display. On a disposable seeded save, verify retinue capacity, rank/type text, and Dismiss behavior.
9. Stronghold panel displays resources, purchased/locked/available states, costs, effects, and purchase buttons.
10. Buy Quartermaster Stores I and II from a resource-seeded campaign and verify the next launched battle starts with the Tier II resource package.
11. Border Village is available and locked nodes cannot start.
12. Border Village launches First Claim.
13. Select hero with click and `H`; select a ranked non-hero unit during a seeded run and verify rank/XP/kills display.
14. Move units with right-click.
15. Capture Crown Shrine.
16. Select Command Hall.
17. Place Barracks and verify valid/invalid placement reasons.
18. Barracks appears under construction and cannot train until complete.
19. Hover Build/Train/Research command buttons while the HUD is updating; buttons should not flicker or become hard to click.
20. Scroll the battle side panel when it contains enough actions/queue rows; it should not jump back to the top during routine HUD updates.
21. Completed Barracks trains Militia and Ranger.
22. Queue progress displays and cancel/refund works.
23. Set Barracks rally point and verify marker plus trained-unit movement.
24. Build Mystic Lodge and train Acolyte.
25. Build Watchtower and verify it attacks.
26. Research all current upgrades through UI.
27. Verify locked train/upgrade buttons show reasons.
28. Use hero ability hotkeys.
29. Verify audio cues with human ears.
30. Verify floating text and reduced motion visually.
31. Verify fog hides unexplored/undetected entities.
32. Capture a resource site, move units away, and verify the captured site stays locally revealed instead of being covered by fog.
33. Press `F` on fog-enabled difficulty and verify fog debug.
34. Verify settings fog override changes battle fog behavior.
35. Verify minimap units/buildings/sites/camera/rally/pings and colorblind palette.
36. Survive or lose the first wave through normal play.
37. Defeat screen shows contextual tips and retry/campaign return.
38. Victory screen shows map, difficulty, time, XP, level progress, battle rewards, affixes, node rewards, campaign bank, Notable Veterans, Retinue add/skip controls when eligible, and Rival Defeated reward/trophy copy when a commander first falls.
39. Equip Now changes stats, including affix stats, and persists after leaving Results.
40. Campaign victory completes Border Village and unlocks Old Stone Road; if a retinue unit was added, the next campaign battle deploys it near the hero/Command Hall with saved rank.
41. Complete Old Stone Road and verify Aether Well Ruins, Bandit Hillfort, Marcher Camp, and Refugee Caravan unlock. On a disposable seeded rival save, defeat Veyra or Gorak and verify the Rival Trophies section persists after returning to Campaign Map.
42. Marcher Camp repeatable services, once-only purchases, costs, locked reasons, and save persistence work.
43. Refugee Caravan choices and reputation/resource effects work.
44. Chapel choices work, especially non-completing guidance.
45. Campaign node rewards cannot be claimed repeatedly.
46. Skirmish Setup opens separately.
47. First Claim, Broken Ford, and Ashen Outpost launch from skirmish.
48. Ashen Outpost shows fortress layout, Burned Shrine, side resources, neutral camps, and defensive towers.
49. Ashen Outpost Results show special objective completion states.
50. Difficulty selection changes pacing/fog behavior.
51. AI personality selection changes displayed style and launches without errors.
52. Hero Inventory opens from main menu.
53. Equipping/unequipping items changes hero stats, including affixed item instances.
54. Skill point spending persists.
55. Asset Gallery opens.
56. Browser console has no new hard errors.
57. Production build preview boots if doing release-style QA.

## Recommended Next Priorities

1. Human-verify the current Chapter 2 Cinderfen slice end to end: Cinderfen Overlook, Cinderfen Waystation, Cinderfen Crossing, Cinder Shrine surge/attunement, Malrec trophy consequence, Cinderfen Watch, Cinderfen Aftermath, Results, and return-to-campaign persistence.
2. Add no further Chapter 2 content until the current route stays green in human readability and balance review. Do not start a broad Chapter 2 campaign arc yet.
3. Keep Chapter 2 reward pacing modest: Fast Army and retinue plus Training Yard II remain the main reward-farm watchpoints, even though Cinderfen repeat clears now pay only tiny XP/resources and no battle item roll.
4. Do a human-paced Chapter 1 regression pass after any Chapter 2 content change: Border Village, Old Stone Road, Aether Well Ruins, Bandit Hillfort, Marcher Camp, Refugee Caravan, Chapel, and Ashen Outpost should remain unchanged.
5. Play Ashen Outpost with and without Chapel repair to validate fortress pressure, Captain Malrec readability, final approach readability, tower pressure, upper-left objective-panel placement, and whether mixed or Stronghold-backed retinue feels helpful or mandatory.
6. Human-review affixed rewards in Results and Inventory to make sure base/affix/total stat copy is readable without crowding the equipment flow.
7. Human-review reputation hooks in actual campaign flow: Common Folk service discounts, Free Marches Stronghold discounts, Old Faith Chapel Aether bonus, Ashen Covenant Hostile pressure, and Cinderfen event/service effects.
8. Human-review the full two-tier Stronghold set in actual fog/build-order play, especially whether Training Yard II's retinue capacity, Watch Post II's earlier warning/tower reach, and Quartermaster II's broader starter package feel helpful without becoming mandatory.
9. Reputation hooks, item affixes V1, Stronghold Tier II, battle-local Unit Veterancy V1, Retinue Camp V1, Enemy Hero / Rival Commander V1, Rival / Nemesis Persistence V1, Rival Rewards and Trophies V1, Cinderfen Overlook, Cinderfen Waystation, Cinder Shrine, Cinderfen Watch, and Cinderfen Aftermath are compact slices; future campaign-depth work should stay compact. Do not move into workers, enemy construction, crafting, durability, affix rerolling, diplomacy, broad loot complexity, full trophy rooms, or broad city-builder systems yet.
10. Treat the next technical risks as `PlaytestRunner.ts`, `PlaytestAnalyzer.ts`, `BattleScene`, `HUD`, `battle-hud.css`, content validation, focused campaign data modules, `CampaignChoiceRules.ts`, `CampaignRewardRules.ts`, `RetinueRules`, `src/game/core/progression/ItemRewardRules.ts`, `itemAffixes`, and reputation helper/rule hooks. `ScriptedBattlePlaytest.ts`, `HeroProgressionRules.ts`, `CampaignRules.ts`, `campaignNodes.ts`, and `rewards.ts` are now compatibility barrels.
11. Keep Vite chunk-size warning as a known build warning unless the user asks for bundle optimization.

## Guidance For Future LLMs

- Preserve current dirty work unless explicitly told to reset/revert. The current Stronghold Tier I telemetry-response, Stronghold Tier II, campaign reputation/consequence, item affix V1, Unit Veterancy V1, Retinue Camp V1, retinue balance, Rival / Nemesis Persistence V1, Rival Rewards and Trophies V1, HeroProgressionRules refactor, CampaignRules refactor, HUD/fog polish, permanent HUD/fog regression coverage, Chapter 2 Cinderfen slice, Cinderfen Watchpost map, Chapter 2 docs/report updates, and campaign data-organization cleanup are intentional.
- Treat the current docs as the v0.2.1 prototype baseline candidate. Use `CHANGELOG.md` and `RELEASE_CHECKLIST.md` for release-facing summaries and verification commands.
- The current named phase is the v0.3 Chapter 2 Cinderfen slice. Cinderfen Overlook, Cinderfen Waystation, Cinderfen Crossing, Cinder Shrine, Malrec trophy consequence, Cinderfen Watch, and Cinderfen Aftermath are implemented; next work should be human verification before any additional Chapter 2 content. Do not reopen completed Stronghold Tier II, reputation, item-affix V1, battle-local Unit Veterancy V1, Retinue Camp V1, Enemy Hero / Rival Commander V1, Rival / Nemesis Persistence V1, Rival Rewards and Trophies V1, retinue balance, HeroProgressionRules refactor, CampaignRules refactor, or HUD/fog polish work unless the user asks for a targeted pass.
- Keep campaign and skirmish separate entry flows that share `BattleLaunchRequest`.
- Prefer data tuning in `src/game/data` and pure rules in `src/game/core` or `src/game/systems`.
- For campaign content, keep `src/game/data/campaignNodes.ts` and `src/game/data/rewards.ts` as compatibility barrels. Add/edit Chapter 1 nodes in `borderMarchesNodes.ts`, current Chapter 2 nodes in `cinderfenRoadNodes.ts`, chapter metadata in `campaignChapters.ts`, and campaign battle reward tables in `campaignRewards.ts`.
- For Cinderfen rewards specifically, preserve the first-clear-only flags on Chapter 2 battle item pools and base battle XP/resources unless a future economy pass adds a real repeat-clear sink or consequence.
- For Chapter 2 Playwright coverage, reuse `tests/e2e/chapter2-helpers.ts` for post-Ashen/post-Crossing seeds, Waystation service clicks, Cinderfen launches, safe Cinder Shrine capture hook calls, and test-only victory fast-forwards. Keep assertions for copy, rewards, save state, and duplicate prevention in the specs.
- `src/game/core/HeroProgressionRules.ts` is intentionally a compatibility barrel. Preserve it for old imports and put future hero progression work in the focused modules under `src/game/core/progression/`.
- Add or update tests for persistent save fields and data contracts.
- Use Playwright for browser verification when UI/gameplay changes.
- Use Browser Use when the user asks for in-app browser inspection or visible local-browser interaction. The latest deterministic browser gameplay verification is the Playwright suite; this handoff refresh did not need to manipulate the already-open browser tab.
- Keep changes conservative until the current first-hour campaign balance has human playtesting.
- Never run destructive git commands without explicit user approval.
