# v0.7.3 Real-Input Pressure Playtest Protocol

Status: Phase 1 protocol. This document defines how to review Cinderfen pressure with the closest available player-like browser input before making any changes.

## 1. Purpose

The v0.7.3 goal is to judge human noticeability and feel, not simulator balance alone.

The review asks whether a player can notice, understand, and respond to the current Enemy Strategic Pressure V1 warnings during normal-feeling Cinderfen play. It does not try to prove a new mechanic, expand pressure behavior, or tune against every strategy profile.

Evidence must be labeled by source:

- Real-input manual evidence: notes from a person using mouse and keyboard directly.
- Controlled browser-input evidence: browser automation or in-app browser clicks/keypresses used at human-like pacing.
- Seeded surrogate evidence: Playwright/test-hook setup used to reach Cinderfen states without replaying the full campaign.
- Simulator evidence: deterministic telemetry from `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json`.

No subjective claim should be recorded without an evidence label.

## 2. Battles

Review only the two current pressure-enabled campaign battles:

- `cinderfen_crossing` on `cinderfen_causeway`
- `cinderfen_watch` on `cinderfen_watchpost`

Do not add pressure to Ashen Outpost, Chapter 1, Tutorial / Proving Grounds, skirmish, or any other node.

## 3. Profiles

Use four review lenses:

Safe Beginner:

- Stabilize first.
- Capture income sites and build a modest army.
- Treat warnings as guidance.
- Expected read: pressure should teach caution without feeling punitive.

Greedy Economy:

- Spend longer on income, upgrades, or setup before decisive attacks.
- Watch for timeouts and whether the warning explains the cost of delay.
- Expected read: timeouts should feel like slow conversion of resources into force, not surprise punishment.

Fast Army:

- Build and attack quickly.
- Accept risk to finish before pressure fully develops.
- Expected read: bypassing some Crossing pressure can be valid skill expression if the player made a clear aggressive choice.

Retinue + Training Yard II:

- Use saved-progress power and a stronger starting force.
- Watch whether pressure becomes irrelevant.
- Expected read: dominance may be acceptable saved-progress power, but it should be documented as a retinue/Stronghold watchpoint rather than solved by harsher enemy pressure.

## 4. Review Questions

For each reviewed battle, answer:

- Did I notice the pressure warning?
- Did I understand what caused it?
- Did I understand what to do next?
- Did the warning stay visible long enough?
- Did it appear too early?
- Did it appear too late?
- Did it compete with stronger objective feedback?
- Did it change my next decision?
- Did the pressure feel fair?
- Did it make the map identity clearer?

Crossing-specific questions:

- Was the Cinder Shrine visible enough to matter?
- Was `Cinder Shrine Surge` noticed?
- Did shrine reward feedback stay above pressure feedback?
- Did the delayed route-pressure warning arrive while the player could still act on it?
- Did Fast Army bypass feel fun, clever, or too cheap?

Watch-specific questions:

- Was Watch Road visible enough to explain the warning?
- Did immediate Watch Road pressure feel too early?
- Did the delayed road warning remain readable under combat/status churn?
- Did the warning suggest a practical response?
- Did Greedy Economy timeout for understandable reasons?

Strategy-profile questions:

- Safe Beginner: did pressure teach caution?
- Greedy Economy: did warnings and results explain the timeout pattern?
- Fast Army: did bypass feel like valid strategy expression?
- Retinue + Training Yard II: did saved-progress power make pressure irrelevant?

## 5. Evidence To Capture

Use lightweight evidence:

- Browser notes with route taken, input style, and timing impressions.
- Screenshots for visible warning moments when available.
- Console error count for each browser pass.
- Pressure status text and whether it was visible.
- Whether objective/resource/minimap/HUD surfaces stayed readable.
- Telemetry references for profile outcomes, warnings, timeouts, and losses after pressure.
- Any result/defeat tip text that helped or failed to help.

Screenshot evidence should record the local path in the review doc. Screenshots are optional if capture would slow or destabilize the pass, but visual state should still be described.

## 6. Change Threshold

Make no gameplay change by default.

Tiny polish is allowed only when the review shows a clear, repeatable problem:

- Warning copy is ambiguous.
- Warning timing is visibly too early or too late.
- Pressure status duration is too short to read.
- Defeat or timeout guidance does not explain the practical response.

Allowed tiny changes:

- Warning copy.
- Warning timing.
- Status duration.
- Defeat-tip wording.
- Documentation/report wording.
- E2E assertion wording, only if a real observability gap is discovered.

Forbidden changes:

- Live reinforcement behavior.
- Capture-site contest AI.
- Defensive hold behavior.
- New pressure stages.
- New pressure plans.
- New maps.
- New units.
- New factions.
- Workers or enemy workers.
- Real enemy construction.
- Build placement AI.
- Harvesting or enemy economy simulation.
- Reward changes.
- Save changes or save-version bumps.
- Campaign progression changes.
- Broad BattleScene rewrites.

## 7. Non-Goals

This protocol is not:

- A full balance pass.
- A new enemy AI system.
- A live reinforcement experiment.
- A capture-site contest prototype.
- A defensive-hold prototype.
- Enemy construction, workers, or economy.
- Chapter 2 content expansion.
- A tutorial reward or campaign reward change.
- A new map, unit, faction, asset, or desktop packaging step.

## 8. Pass/Fail Criteria

Pass:

- Crossing and Watch can be reviewed with clearly labeled evidence.
- The review separates controlled browser-input evidence from true manual evidence.
- Pressure warnings are judged for noticeability, cause, response clarity, and fairness.
- Any no-change decision is explicit.
- Any tiny polish has a direct evidence trail.
- Tutorial, skirmish, Ashen Outpost, Chapter 1, rewards, saves, maps, units, factions, workers, construction, and economy remain untouched.

Fail or stop:

- A review finding would require live reinforcement, contest AI, defensive hold, workers, construction, economy AI, new maps, new units, new factions, reward changes, save changes, campaign progression changes, or broad BattleScene rewrites.
- Evidence is too weak to distinguish player-feel issues from simulator-only assumptions.
- Verification cannot be restored after focused fixes.
