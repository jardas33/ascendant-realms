# v0.7.2 Greedy Economy And Fast Army Pressure Review

Date: 2026-05-09

Status: Phase 7 strategy-extreme review. This review evaluates Greedy Economy timeout readability and Fast Army pressure bypass. It does not tune pressure plans, rewards, saves, maps, units, factions, workers, construction, enemy economy, live reinforcements, capture-site contest AI, defensive hold behavior, or broad systems.

## 1. Review Question

Do the two extreme scripts reveal a v0.7.2 pressure readability or timing problem?

Short answer: no tuning is applied.

Greedy Economy still shows the clearest timeout pattern, but it receives pressure warnings consistently and survives the first wave. Fast Army still expresses a valid rush route, especially on Crossing where it often wins before pressure matters. Neither pattern justifies making pressure earlier or harsher.

## 2. Greedy Economy Summary

Scope: all current pressure-enabled Cinderfen runs with `playerScript = greedy_economy`.

| Node | Runs | Wins | Defeats | Timeouts | Triggered | Warnings | Avg first pressure | Losses after pressure | Reinforcement applied |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Cinderfen Crossing | 13 | 1 | 0 | 12 | 13 | 38 | 0:35 | 60 | 0 |
| Cinderfen Watch | 12 | 3 | 0 | 9 | 12 | 33 | 0:07 | 54 | 0 |
| Total | 25 | 4 | 0 | 21 | 25 | 71 | - | 114 | 0 |

Greedy Economy triggers pressure in every pressure-enabled Cinderfen run. The issue is not invisible pressure. The issue is that greedy openings delay conversion into enough army pressure to finish before the simulator timeout.

## 3. Greedy Economy Findings

Timeout pattern:

- Crossing: 12/13 timeouts.
- Watch: 9/12 timeouts.
- No defeats.
- First wave survived in every Greedy pressure-node run.

This suggests Greedy Economy is not being crushed by an unfair pressure spike. It survives, floats resources, and fails to close quickly enough.

Do pressure warnings help?

Partially. The warnings tell the player the enemy is responding:

- Crossing points to the shrine route and faster pressure after the shrine.
- Watch points to road income and faster pressure on the raised road.

That is the right warning style for v0.7.2. Greedy still timing out is a pacing/build-order result, not proof that the warnings should become stronger mechanics.

Should defeat or timeout guidance be clearer?

Not in Phase 7. Existing Cinderfen defeat tips already point toward the relevant practical answers:

- Crossing: secure side income, claim the Cinder Shrine, clear Cinder Guardians, destroy Enemy Barracks before the Stronghold.
- Watch: claim Watch Road Toll, clear the Marsh Raider Camp, destroy the Watchpost Tower before committing to the Stronghold.
- Pressure-specific tips already mention holding the shrine route, guarding income, regrouping, and pushing after waves break.

A future full human playtest can still judge whether timeout results need a dedicated "convert your bank into army sooner" message, but the current evidence does not require a v0.7.2 copy change.

Does pressure worsen Greedy Economy?

It likely contributes to attrition, but it does not create a defeat spike. The key evidence is 0 defeats and 25/25 first-wave survivals across Greedy pressure-node runs. Greedy loses to clock/closure, not sudden pressure collapse.

## 4. Fast Army Summary

Scope: all current pressure-enabled Cinderfen runs with `playerScript = fast_army`.

| Node | Runs | Wins | Defeats | Timeouts | Triggered | Warnings | Avg first pressure | Losses after pressure | Reinforcement applied |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Cinderfen Crossing | 13 | 12 | 0 | 1 | 1 | 1 | 6:30 | 4 | 0 |
| Cinderfen Watch | 12 | 10 | 0 | 2 | 12 | 20 | 0:44 | 13 | 0 |
| Total | 25 | 22 | 0 | 3 | 13 | 21 | - | 17 | 0 |

Fast Army is the inverse of Greedy Economy. It usually wins, often before later pressure stages matter, and it records no defeats.

## 5. Fast Army Findings

Crossing quick-clear bypass:

- Fast Army wins 12/13 Crossing runs.
- Pressure triggers in only 1/13 Crossing runs.
- The triggered Crossing run first pressures at 6:30, much later than most Fast Army wins.

This is acceptable strategy expression. Crossing pressure is tied to shrine/route behavior, and a fast direct clear can outrun that plan. Making pressure trigger earlier just to catch Fast Army would likely make the pressure feel arbitrary for normal players and would weaken the map's strategic choice space.

Watch quick-clear pattern:

- Fast Army wins 10/12 Watch runs.
- Pressure triggers in 12/12 Watch runs.
- Average first pressure is about 0:44.

Watch pressure already catches the fast route because Watch Road is part of the fast objective path. Despite that, Fast Army usually wins. That is a useful contrast with Crossing, not a bug.

Should pressure punish Fast Army more?

No. Fast Army should remain a viable expression of "I invested in immediate force and accepted risk." v0.7.2 is a feel/readability gate, not a mandate to close every bypass.

## 6. Decision

No tuning is applied.

Decision: no pressure timing tweak, no warning copy change, no defeat-tip change, no telemetry label change, no plan scope change, and no existing-wave timing nudge change.

Reasons:

- Greedy Economy already triggers pressure consistently and receives warnings.
- Greedy timeouts are closure/build-order pacing issues, not pressure-caused defeats.
- Fast Army bypass on Crossing is acceptable strategy expression.
- Watch already demonstrates that Fast Army can trigger pressure and still win.
- There are no pressure reinforcement applications.
- Strengthening pressure to target Fast Army or Greedy Economy would risk punishing normal players first.

## 7. Future Watchpoints

Potential future human-play questions:

- Does a Greedy player understand that they need to convert banked resources into army sooner?
- Should timeout results eventually include a clearer "spend floating resources and push after waves" message?
- Does Fast Army feel exciting or does it skip too much Cinderfen identity?
- Should a future simulator-only experiment test a softer Fast Army pressure read before any live change?

For v0.7.2, keep both strategy extremes as evidence that pressure is subtle and strategy-dependent, not as reasons to promote stronger actions.
