# v0.12.3 Human Campaign Play Session Notes

Date: 2026-05-17

Scope: Phase 2 human-style campaign balance notes for v0.12.3. This pass reviews the current green campaign slice through direct browser/player-facing evidence plus the existing deterministic telemetry route spread. It does not tune while taking notes.

## Evidence Sources

- Phase 0 baseline: `main` clean and synced at `f8fa346`.
- Direct visible browser pass on local dev server at `http://127.0.0.1:5174/`:
  - Main menu booted with `Prototype v0.3` / `Cinderfen Route Baseline`.
  - New Campaign opened hero creation.
  - Begin Campaign opened Campaign Map.
  - Campaign Map showed `Start Here`, Border Village guidance, Stronghold context, Retinue Camp context, locked-node state, and `Start Battle`.
  - Border Village launched to battle HUD with resources, hero panel, Current Orders, minimap shell, and battle status.
- Existing browser evidence harness coverage:
  - `visual:qa` captures Cinderfen Crossing launch, shrine capture, Crossing pressure warning, Crossing victory results, Cinderfen Watch launch, Watch pressure warning, and defeat results.
  - Smoke/e2e paths exercise campaign return, Cinderfen Crossing completion, Cinderfen Watch completion, Skirmish setup, and Broken Ford launch.
- Structural route evidence from `PLAYTEST_TELEMETRY.json` and `PLAYTEST_TELEMETRY.md`.
- Prior slow-play context from `docs/V0121_HUMAN_PACED_PLAYTEST_REPORT.md`.

## Border Village

Subjective difficulty:

- Easy and appropriate for an opening battle.
- Direct browser pass showed clear first-action context before launch: `Start Here` and Border Village copy describe capture, Barracks, training, defending the first wave, and destroying the enemy Stronghold.

Army losses:

- Telemetry baseline: Safe Beginner averages 0.6 losses and wins 12/12.
- Fast Army averages 1.3 losses but clears very quickly.

Hero danger:

- No current hero-danger signal. Telemetry still lacks final hero HP/death as a separate metric, so this remains a human-observation caveat.

Resource pressure:

- No concerning shortage. Safe and Greedy routes both complete Barracks before contact in 12/12 runs.

Objective clarity:

- Campaign pre-battle guidance is clear.
- The remaining v0.12.1 note still stands: First Claim relies more on launch/status guidance than the richer objective tracker used by Ashen/Cinderfen. That is a readability polish item, not a balance problem.

Pressure-warning noticeability:

- Not applicable; Border Village has no Cinderfen pressure plan.

Victory / defeat feel:

- Victory should feel like a tutorialized first loop.
- There is no structural defeat evidence: 36 wins / 0 defeats / 0 timeouts.

Issue type:

- No balance issue. Minor objective-presentation polish can be deferred.

## Ashen Outpost

Subjective difficulty:

- Fair milestone when the player follows objective order and produces an army.
- It is the first major place where slow/greedy play can become pacing pressure rather than raw survival pressure.

Army losses:

- Baseline Safe Beginner: 12 wins / 0 defeats / 0 timeouts, 0.0 average losses.
- No-retinue profile: 1 win / 0 defeats / 2 timeouts, 5.3 average losses.
- Retinue + Training Yard II: 3 wins / 0 defeats / 0 timeouts, 0.0 average losses, final army 15.0.
- Greedy Economy: 3 wins / 0 defeats / 9 timeouts, 5.3 average losses.
- Fast Army: 7 wins / 0 defeats / 5 timeouts, 3.6 average losses.

Hero danger:

- Captain Malrec remains readable as a milestone threat in objectives/results, but hero-specific survival is not measured independently in telemetry.
- No direct v0.12.3 evidence shows unavoidable hero danger.

Resource pressure:

- Greedy and no-retinue failures tend to have high peak crowns, so the issue is not raw resource starvation.
- The player-facing risk is converting resources into a decisive final push before time/attrition catches up.

