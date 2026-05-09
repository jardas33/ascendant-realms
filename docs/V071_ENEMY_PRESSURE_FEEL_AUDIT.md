# v0.7.1 Enemy Pressure Feel Audit

Date: 2026-05-09

Status: Phase 1 feel/readability audit for v0.7.1. This is an evidence review only. It does not change enemy pressure mechanics, rewards, saves, maps, units, factions, workers, construction, economy AI, reinforcement behavior, route contesting, or defensive hold behavior.

## Evidence Read

Sources reviewed:

- `docs/V07_ENEMY_STRATEGIC_PRESSURE_REPORT.md`
- `docs/V07_ENEMY_STRATEGIC_PRESSURE_SPEC.md`
- `docs/V07_ENEMY_PRESSURE_RESEARCH_AUDIT.md`
- `PLAYTEST_TELEMETRY.md`
- `PLAYTEST_TELEMETRY.json`
- `BALANCE.md`
- `README.md`, `ROADMAP.md`, `RELEASE_CHECKLIST.md`, `CHANGELOG.md`, `CONTENT_GUIDE.md`, `DEVELOPMENT_CHECKPOINT.md`
- `src/game/data/enemyPressurePlans.ts`
- `src/game/battle/EnemyPressureRuntime.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/core/ResultsFlow.ts`
- `tests/e2e/enemy-pressure.spec.ts`

Current telemetry:

- Baseline without pressure: 180 simulator runs.
- Pressure-enabled Cinderfen runs: 75.
- Triggered pressure runs: 63.
- Pressure warnings shown: 149.
- Simulated reinforcement applications: 0.
- Losses after pressure: 147.
- Enemy-pressure analyzer warnings: none.

Plan reads:

| Plan | Runs | Triggered | Average First Pressure | Warnings | Losses After Pressure |
| --- | ---: | ---: | ---: | ---: | ---: |
| `causeway_contest_pressure` | 39 | 27 | 2:47 | 72 | 71 |
| `ashen_watch_captain_pressure` | 36 | 36 | 0:19 | 77 | 76 |

Strategy read:

| Plan | Strategy | Record | Triggered | Warnings | Losses After Pressure |
| --- | --- | ---: | ---: | ---: | ---: |
| Causeway Contest | Safe Beginner | 13-0-0 | 13/13 | 33 | 7 |
| Causeway Contest | Greedy Economy | 1-0-12 | 13/13 | 38 | 60 |
| Causeway Contest | Fast Army | 12-0-1 | 1/13 | 1 | 4 |
| Ashen Watch Captain Pressure | Safe Beginner | 12-0-0 | 12/12 | 24 | 9 |
| Ashen Watch Captain Pressure | Greedy Economy | 3-0-9 | 12/12 | 33 | 54 |
| Ashen Watch Captain Pressure | Fast Army | 10-0-2 | 12/12 | 20 | 13 |

## 1. Does Pressure Trigger Often Enough To Be Noticeable?

Mostly yes in telemetry.

- Cinderfen Watch triggers in 36/36 simulator runs, so the system is very likely to be observed there.
- Cinderfen Crossing triggers in 27/39 simulator runs. This is enough to measure, but Fast Army bypasses it in 12/13 runs because the battle can end before shrine pressure matters.
- Across all pressure-enabled Cinderfen runs, 63/75 trigger at least one stage.

Feel risk: the simulator records warnings, but it does not prove a human saw or understood them.

## 2. Does Pressure Trigger Too Often?

Cinderfen Watch may trigger too early rather than too often.

- Average Watch first pressure is 0:19.
- Some retinue/Quartermaster paths trigger as early as 0:07.
- Because the Watch Road capture is an intended early objective, this frequency is acceptable for V1, but human play should verify it does not feel like immediate punishment for following the correct route.

Cinderfen Crossing is not over-triggering. It is route-dependent and can be bypassed by a fast center/base clear.

## 3. Is Cinderfen Crossing Pressure Understandable?

Partly.

The trigger is tied to `cinder_crossing`, the Cinder Shrine route. This supports the map identity because the shrine is already a known point of interest. At audit time, the warning copy said Ashen patrols were contesting the shrine route and that the causeway commander was pressing the center road, which pointed at the right geography.

