# v0.7.2 Retinue + Training Yard II Pressure Review

Date: 2026-05-09

Status: Phase 6 telemetry review. This review evaluates whether saved veterans plus Training Yard II make Cinderfen pressure meaningless. It does not tune retinue, Stronghold upgrades, pressure plans, rewards, saves, maps, units, factions, workers, construction, enemy economy, live reinforcements, capture-site contest AI, defensive hold behavior, or broad systems.

## 1. Review Question

Does Retinue + Training Yard II trivialize Enemy Strategic Pressure V1 enough to require a v0.7.2 change?

Short answer: no immediate change.

It clearly makes current Cinderfen pressure much easier, but the evidence points to a retinue/Stronghold power watchpoint rather than a pressure readability or pressure fairness bug.

## 2. Evidence Summary

Profile: `Retinue + Training Yard II`

Scope: `cinderfen_crossing` and `cinderfen_watch`

| Metric | Result |
| --- | ---: |
| Runs | 6 |
| Wins | 6 |
| Defeats | 0 |
| Timeouts | 0 |
| Pressure-triggered runs | 5 |
| Pressure warnings shown | 9 |
| Losses after pressure | 0 |
| Total unit losses | 0 |
| Reinforcement applied | 0 |

Starting force in these runs:

- 6 Militia
- 2 Rangers
- Veteran Militia
- Seasoned Ranger
- Seasoned Militia
- Stronghold upgrades `training_yard_i` and `training_yard_ii`

That is intentionally far above the no-retinue Cinderfen baseline. It is a saved-progress power profile, not the normal first Chapter 2 read.

## 3. Per-Run Read

| Node | Script | Result | Duration | Pressure stages | First pressure | Warnings | Unit losses |
| --- | --- | --- | ---: | --- | ---: | ---: | ---: |
| Cinderfen Crossing | Safe Beginner | victory | 6:10 | Shrine route warning, Causeway contest timing | 4:42 | 2 | 0 |
| Cinderfen Crossing | Greedy Economy | victory | 4:39 | Shrine route warning, Causeway contest timing | 0:35 | 2 | 0 |
| Cinderfen Crossing | Fast Army | victory | 1:21 | none | - | 0 | 0 |
| Cinderfen Watch | Safe Beginner | victory | 5:39 | Watch road response, Raised-road pressure warning | 0:07 | 2 | 0 |
| Cinderfen Watch | Greedy Economy | victory | 4:39 | Watch road response, Raised-road pressure warning | 0:07 | 2 | 0 |
| Cinderfen Watch | Fast Army | victory | 1:16 | Watch road response | 0:44 | 1 | 0 |

The pressure system is not failing to trigger broadly: 5/6 runs see at least one pressure stage. The exception is Fast Army on Crossing, which wins before the shrine-route pressure matters. That bypass pattern was already accepted as strategy expression in the Crossing review and is amplified by the stronger starting army.

## 4. Does Pressure Trigger?

Mostly yes.

- Crossing Safe Beginner and Greedy Economy both trigger pressure.
- Crossing Fast Army wins before pressure matters.
- Watch triggers pressure in all three scripts.

This means the issue is not missing plan wiring. The pressure signal exists, but the saved veteran army is strong enough that pressure does not create attrition.

## 5. Are Losses After Pressure Near Zero?

Yes. They are exactly zero in this profile.

That is meaningful. It means current pressure does not threaten a Retinue + Training Yard II player in the simulator. It also means v0.7.2 should not interpret retinue-assisted wins as proof that pressure is too weak for ordinary players.

## 6. Acceptable Power Fantasy Or Balance Smell?

For v0.7.2, this is acceptable power fantasy with a watchpoint.

Reasons:

- Retinue units are earned by keeping Seasoned+ units alive in earlier battles.
- Training Yard II is a campaign-resource investment.
- The profile represents a stacked player state, not the normal first-clear path.
- No current automated analyzer flags Cinderfen as structurally `too_easy`.
- Retinue + Training Yard II strength predates Enemy Strategic Pressure V1.
- Making pressure harsher to hurt this profile would likely punish no-retinue and normal players first.

The watchpoint is real: deathless 6/6 Cinderfen wins can make pressure feel cosmetic for stacked saves. That should be judged in a later retinue/Stronghold balance review, not by escalating v0.7.2 pressure.

## 7. Does This Make Chapter 2 Too Easy?

Not globally.

It makes Chapter 2 easy for this specific stacked profile. The broader Chapter 2 telemetry still has strategy spread:

- Cinderfen Crossing remains 26 wins / 0 defeats / 13 timeouts.
- Cinderfen Watch remains 25 wins / 0 defeats / 11 timeouts.
- Greedy Economy still times out often without this stacked profile.
- Fast Army still creates quick-clear reads rather than universal pressure relevance.

The correct conclusion is not "buff pressure." It is "review retinue/Training Yard II strength with human play before changing numbers."

## 8. Is This A Retinue Issue Rather Than A Pressure Issue?

Yes.

Pressure warnings still trigger, status feedback remains readable, and live reinforcement remains off. The reason pressure does not cost units is the saved veteran starting force and Training Yard II capacity, not a Cinderfen pressure bug.

## 9. Decision

No tuning is applied.

Do not change:

- pressure warning copy
- pressure timing
- pressure plan scope
- existing-wave timing nudge strength
- retinue capacity
- Training Yard II
- veterancy stats
- Cinderfen map balance
- rewards
- save schema
- live reinforcement, contest, or defensive-hold behavior

## 10. Future Evidence Needed

Before any retinue or pressure adjustment:

- Human play Retinue + Training Yard II across Crossing and Watch.
- Compare whether the player feels rewarded or bored.
- Confirm whether deathless wins happen with ordinary human micro, not only simulator scripts.
- Check whether no-retinue Cinderfen remains fair if any retinue-side number changes are considered.
- Prefer retinue/Stronghold-specific tuning over pressure escalation if the stacked profile proves too dominant.

For now, keep Retinue + Training Yard II as a documented Cinderfen watchpoint.
