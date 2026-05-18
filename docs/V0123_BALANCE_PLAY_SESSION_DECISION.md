# v0.12.3 Balance Play Session Decision

Date: 2026-05-17

Scope: Phase 4 decision after v0.12.3 human-style campaign play session review.

## Decision Summary

No numeric tuning was made.

No copy/readability change was made.

No runtime code, gameplay data, simulator logic, tests, art/assets, save data, release scripts, or CI plumbing changed in this phase.

The evidence strengthens the v0.12.2 conclusion: the current balance questions are real watchpoints, but they do not yet justify tuning.

## Retinue + Training Yard II

Decision: no change.

Reason:

- It is the strongest reviewed route and produces repeated no-loss Ashen/Cinderfen clears.
- It still reads as earned campaign power because it requires veterans plus Stronghold investment.
- The direct review threshold for a nerf was repeated evidence that objectives, production, and pressure no longer matter. Current evidence shows a very clean route, but not enough human-stress proof that the reward is harmful.

Risk:

- It is close to too clean. Future direct human play should test whether the player can ignore shrine/road objectives and still win comfortably.

Deferred:

- Retinue capacity, Training Yard II cost/capacity, veterancy stat multipliers, and enemy compensation changes.

## Greedy Economy

Decision: no change.

Reason:

- Greedy Economy survives early pressure and completes Barracks before contact.
- Failures show high resource float plus timeouts/losses after pressure, not early unfairness or underpowered economy.
- Current copy already tells players to secure side income, shrine/road objectives, production, and push timing.

Risk:

- Human players may still not understand why resource float is not enough. That needs direct tester feedback before copy changes.

Deferred:

- Economy buffs, timeout relief, pressure nerfs, new sinks, and broad economy systems.

## Fast Army

Decision: no change.

Reason:

- Fast Army is very quick on Cinderfen Crossing and fast on Watch, but Ashen still has failures/timeouts and Watch still triggers pressure in every reviewed Fast Army run.
- Speed currently rewards decisive play rather than trivializing the whole campaign slice.

Risk:

- If future human play shows Fast Army repeatedly skips shrine/road/pressure identity with low losses and high reward value, revisit reward pacing or map timing.

Deferred:

- Slowdown tuning, anti-rush mechanics, reward redesign, or enemy AI changes.

## Early Defeats

Decision: no change.

Reason:

- Border Village remains stable and readable in direct browser entry.
- Structural evidence has no early defeat spike.
- Ashen Outpost problems are timeouts/final-push attrition rather than early losses.

Risk:

- First Claim could still benefit from richer objective presentation later, but not as a balance fix.

Deferred:

- Early campaign difficulty reduction and new tutorial/objective systems.

## Pressure Fairness

Decision: no change.

Reason:

- Cinderfen pressure warnings are structurally fair: baseline wins all pressure-enabled Cinderfen runs.
- Browser capture coverage makes both Crossing and Watch warning states visible in the active review lane.
- No evidence shows pressure timing is too late to act.

Risk:

- Noticeability under real combat remains the main open human-risk item because visual salience is still prototype-level.

Deferred:

- Pressure timing changes, warning read-window tuning, live reinforcements, route contest behavior, defensive hold behavior, and visual/UI redesign.

## Possible Fixes Considered And Rejected

- Clearer pressure-warning copy: rejected because current warnings already name counterplay and no new confusion was isolated.
- Clearer Greedy Economy result tip: rejected until human testers show they cannot diagnose resource-to-army conversion.
- Tiny Training Yard II/retinue adjustment: rejected because the route is strong but still plausibly satisfying earned power.
- Tiny timing adjustment: rejected because the current unfairness signal is not repeated across baseline/no-retinue/fast/greedy routes.

## Test Impact

No tests were added or updated because no behavior or copy changed.