Readability gap: the live V1 does not actually send patrols to contest the shrine route. That is acceptable because route contesting is intentionally warning/telemetry-only, but the copy should avoid implying a precise live movement behavior the player will not see.

## 4. Is Cinderfen Watch Pressure Understandable?

Mostly, but it needs clearer player-facing language.

The Watch Road Toll is concrete, objective-aligned, and visible in the node identity. At audit time, the copy said the enemy commander was reinforcing the watch road and that Ashen patrols were contesting the raised road.

Readability gap: "reinforcing" can sound like live unit reinforcement, while `reinforce_next_wave` is intentionally not applied. The warning should communicate "the enemy is reacting and pressure will arrive sooner" without promising new spawned units.

## 5. Does Warning Copy Explain What Is Happening?

Only partially.

Audit-time copy named the geography, but it did not consistently state the player impact:

- "Enemy commander is reinforcing the watch road." explains enemy intent but not what the player should expect.
- "Ashen patrols are contesting the shrine route." explains contested territory but may imply visible route-contest behavior.
- "The watchpost is pulling defenders around its stronghold." is clear as a late defensive posture, but the action remains warning/telemetry-only.

Phase 2 should tighten warning copy around player-facing consequences: faster pressure, horns answering the advance, and the need to hold income or regroup.

## 6. Does Warning Copy Explain Why The Player Should Care?

Not enough yet.

The warnings currently say what the enemy is doing, but rarely tell the player whether the practical response is to defend, regroup, keep a guard near income, or expect a sooner wave. Defeat tips help after a loss, but the in-battle warnings should be more useful in the moment.

## 7. Are Warnings Too Easy To Miss On The Battle Message Surface?

Likely yes.

The warning uses the shared `battle-status` surface at the top of the playfield. It is compact and does not add UI clutter, which is good, but it competes with normal battle state and transient combat messages.

The live status display currently:

- Uses `BattleScene.showMessage()`.
- Sets `statusMessage` directly.
- Uses a 2.5 second `statusTimer`.
- Resets to generic AI/time status when the timer reaches 0.
- Can be replaced immediately by another `showMessage()` call.

This is a good minimal surface, but pressure warnings need either clearer copy, slightly longer duration, or a category/priority guard to avoid being swallowed.

## 8. Are Warnings Overwritten Too Quickly By Normal Battle Status?

They can be.

The e2e coverage already accounts for this by asserting immediate pressure telemetry and then forcing a delayed pressure runtime tick for visible warning coverage. That is useful evidence: the runtime is reliable, but the visible status line is not guaranteed to preserve the first pressure message against normal objective/status updates.

Phase 3 should inspect whether a safe status priority fix can preserve pressure warnings longer without adding a panel or disrupting the tutorial overlay.

## 9. Does Pressure Feel Fair According To Telemetry?

Yes, within automated evidence.

- No enemy-pressure analyzer warnings.
- No structural too-hard pressure nodes.
- No defeats across Cinderfen Crossing or Cinderfen Watch in the current pressure-node summaries.
- Greedy Economy has timeouts, not defeat spikes.
- Fast Army is still viable.

Telemetry supports keeping pressure scoped and unchanged until human feel evidence exists.

## 10. Does Pressure Help Cinderfen Identity?

Yes.

Cinderfen Crossing pressure reinforces the shrine/causeway identity. Cinderfen Watch pressure reinforces the raised-road/watchpost identity. Both use existing Ashen units, Cinderfen maps, and route objectives instead of new content.

Best identity win: pressure makes the enemy feel like it noticed the player taking a key route objective.

## 11. Does Pressure Worsen Greedy Economy Timeouts?

Not enough to justify tuning.

Greedy Economy remains timeout-prone:

- Crossing: 1 win / 0 defeats / 12 timeouts while triggering pressure in 13/13 runs.
- Watch: 3 wins / 0 defeats / 9 timeouts while triggering pressure in 12/12 runs.

