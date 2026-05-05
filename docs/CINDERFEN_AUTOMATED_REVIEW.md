# Cinderfen Automated Readability And Balance Review

Generated: 2026-05-03 19:34 -04:00

Current status note, 2026-05-04: this review is now part of the v0.3 Cinderfen route baseline candidate. For the newest route-baseline summary, including Aftermath, reward-audit results, current verification counts, and forbidden next steps, use `docs/V03_CINDERFEN_ROUTE_BASELINE.md`.

Sources read: `LLM_GAME_HANDOFF.md`, `docs/CHAPTER_2_CINDERFEN_SLICE_REPORT.md`, `docs/V03_CINDERFEN_ROUTE_BASELINE.md`, `PLAYTEST_TELEMETRY.md`, `PLAYTEST_TELEMETRY.json`, `BALANCE.md`, and `QA_RUN.md`.

Scope: automated review only. This pass uses campaign view-model tests, pure rules, Playwright flows, deterministic telemetry, and docs. It does not include manual playtesting and makes no gameplay or balance changes.

## Executive Result

| Area | Verdict | Evidence |
| --- | --- | --- |
| Chapter 2 progression clarity | Pass | View-model, rules, and e2e cover Overlook, Waystation, Crossing, Watch, and Aftermath unlock order. |
| Cinderfen Overlook clarity | Pass | Costs, rewards, reputation, modifiers, Malrec trophy condition, completion, and duplicate prevention are covered. |
| Cinderfen Waystation clarity | Pass with added coverage | This pass adds view-model assertions for service effect text and repeatable/one-time labels. |
| Cinderfen Crossing readability | Pass with watchpoint | E2E verifies map name, objectives, minimap, resources, Cinder Shrine +25 attuned surge, and duplicate prevention. Human review is still useful for shrine visual salience. |
| Cinderfen Watch readability | Pass with watchpoint | E2E verifies map name, objectives, minimap, resources, Marsh Guides modifier, victory, rewards, and persistence. |
| Cinderfen Aftermath clarity | Pass with watchpoint | E2E and route docs cover the compact post-Watch consequence choices and duplicate prevention; mobile density still wants human review. |
| Telemetry balance | Reasonable | No `too_easy` or `too_hard` automated flags. Safe Beginner wins both Chapter 2 battles; Greedy Economy timeouts remain a routing/pacing watchpoint. |
| Chapter 1 regression | Stable | Telemetry keeps Chapter 1 in the same verdict bands, with no Chapter 2 balance changes in this pass. |

## 1. Chapter 2 Progression Clarity

Current implemented chain:

| Step | Node | State Read |
| --- | --- | --- |
| 1 | `cinderfen_overlook` | Playable event gate after `ashen_outpost`. |
| 2 | `cinderfen_waystation` | Town/service node unlocks after Overlook and stays open. |
| 3 | `cinderfen_crossing` | Battle node unlocks after Overlook and launches `cinderfen_causeway`. |
| 4 | `cinderfen_watch` | Battle node unlocks after Crossing victory and launches `cinderfen_watchpost`. |
| 5 | `cinderfen_aftermath` | Event node unlocks after Watch victory and completes the compact Cinderfen route. |

Automated evidence:

- `CampaignMapViewModel.test.ts` verifies Chapter 2 appears after Ashen Outpost, Overlook is playable, Waystation and Crossing unlock after Overlook, Watch unlocks after Crossing, and Aftermath unlocks after Watch.
- `CampaignRules.test.ts` verifies node unlocks, choice gating, insufficient-resource cases, and completion/unlock effects.
- `smoke.spec.ts` seeds Chapter 2 state, opens the Chapter 2 map, resolves the event/service steps, launches both Cinderfen battles, resolves Aftermath, and returns to campaign.
- Chapter 1 nodes remain present in the same campaign presentation flows; no Chapter 1 map or reward data changed in this review.

Locked/unavailable states are clear enough for the current slice: locked nodes remain disabled until prerequisites resolve, upcoming/scaffold content is not launchable, and the Waystation clearly presents as services rather than a battle.

## 2. Cinderfen Overlook Clarity

Baseline choices are readable:

| Choice | Cost | Reward/Effect Read |
| --- | --- | --- |
| Scout the Causeway | 30 Crowns | 20 XP, 8 Stone, Free Marches/Common Folk reputation, Local Support. |
| Aid Marsh Refugees | 55 Crowns | 25 XP, 10 Iron, Common Folk/Free Marches reputation, Inspired Militia. |
| Study the Cinders | 24 Aether | 20 XP, Emberglass Wand, Old Faith reputation, Ashen reputation loss, Blessed Road. |

Malrec trophy consequence:

- `Raise Malrec's Standard` appears only when the hero owns `trophy_malrec_outpost_standard`.
- The choice has no cost, grants 10 XP, +3 Free Marches reputation, and Well Rested.
- Rules and e2e cover absence, presence, one-time reward application, and duplicate prevention.

Completion/unlock behavior:

- Overlook choices complete the event and unlock Cinderfen progression.
- Rewards are saved via existing campaign choice state, so replaying the same choice does not duplicate payout.

## 3. Cinderfen Waystation Clarity

Current services:

| Service | Cost | Effect Read | Repeatability |
| --- | --- | --- | --- |
| Marsh Guides | 35 Crowns | Next Cinderfen battle gains earlier enemy warnings and wider base vision. | Repeatable service. |
| Ash Filters | 35 Crowns, 15 Aether | Next Cinderfen battle starts the hero with a small HP and Mana buffer. | Repeatable service. |
| Refugee Scouts | 25 Crowns | Confirms the Cinder Shrine and central guardians, grants 10 XP and +2 Common Folk reputation. | Purchase once. |
| Shrine Attunement | 12 Aether | Next Cinderfen battle's Cinder Shrine Surge grants +5 extra Aether on first capture. | Repeatable service. |

Automated evidence:

- Pure rules cover unlock, cost payment, insufficient resources, service effect grants, one-time/repeatable behavior, save/load, and Cinderfen-only modifier consumption.
- E2E covers using Shrine Attunement, spending resources, seeing the modifier, launching Crossing, and receiving a +25 Cinder Shrine surge.
- E2E covers using Marsh Guides before Watch and seeing the battle modifier applied.
- This review adds presentation coverage that asserts Waystation service effect copy and repeatable/one-time labels are visible in the rendered campaign node details.

Risk:

- The service list is dense. It is readable in text assertions, but mobile/touch density still wants human review later.

## 4. Cinderfen Crossing Readability

Battle/map read:

- Node: `cinderfen_crossing`
- Map: `cinderfen_causeway`
- Display name: Cinderfen Causeway
- Primary objective: destroy the Ashen staging Stronghold.
- Secondary objectives include claiming the Cinder Shrine, clearing Cinder Guardians, and destroying the Enemy Barracks.

Cinder Shrine:

- Normal first player capture grants a battle-local +20 Aether surge.
- Shrine Attunement raises that one-battle first-capture surge to +25 Aether.
- Pure ResourceSystem tests cover +20, +25, enemy/player separation, and duplicate prevention.
- E2E verifies the attuned +25 status/resource result and no duplicate surge on revisit.

Readability support:

- Objectives include Cinder Shrine and guardian copy.
- The battle HUD/e2e surfaces resources, objectives, minimap, fog state, and Cinderfen-specific defeat tips.
- Minimap and fog are covered by DOM/e2e presence checks rather than brittle screenshots.

Risk:

- The automated suite confirms the shrine text and effect, not whether the capture site visually stands out enough under human attention. Keep shrine visual salience on the next manual QA list.

## 5. Cinderfen Watch Readability

Battle/map read:

- Node: `cinderfen_watch`
- Map: `cinderfen_watchpost`
- Display name: Cinderfen Watchpost
- Theme: raised road and Ashen watchpost controlling cinder-marsh movement.
- Primary objective: destroy the Ashen Watchpost Stronghold.
- Secondary objectives include capturing the Watch Road, clearing the Marsh Raider Camp, and destroying the Watchpost Tower.

Automated evidence:

- E2E verifies node unlock after Crossing, launch into the Watchpost map, correct objective text, resources, minimap, battle modifier display, forced victory, results screen, rewards, and campaign completion.
- The map has no Cinder Shrine, which keeps the second battle from overusing the first Cinderfen tactical feature.

Risk:

- Fog and raised-road theme are text/objective/readability covered, but not visually reviewed in this pass.

## 6. Cinderfen Aftermath Clarity

Event read:

- Node: `cinderfen_aftermath`
- Type: compact non-battle consequence event after `cinderfen_watch`.
- Choices remain modest once-only follow-ups: secure the road, aid Fenfolk, study Ashen marks, or display Malrec's standard when the trophy requirement is met.

Automated evidence:

- E2E covers unlocking Aftermath after Watch, selecting a consequence, reward/cost application, save persistence, and duplicate prevention.
- The v0.3 baseline document and slice report keep Aftermath framed as a small route close, not a new broad Chapter 2 system.

Risk:

- The choice set is readable in text assertions, but real mobile density and choice-comparison comfort still need human review.

## 7. Telemetry Summary

Current deterministic telemetry: 255 total runs, 75 Chapter 2 battle runs, 180 Chapter 1/earlier-node runs.

