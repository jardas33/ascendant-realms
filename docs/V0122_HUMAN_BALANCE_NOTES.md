# v0.12.2 Human Balance Notes

Date: 2026-05-17

Scope: Phase 3 human-style balance notes for the v0.12.2 Human Balance Watchpoint Review. This is a review of the existing v0.12.1 green baseline, using the slow-play observations from `docs/V0121_HUMAN_PACED_PLAYTEST_NOTES.md`, the final v0.12.1 report, and current deterministic playtest telemetry. It does not add gameplay content, maps, factions, units, art, runtime assets, save changes, AI/economy systems, or numeric tuning.

## Evidence Boundary

- v0.12.1 already performed direct slow visible review on first launch, Tutorial / Proving Grounds, New Campaign, Border Village / First Claim, Ashen Outpost, Cinderfen Crossing, Cinderfen Watch, skirmish setup, Broken Ford setup context, defeat guidance, victory results, and campaign return.
- v0.12.2 re-reads that human-paced evidence through a balance/watchpoint lens and cross-checks it against `PLAYTEST_TELEMETRY.json` / `PLAYTEST_TELEMETRY.md`.
- The current telemetry has 255 deterministic runs across 85 campaign battle node/profile summaries. It can show structural balance outliers, but it still cannot judge moment-to-moment stress, visual clarity, audio, or exact human attention.
- Broken Ford is not represented in the campaign simulator matrix. It is useful here only as a skirmish setup/readability check, not as campaign balance evidence.

## Border Village / First Claim

Telemetry read:

- Border Village: 36 wins / 0 defeats / 0 timeouts.
- Safe Beginner: 12 wins / 0 defeats / 0 timeouts, first wave survived 12/12, Barracks before contact 12/12.
- Greedy Economy: 12 wins / 0 defeats / 0 timeouts, first wave survived 12/12, Barracks before contact 12/12.
- Fast Army: 12 wins / 0 defeats / 0 timeouts, average duration 1:49, but first wave and Barracks timing are bypassed because the script clears before normal wave play develops.

Human-style read:

- The v0.12.1 slow pass found the first battle command loop much clearer after selected-order and command-acknowledgement changes.
- The remaining friction was objective-tracker consistency: First Claim relies more on battle-start status and campaign guidance than on the same small objective tracker used by Ashen/Cinderfen.

Where the player wins too easily:

- Fast Army clears Border Village extremely quickly, but this is acceptable for the first battle and does not create repeat-reward pressure or Chapter 2 balance distortion.

Where the player loses unfairly:

- No current evidence. The simulator shows no defeats or timeouts.

Where the player loses because guidance is unclear:

- Not shown structurally. If a human gets lost here, it is more likely first-objective presentation than enemy balance.

Enemy pressure fairness:

- No pressure plan is active here. The battle is not a pressure-warning fairness test.

Victory feel:

- v0.12.1 found command feedback and campaign return guidance readable and satisfying enough for the current prototype.

Slow / overly punishing feel:

- No balance signal. Any future polish should be objective/readability, not difficulty reduction.

## Ashen Outpost

Telemetry read:

- Ashen Outpost: 22 wins / 0 defeats / 14 timeouts.
- Safe Beginner: 12 wins / 0 defeats / 0 timeouts, first wave survived 12/12, Barracks before contact 12/12.
- Greedy Economy: 3 wins / 0 defeats / 9 timeouts, peak crowns average 4159, average final army 6.2.
- Fast Army: 7 wins / 0 defeats / 5 timeouts, first wave survived 5/12, average duration 8:16.
- Retinue + Training Yard II: 3 wins / 0 defeats / 0 timeouts, average duration 4:09, 0 average losses, final army 15.0.

Human-style read:

- The v0.12.1 slow pass found the Ashen objective tracker strong: `Next` points at the Burned Shrine, the shrine payoff explains the safer fortress push, and Captain Malrec guidance tells the player to secure shrine/Barracks before using hero abilities.
- The remaining risks are fortress/tower/commander visual readability and result density, which are visual/UI debt rather than proven balance failure.

Where the player wins too easily:

- Retinue + Training Yard II turns Ashen Outpost into a very clean clear. This is a real strength signal.
- It is still earned progression, and the full profile retains defeats/timeouts elsewhere, so this is not enough evidence for a nerf by itself.

Where the player loses unfairly:

- No defeat spike. Ashen failures are timeouts, while Safe Beginner wins every run.

Where the player loses because guidance is unclear:

- Greedy Economy timeouts with high resource float suggest conversion trouble: the player has resources but does not turn them into final pressure quickly enough.
- If this appears in human play, results/fortress-push guidance is the likely place to improve before changing numbers.

Enemy pressure fairness:

- Ashen Outpost does not use the Cinderfen pressure warning plan. It is a milestone pacing/fortress read, not the pressure-warning fairness test.

Victory feel:

- Victory should feel earned when the player follows the shrine, Barracks, and final-push sequence.
- With strong retinue it may feel more like a payoff for prior campaign investment than a tactical puzzle.

Slow / overly punishing feel:

- Greedy Economy and no-Stronghold timeouts show the map can run long if the player delays the final push. Current evidence points to pacing/guidance rather than unfair combat stats.

## Cinderfen Crossing

Telemetry read:

- Cinderfen Crossing: 26 wins / 0 defeats / 13 timeouts.
- Safe Beginner: 13 wins / 0 defeats / 0 timeouts, first wave survived 13/13, 33 pressure warnings, 7 losses after pressure.
- Greedy Economy: 1 win / 0 defeats / 12 timeouts, first wave survived 13/13, 38 pressure warnings, 60 losses after pressure, peak crowns average 4749.
- Fast Army: 12 wins / 0 defeats / 1 timeout, average duration 2:40, pressure triggered in only 1/13 runs.
- Retinue + Training Yard II: 3 wins / 0 defeats / 0 timeouts, average duration 4:03, 0 losses, final army 13.0.