This is a pacing/readability watchpoint, not a pressure-specific failure. The absence of defeats suggests pressure does not make Greedy Economy unfair, but human play should check whether the warnings help players realize they need to move sooner.

## 12. Does Pressure Matter Against Fast Army?

Mixed.

- Crossing Fast Army triggers pressure only 1/13 runs. Fast Army can mostly bypass shrine-pressure identity.
- Watch Fast Army triggers pressure 12/12 runs, but still wins 10/12.

This is acceptable for V1. Pressure should not erase quick-clear strategies, but Crossing may need human review to decide whether the Cinder Shrine warning arrives too late to be felt by aggressive players.

## 13. Does Retinue + Training Yard II Trivialize Pressure?

Possibly, but this predates pressure.

Retinue + Training Yard II remains 6 wins / 0 defeats / 0 timeouts across Crossing and Watch, with 0 losses after pressure. That suggests pressure does not meaningfully threaten the strongest existing Cinderfen profile.

This is a human-review issue for retinue/Stronghold strength, not a reason to buff pressure inside v0.7.1.

## 14. Does Pressure Affect Tutorial Or Skirmish?

No.

Runtime pressure is campaign-only:

- `createEnemyPressureRuntime()` returns undefined without `mode === "campaign_node"` and a campaign node id.
- Current e2e coverage verifies Tutorial / Proving Grounds has no pressure plan id, no triggered stages, and no warnings.
- Current e2e coverage verifies Cinderfen Watchpost skirmish has no pressure plan id, no triggered stages, and no warnings even after a site capture.

This protection should remain unchanged.

## 15. What Still Requires Human Play?

Human play is still required for:

- Whether players notice pressure warnings in normal battle motion.
- Whether the warning line feels important enough without a new panel.
- Whether pressure copy sounds like real reinforcement or construction when no live reinforcement exists.
- Whether Cinderfen Watch pressure feels like fair commander response rather than punishment for early Watch Road capture.
- Whether Cinderfen Crossing shrine pressure is too easy for Fast Army to bypass.
- Whether Greedy Economy timeouts feel like clear strategic debt rather than confusing stalemate.
- Whether Retinue + Training Yard II makes pressure irrelevant in actual input play.

## Phase 1 Recommendation

Proceed to Phase 2 with copy-only warning and defeat-tip polish.

Recommended copy goals:

- Avoid implying live reinforcement or route-contest AI that is not implemented.
- Name the map objective or route.
- State the expected player impact: faster enemy pressure, guard income, regroup, or hold the route.
- Keep player-facing text free of "pressure plan" or telemetry language.

Proceed to Phase 3 after copy polish to decide whether the shared status line needs a small pressure priority/duration guard.

## Phase 2 Copy Polish Note

Phase 2 updated player-facing pressure copy to name the route and state the practical consequence without implying real enemy construction, live reinforcement, or capture-site contest AI. The new copy favors "expect faster pressure," "keep income protected," "hold the route," and "break the next wave" over technical or system-facing language.

## Phase 6 Balance Review Note

No tuning was applied in Phase 6. Regenerated telemetry still reports 255 runs, 75 pressure-enabled Cinderfen runs, 63 triggered pressure runs, 149 pressure warnings, 0 simulated reinforcement applications, no enemy-pressure analyzer warnings, no structural `too_easy` nodes, and no structural `too_hard` nodes.

The pressure pattern remains fair enough for v0.7.1:

- Cinderfen Crossing stays at 26 wins / 0 defeats / 13 timeouts, with Fast Army bypassing most shrine pressure but not creating a reward or difficulty reason to buff the plan.
- Cinderfen Watch stays at 25 wins / 0 defeats / 11 timeouts, with 36/36 pressure triggers and no defeat spike.
- Greedy Economy remains timeout-prone across pressure nodes, but the failures are pacing/readability signals rather than pressure-caused defeats.
- Retinue + Training Yard II still trivializes many Cinderfen risks, but that strength predates pressure and should be handled through human retinue/Stronghold review, not by making enemy pressure harsher.

The correct v0.7.1 decision is to keep pressure scope, timings, and the next-wave timing nudge unchanged while improving warning readability, status salience, report clarity, and human-review guidance.