| Node | Runs | Wins | Defeats | Timeouts | Verdict |
| --- | ---: | ---: | ---: | ---: | --- |
| Cinderfen Crossing | 39 | 26 | 0 | 13 | Reasonable |
| Cinderfen Watch | 36 | 25 | 0 | 11 | Reasonable |

Script read:

| Node | Script | Result | Avg First Enemy Contact | First Wave Survived |
| --- | --- | --- | ---: | --- |
| Cinderfen Crossing | Safe Beginner | 13W / 0D / 0T | 256s | 13/13 |
| Cinderfen Crossing | Greedy Economy | 1W / 0D / 12T | 255s | 13/13 |
| Cinderfen Crossing | Fast Army | 12W / 0D / 1T | 255s | 1/13 |
| Cinderfen Watch | Safe Beginner | 12W / 0D / 0T | 237s | 12/12 |
| Cinderfen Watch | Greedy Economy | 3W / 0D / 9T | 237s | 12/12 |
| Cinderfen Watch | Fast Army | 10W / 0D / 2T | 238s | 2/12 |

Feature/service read:

- Cinder Shrine usage: 26/39 Crossing runs captured the shrine and received the battle-local surge.
- Shrine Attunement: 2 attuned Crossing captures raised the surge to +25 Aether.
- Waystation Shrine Attunement profile: 2 wins / 0 defeats / 1 timeout across 3 Crossing runs.
- Marsh Guides and Ash Filters are covered by unit/e2e behavior; only Shrine Attunement has a dedicated simulator profile.

Strategic risk read:

- Fast Army farming risk: Fast Army wins most Cinderfen runs, especially Crossing, but it also skips or fails first-wave survival in most fast-rush cases. This remains a human-review watchpoint rather than an automated `too_easy` flag.
- Greedy Economy timeout rate: high on both Cinderfen nodes, especially Crossing 12/13 timeouts and Watch 9/12 timeouts. This looks like slow objective routing/final-assault timing rather than first-contact unfairness, because all Greedy runs survive the first wave.
- Retinue + Training Yard II strength: 6 wins / 0 defeats / 0 timeouts across Crossing and Watch. Strongest Chapter 2 profile and worth human review before more rewards or retinue-adjacent buffs.
- Quartermaster II interaction: Retinue + Quartermaster II is strong at 5 wins / 0 defeats / 1 timeout across Chapter 2; Economy/Tier II Quartermaster paths make Watch a human-review strategy-spread case.
- Rival impact: current Chapter 2 battles do not have named enemy heroes and telemetry reports 0 Cinderfen rival modifiers applied. The Malrec consequence is an event/trophy option, not a battle pacing modifier.
- Reward strength: both Chapter 2 battles remain listed as useful reward nodes. Crossing first-clear reward reads 125 XP, 170 resources, `aether_lens`, and `scouts_bow`; Watch first-clear reward reads 128 XP, 170 resources, and `aether_lens`.
- Automated warnings: no `too_easy`, no `too_hard`, no unfair first attack nodes, no weak reward nodes, and no Stronghold warnings.
- Chapter 1 regression stability: telemetry still reports Chapter 1 nodes in their prior bands, with Safe Beginner able to stabilize milestone content.

## 8. Missing Coverage And Actions

Added in this review:

- `CampaignMapViewModel.test.ts` now asserts Cinderfen Waystation service effect copy for Marsh Guides, Ash Filters, Refugee Scouts, Shrine Attunement, and the repeatable/one-time labels.

Important coverage already present:

- Unlock/select event node, Overlook choices, Malrec condition, Waystation service use, Crossing victory/reward/return, Watch victory/reward/return, Aftermath choice/reward/duplicate-prevention behavior, reward duplicate prevention, Cinder Shrine surge rules, and save/load behavior.

Remaining non-blocking gaps:

- No screenshot-based visual assertion for Cinder Shrine salience, fog mood, or raised-road readability.
- No mobile-specific Waystation or Aftermath density check.
- No manual feel pass on whether Greedy Economy timeouts are frustrating or simply a valid strategic failure.

Recommendation:

- Do not tune numbers from this automated review alone. The current data says Chapter 2 is structurally reasonable, while the remaining risks need a short human readability/feel pass before changing balance.

## Verification

Commands completed for this pass:

- `npm test` - latest route checkpoint passed, 259 tests.
- `npm run build` - passed; Vite emitted the existing large-chunk warning.
- `npm run test:e2e -- --reporter=line` - passed, 52 Playwright tests in about 21.4 minutes.
- `npm run playtest:sim` - passed, 255 deterministic runs across 85 campaign battle summaries.