Human-style read:

- v0.12.1 found the Cinder Shrine plan understandable after copy polish: claim it for a one-time +20 Aether surge, then hold it.
- The map name is now aligned with campaign language.
- Remaining roughness is landmark/art readability for shrine, marsh, and causeway features.

Where the player wins too easily:

- Fast Army is very fast on Crossing and often wins before pressure fully develops.
- Retinue + Training Yard II also clears cleanly with no losses in the reviewed profile.

Where the player loses unfairly:

- No defeats. The worst outcome pattern is timeout, not sudden loss.

Where the player loses because guidance is unclear:

- Greedy Economy is the clearest conversion failure: it survives the first wave, completes Barracks before contact, floats large resources, then times out.
- That reads as risky/slow play failing to push, not as an unfair economy trap.

Enemy pressure fairness:

- Pressure is visible in telemetry. Safe and Greedy trigger pressure every run and show warnings.
- Safe Beginner still wins 13/13 while seeing pressure, which argues that warnings are actionable enough structurally.
- Greedy losses after pressure are high, but paired with timeouts and high resource float rather than defeats.

Victory feel:

- Safe victories feel earned through shrine, side income, regrouping, and pressure response.
- Fast Army victory is a legitimate speed profile as long as repeat-clear rewards stay modest.

Slow / overly punishing feel:

- Greedy Economy can feel slow or frustrating, but the issue is converting advantage into victory rather than insufficient resources or unavoidable pressure.

## Cinderfen Watch

Telemetry read:

- Cinderfen Watch: 25 wins / 0 defeats / 11 timeouts.
- Safe Beginner: 12 wins / 0 defeats / 0 timeouts, first wave survived 12/12, 24 pressure warnings, 9 losses after pressure.
- Greedy Economy: 3 wins / 0 defeats / 9 timeouts, first wave survived 12/12, 33 pressure warnings, 54 losses after pressure, peak crowns average 3872.
- Fast Army: 10 wins / 0 defeats / 2 timeouts, pressure triggers in 12/12 runs, 20 warnings, 13 losses after pressure.
- Retinue + Training Yard II: 3 wins / 0 defeats / 0 timeouts, average duration 3:51, 0 losses, final army 13.0.

Human-style read:

- v0.12.1 found the Watch Road objective readable: capture the road, scout fog around the tower, then handle Brute/tower pressure.
- Remaining risk is fog/tower visual salience, not current numeric pressure timing.

Where the player wins too easily:

- Retinue + Training Yard II again produces a clean low-friction clear.
- Fast Army is quick but not free: it still triggers pressure in every Watch run and records timeouts/losses.

Where the player loses unfairly:

- No defeat signal. Failures are timeouts.

Where the player loses because guidance is unclear:

- If a player times out here, likely causes are delayed push timing, not converting income, or losing tempo around the Watch Road/tower route.

Enemy pressure fairness:

- Watch pressure triggers every run and shows warnings. Safe Beginner wins all runs while seeing pressure.
- Fast Army still succeeds often under pressure, while Greedy Economy times out under heavy losses after pressure. That is a reasonable strategy spread, not a structural unfairness flag.

Victory feel:

- Victory feels earned when the player captures Watch Road, respects fog/tower threat, and converts a safe army into a push.

Slow / overly punishing feel:

- Greedy Economy can feel slow because the script hoards resources and suffers losses after pressure. This is a player-guidance watchpoint, not a current numeric tuning reason.

## Skirmish / Broken Ford Path

Human-style read:

- v0.12.1 found Skirmish Setup readable: map, difficulty, and AI personality choices are clear enough for quick map selection.
- Broken Ford setup copy clearly says the center is dangerous and side resource routes are safer but slower.
- v0.12.1 fixed the skirmish defeat guidance so it no longer suggests campaign-only camp or Chapel support.

Balance read:

- Broken Ford is not part of the current campaign simulator telemetry. It should not drive campaign tuning.
- Its useful signal is readability parity: skirmish should teach command feedback and risk language without campaign-only advice.

Where the player wins too easily:

- No new evidence in v0.12.2.

Where the player loses unfairly:

- No new evidence in v0.12.2.

Where the player loses because guidance is unclear:

- The main historic issue was incorrect skirmish defeat advice, now fixed in v0.12.1.

## Watchpoint Conclusions From Human-Style Notes

Retinue + Training Yard II:

- Strong and satisfying, especially on Ashen/Cinderfen.
- It is a watchpoint because it can produce clean, fast clears with no losses.
- Current evidence does not prove it is too strong enough to nerf; it may be doing the intended job of making earned veterans feel valuable.

Greedy Economy:

- Risky rather than unfair.
- It usually has enough resources and survives early pressure, then fails to convert economy into timely victory.
- If later human play finds this confusing, improve result/route advice before changing timing or resources.

Fast Army:

- Legitimate speed profile.
- It clears some maps quickly, especially Cinderfen Crossing, but it also accepts first-wave bypass/failure risk and does not dominate the whole suite.

Early campaign defeats:

- No structural early defeat cause is visible. Border Village has no losses; Ashen has timeouts, not defeats; Safe Beginner wins all reviewed nodes.

Pressure warning fairness:

- Cinderfen warnings are fair and actionable in the structural evidence. Safe Beginner wins all pressure-enabled Cinderfen runs while seeing warnings.
- Remaining fairness risk is human noticeability under stress, not a current pressure-number problem.