Objective clarity:

- v0.12.1 found the objective tracker strong: `Next` points at Burned Shrine, shrine payoff is clear, and Captain Malrec guidance tells the player to secure shrine/Barracks before using hero abilities.

Pressure-warning noticeability:

- Not applicable to Cinderfen pressure warnings. Ashen is a fortress/milestone read.

Victory / defeat feel:

- Safe wins feel earned through objective sequencing.
- No-retinue and Greedy timeouts feel like overcaution or poor conversion, not unfair immediate defeats.
- Retinue + Training Yard II can make Ashen very clean, but that currently reads as earned power.

Issue type:

- Balance watchpoint for retinue strength and greedy conversion. No tuning target isolated.

## Cinderfen Crossing

Subjective difficulty:

- Fair when played with baseline/cautious assumptions.
- Cinder Shrine objective and pressure messaging are central to whether the battle feels readable.

Army losses:

- Baseline Safe Beginner: 13 wins / 0 defeats / 0 timeouts, 0.5 average losses.
- No-retinue: 2 wins / 0 defeats / 1 timeout, 2.3 average losses.
- Mixed Veterans: 2 wins / 0 defeats / 1 timeout, 1.7 average losses.
- Retinue + Training Yard II: 3 wins / 0 defeats / 0 timeouts, 0.0 average losses.
- Greedy Economy: 1 win / 0 defeats / 12 timeouts, 4.6 average losses.
- Fast Army: 12 wins / 0 defeats / 1 timeout, 0.9 average losses, average duration 2:40.

Hero danger:

- No separate HP/death signal. Direct visual evidence should continue to watch whether the hero is endangered during shrine/road pressure.

Resource pressure:

- Greedy Economy floats very high resources, averaging 4749 peak crowns, while timing out. That is a conversion/readability issue, not resource underpowering.
- Fast Army has low peak crowns and wins by decisive tempo rather than economy.

Objective clarity:

- v0.12.1 copy now says to claim the shrine for a one-time +20 Aether surge, then hold it.
- The visual QA harness directly captures Cinderfen Crossing launch, shrine capture, pressure warning, and victory results, so the player-facing surfaces are part of the active review lane.

Pressure-warning noticeability:

- Structural evidence: Safe and Greedy trigger pressure every Crossing run.
- Visual evidence: the pressure warning is capturable in the battle status during the Crossing review path.
- Human-stress risk remains: a player commanding units may still miss it during combat, but current evidence does not show unfair timing.

Victory / defeat feel:

- Baseline victory feels earned through shrine/side-income/pressure response.
- Fast Army victory is fast enough to be a watchpoint, but it can bypass wave development rather than proving the map is trivial.
- Greedy failures feel like slow conversion rather than unfair punishment.

Issue type:

- Fast Army and Retinue + Training Yard II are watchpoints.
- Greedy Economy is clarity/conversion risk.
- No current numeric tuning target.

## Cinderfen Watch

Subjective difficulty:

- Fair under baseline play and useful as the second pressure-read map.
- Watch Road and fog/tower context remain the key readability beats.

Army losses:

- Baseline Safe Beginner: 12 wins / 0 defeats / 0 timeouts, 0.8 average losses.
- No-retinue: 2 wins / 0 defeats / 1 timeout, 2.7 average losses.
- Mixed Veterans: 3 wins / 0 defeats / 0 timeouts, 0.0 average losses.
- Retinue + Training Yard II: 3 wins / 0 defeats / 0 timeouts, 0.0 average losses.
- Greedy Economy: 3 wins / 0 defeats / 9 timeouts, 4.5 average losses.
- Fast Army: 10 wins / 0 defeats / 2 timeouts, 1.1 average losses.

Hero danger:

- No current standalone hero danger measurement.
- Tower/fog salience remains visual debt, not a proven tuning problem.

Resource pressure:

- Greedy Economy again floats resources and times out.
- Baseline and Fast Army have enough resources when they turn them into pressure.

Objective clarity:

- v0.12.1 found Watch Road objective copy readable: capture the road, scout fog around the tower, then handle Brute/tower pressure.
- Visual QA directly captures Cinderfen Watch launch and pressure warning.

Pressure-warning noticeability:

- Watch pressure triggers in every Safe, Greedy, and Fast Army Watch run.
- Safe Beginner wins 12/12 through the warnings.
- Visual evidence confirms the warning can be shown in the status surface; human attention under combat remains the watch item.

Victory / defeat feel:

- Baseline victory feels earned.
- Retinue + Training Yard II and Mixed Veterans can make Watch very clean.
- Greedy timeouts feel like delayed conversion.

Issue type:

- No change. Watch remains a useful future human-stress warning test.

## Campaign Return Flow After Victory / Defeat

Subjective difficulty:

- Results and campaign return are readable enough for current balance judgment.
- v0.12.1 found `Strengthen Your Hero` helpful after victory.

Army losses:

- Result screens expose objective/reward and veteran information; exact density remains high.

Hero danger:

- Results communicate victory/defeat outcome but do not solve the telemetry gap around final hero HP.

Resource pressure:

- Campaign return shows bank/resources and next route context.
- Greedy Economy risk may still need human testers to verbalize whether they understood resource-to-army conversion after timeouts.

Objective clarity:

- Victory/defeat guidance is practical after v0.12/v0.12.1.
- Skirmish defeat no longer points to campaign-only support.

Pressure-warning noticeability:

- Defeat results can explain pressure failure after the fact, but the key test remains whether the warning is noticed during combat.

Victory / defeat feel:

- Victory feels earned for baseline routes.
- Defeat guidance is contextual enough for now.

Issue type:

- Results density and visual presentation are UI/visual debt, not v0.12.3 tuning.

## Route Notes

Baseline cautious:

- Subjective difficulty: fair.
- Evidence: Safe Beginner wins every reviewed node, including all Cinderfen pressure runs.
- Verdict: no change.

No-retinue:

- Subjective difficulty: fair but slower/higher attrition.
- Evidence: Ashen and Cinderfen can time out, but no immediate defeat pattern appears.
- Verdict: no change; keep no-retinue as an important future human run.

One-veteran:

- Subjective difficulty: helpful but not automatic.
- Evidence: one Veteran Militia improves Ashen and Cinderfen modestly; one Veteran Ranger has a rougher Crossing read and does not prove overpowered.
- Verdict: no change.

Mixed-veterans:

- Subjective difficulty: strong experienced-player route.
- Evidence: clean Ashen and Watch clears, but Crossing still has a timeout in the profile.
- Verdict: no change, watch for mandatory-feeling power.

Retinue + Training Yard II:

- Subjective difficulty: strongest and very clean.
- Evidence: wins reviewed Ashen/Cinderfen rows with 0 average losses and 0 losses after Cinderfen pressure.
- Verdict: still reads as earned power; no tuning unless repeated direct human play shows objective/production/pressure trivialization.

Greedy Economy:

- Subjective difficulty: risky, slow, and likely to time out.
- Evidence: survives first waves, completes Barracks, floats high resources, and times out.
- Verdict: no change; if human players cannot diagnose the timeout, consider copy later.

Fast Army:

- Subjective difficulty: decisive and quick.
- Evidence: Crossing is especially fast, Watch still triggers pressure, and Ashen has timeouts.
- Verdict: no change; speed is a legitimate profile, not current trivialization.

## Current Issue Classification

- Balance: no proven current issue.
- Clarity: Greedy Economy conversion may need future human tester feedback.
- Visual debt: pressure-warning noticeability under combat, tower/fog/shrine salience, minimap icon language, and results density.
- Deferred systems: broad AI/economy, pressure-action expansion, reinforcement behavior, reward redesign, new content, save changes.
