# v0.3 Cinderfen Route Baseline Candidate

Date: 2026-05-04

This document promotes the current Cinderfen route to a clean v0.3 vertical-slice baseline candidate. It is a documentation and release-baseline checkpoint only: no gameplay, balance, map, unit, faction, worker, construction, diplomacy, procedural-generation, crafting, durability, or broad loot systems were added for this promotion.

## Current Playable Route

The playable campaign route is the existing Chapter 1 spine through Ashen Outpost, followed by the compact Chapter 2 Cinderfen route:

1. `ashen_outpost` is the prerequisite Chapter 1 battle.
2. `cinderfen_overlook` is the Chapter 2 preparation event unlocked after Ashen Outpost.
3. `cinderfen_waystation` is the optional Cinderfen support node unlocked after Overlook.
4. `cinderfen_crossing` launches the authored `cinderfen_causeway` battle after Overlook.
5. `cinderfen_watch` launches the authored `cinderfen_watchpost` battle after Crossing victory.
6. `cinderfen_aftermath` is the compact consequence event after Watch victory.

This is not a full Chapter 2 campaign. It is the current route baseline for verification, readability, UX, and controlled polish.

## Node Order

| Order | Node | Type | Unlock | Current Purpose |
| --- | --- | --- | --- | --- |
| 1 | `ashen_outpost` | Battle | Chapter 1 route | Prerequisite for Chapter 2 Cinderfen access. |
| 2 | `cinderfen_overlook` | Event | Complete `ashen_outpost` | Introduces the Cinderfen route and lets the player choose a preparation path. |
| 3 | `cinderfen_waystation` | Town/support | Complete `cinderfen_overlook` | Optional one-time services that spend existing campaign resources for modest Cinderfen preparation. |
| 4 | `cinderfen_crossing` | Battle | Complete `cinderfen_overlook` | First Cinderfen battle, with the Cinder Shrine first-capture Aether surge. |
| 5 | `cinderfen_watch` | Battle | Win `cinderfen_crossing` | Second Cinderfen battle, compact watchpost pressure test. |
| 6 | `cinderfen_aftermath` | Event | Win `cinderfen_watch` | Modest post-route consequence choice and Malrec trophy follow-up. |

## Rewards Summary

- Cinderfen Crossing first clear currently pays 125 total XP and 170 total resources, plus one first-clear battle item roll and the fixed `scouts_bow` campaign reward.
- Cinderfen Watch first clear currently pays 128 total XP and 170 total resources, plus one first-clear battle item roll.
- The two required Cinderfen battles therefore pay 253 total XP and 340 total resources on first clear before event choices and Waystation spending.
- Cinderfen Crossing repeat clears pay only 4 XP and 11 resources, with no repeat battle item roll.
- Cinderfen Watch repeat clears pay only 3 XP and 8 resources, with no repeat battle item roll.
- Cinderfen Overlook and Cinderfen Aftermath remain modest once-only event reward/cost nodes. Their choices are useful route flavor and preparation, not farm loops.
- Cinderfen Waystation service costs remain unchanged: Marsh Guides, Ash Filters, Refugee Scouts, Shrine Attunement, and the optional Malrec Standard use existing resource, reputation, modifier, save, and duplicate-prevention rules.
- Chapter 1 reward values remain unchanged by the Cinderfen reward-economy audit and this v0.3 baseline promotion.

The current economy read is useful but deliberately not generous on repeat. Fast Army and Retinue plus Training Yard II remain watchpoints rather than reasons to add systems.

## Simulator Summary

The latest deterministic simulator baseline is 255 runs across 85 node/profile summaries:

- No `too_easy` nodes.
- No `too_hard` nodes.
- Ashen Outpost remains beatable.
- No Stronghold warnings.
- Cinderfen Crossing: 39 runs, 26 victories, 0 defeats, 13 timeouts.
- Cinderfen Crossing by script: Safe Beginner 13/13 victories, Greedy Economy 1/13 victories with 12 timeouts, Fast Army 12/13 victories with 1 timeout.
- Cinderfen Watch: 36 runs, 25 victories, 0 defeats, 11 timeouts.
- Cinderfen Watch by script: Safe Beginner 12/12 victories, Greedy Economy 3/12 victories with 9 timeouts, Fast Army 10/12 victories with 2 timeouts.
- Retinue plus Training Yard II is the strongest observed setup, at 6 victories and 0 defeats across the Cinderfen pair.
- Cinder Shrine was captured in 26 of 39 Crossing runs; 2 Waystation-attuned runs received the 25 Aether surge.

## E2E Summary

The latest checkpointed Playwright suite passed 52 tests. Chapter 2 coverage includes:

- Post-Ashen campaign seeding.
- Cinderfen Overlook choice flow.
- Cinderfen Waystation service purchase and duplicate-prevention checks.
- Cinderfen Crossing launch, Cinder Shrine capture hook, victory flow, and reward assertions.
- Cinder Shrine duplicate-prevention coverage.
- Cinderfen Watch launch, victory flow, and reward assertions.
- Cinderfen Aftermath choice flow.
- Malrec trophy consequence coverage.

Chapter 2 helper cleanup has been completed in `tests/e2e/chapter2-helpers.ts`. The helpers are test-only where they force progress/victory and use safe hooks where they interact with intended test harness entry points.

## Known Risks

- Fast Army is still efficient on the Cinderfen pair, but repeat rewards are now tiny and item rolls are first-clear only.
- Retinue plus Training Yard II can make the Cinderfen battles comfortable and should remain a human-review watchpoint.
- Cinder Shrine timing and Shrine Attunement value may need UX/readability polish, not economy expansion.
- Cinderfen Watchpost tower, fog, and objective readability should be checked in a real browser pass.
- Overlook, Waystation, and Aftermath choice density should be checked on mobile-sized layouts.
- The e2e suite is valuable but relatively slow, so keep helper changes stable and avoid brittle selector churn.

## Forbidden Next Steps

Do not use the v0.3 baseline promotion as permission to add broad systems. In the next phase, do not add:

- New maps.
- New factions.
- New units.
- Workers or broader economy workers.
- Enemy construction or rebuilding.
- Diplomacy or alliances.
- Procedural campaign generation or procedural maps.
- Crafting, durability, affix rerolling, or broad loot complexity.
- Broad army-management systems.
- A full Chapter 2 campaign expansion before the current route is verified and polished.

## Recommended Next Steps

The next phase is **automated route readiness + polish freeze**:

- Keep running the required verification set before release-style checkpoints: `npm test`, `npm run build`, `npm run test:e2e -- --reporter=line`, and `npm run playtest:sim`.
- Use optional `npm run preview` plus Browser Use smoke only when a visible release/browser sanity check is needed.
- Human-verify the route end to end from Ashen Outpost through Cinderfen Aftermath.
- Polish readability, copy, layout density, and UX affordances where verification shows friction.
- Preserve current reward pacing unless future telemetry shows a clear issue.
- Keep Chapter 2 compact until this route is green as a baseline.
