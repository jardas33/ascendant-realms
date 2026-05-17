# v0.12.2 Tuning Decision

Date: 2026-05-17

Scope: Phase 4 tuning-vs-no-tuning decision for the v0.12.2 Human Balance Watchpoint Review. This decision uses `docs/V0122_BALANCE_WATCHPOINT_PROTOCOL.md`, `docs/V0122_SIMULATOR_BALANCE_REVIEW.md`, and `docs/V0122_HUMAN_BALANCE_NOTES.md`.

## Decision Summary

No numeric tuning was made.

No copy/readability change was made in v0.12.2 because the current evidence supports the existing v0.12/v0.12.1 readability changes and does not isolate a new harmful wording issue.

The correct v0.12.2 action is to document the balance read, keep Retinue + Training Yard II and Greedy/Fast strategy spread as watchpoints, and defer broader tuning until repeated human play shows a specific unfairness pattern.

## Retinue + Training Yard II

Decision: no change.

Evidence:

- Full-profile telemetry: 17 wins / 3 defeats / 1 timeout across 21 Retinue + Training Yard II runs.
- Cinderfen telemetry: 6 wins / 0 defeats / 0 timeouts, average duration 3:57, average losses 0.0, average final army 13.0, 0 losses after pressure.
- Ashen Outpost node review: 3 wins / 0 defeats / 0 timeouts, average duration 4:09, average losses 0.0, average final army 15.0.
- The analyzer reports no structural `too_easy` nodes and no Stronghold warnings.

Player-facing read:

- This profile is clearly strong. It makes earned veterans feel powerful and stabilizes Cinderfen/Ashen fights.
- It is not yet proven too strong because the full profile still has defeats/timeouts, and the strength is tied to earned campaign progression rather than free default power.

Why no tuning now:

- A nerf would flatten a satisfying long-term reward without enough human evidence that it trivializes the intended route.
- No smaller isolated number is clearly responsible: retinue capacity, veterancy, Training Yard II timing, enemy stats, and map pressure all interact.

Risk:

- If future human play shows Training Yard II makes Cinderfen and Ashen automatic with little production or objective respect, this becomes the first numeric tuning candidate.

Next evidence needed:

- Human play with no retinue, one veteran, mixed veterans, and Retinue + Training Yard II on Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch.

## Greedy Economy

Decision: no change.

Evidence:

- Full script telemetry: 31 wins / 11 defeats / 43 timeouts across 85 Greedy Economy runs.
- Greedy Economy survives first wave and completes Barracks before contact in 85/85 runs.
- Cinderfen Crossing: 1 win / 0 defeats / 12 timeouts, average peak crowns 4749.
- Cinderfen Watch: 3 wins / 0 defeats / 9 timeouts, average peak crowns 3872.
- Ashen Outpost: 3 wins / 0 defeats / 9 timeouts, average peak crowns 4159.

Player-facing read:

- Greedy Economy is risky by design. It is not being killed before counterplay exists.
- The repeated pattern is resource float plus timeout, which means the strategy fails to convert economy into army pressure quickly enough.

Why no tuning now:

- Resource buffs would reward the wrong failure mode because the script already floats large crowns.
- Pressure nerfs would make Safe Beginner and Fast Army less interesting without solving Greedy conversion.
- Existing v0.12/v0.12.1 result and objective guidance already points toward production, side income, shrine, and push sequencing.

Risk:

- Human players may still read a timeout as unfair if results do not make the conversion problem obvious.

Next evidence needed:

- Human Greedy Economy attempts where the player explains whether the loss felt like unclear guidance, too little time, or accepted strategic risk.

## Fast Army

Decision: no change.

Evidence:

- Full script telemetry: 53 wins / 24 defeats / 8 timeouts across 85 Fast Army runs.
- Cinderfen Crossing: 12 wins / 0 defeats / 1 timeout, average duration 2:40.
- Cinderfen Watch: 10 wins / 0 defeats / 2 timeouts, pressure triggers in 12/12 runs, with 20 warnings and 13 losses after pressure.
- Border Village: 12 wins / 0 defeats / 0 timeouts, average duration 1:49, appropriate for an opening battle.

Player-facing read:

- Fast Army is a real speed profile. It can clear quickly and sometimes avoids normal wave development.
- It is not a free dominant profile across the full suite because it has defeats, timeouts, and first-wave non-survival in harder contexts.

Why no tuning now:

- Slowing Fast Army globally would punish a legitimate aggressive style.
- Repeat-clear economy has already been constrained in earlier Cinderfen work, so fast repeat farming is not currently the main risk.

Risk:

- If future player evidence shows Fast Army skips map identity every time while keeping low losses and meaningful rewards, reward/timing review may be needed.

Next evidence needed:

- Human Cinderfen Crossing/Watch speed clears with notes on losses, objective skips, pressure visibility, and reward value.

## Early Defeats

Decision: no change.

Evidence:

- Border Village: 36 wins / 0 defeats / 0 timeouts.
- Old Stone Road: 36 wins / 0 defeats / 0 timeouts in the current telemetry report.
- Ashen Outpost: 22 wins / 0 defeats / 14 timeouts; Safe Beginner wins 12/12.
- Full Safe Beginner script: 85 wins / 0 defeats / 0 timeouts.

Player-facing read:

- The suite does not show unavoidable early defeat.
- Early failure risk is more likely guidance, overextension, or milestone push timing than bad enemy numbers.

Why no tuning now:

- Difficulty reduction would soften successful baseline play and could make Fast Army/retinue profiles too easy.

Risk:

- A human player who ignores build/training/objective guidance may still lose without understanding why, especially outside the deterministic script.

Next evidence needed:

- Direct human defeat notes that identify whether the player missed a prompt, lacked resources, got surprised by a wave, or understood the risk and accepted it.

## Pressure Fairness

Decision: no change.

Evidence:

- Analyzer reports no enemy-pressure warnings.
- Pressure-enabled Cinderfen runs: 75; triggered pressure runs: 63; warnings shown: 149; simulated reinforcement applications: 0.
- Cinderfen Crossing Safe Beginner: 13 wins / 0 defeats / 0 timeouts while triggering pressure in 13/13 runs.
- Cinderfen Watch Safe Beginner: 12 wins / 0 defeats / 0 timeouts while triggering pressure in 12/12 runs.
- Greedy Economy pressure failures are timeouts with high resource float, not sudden defeats.

Player-facing read:

- Pressure warnings are structurally fair and actionable. Safe play can win through them.
- Remaining concern is noticeability/readability under human attention, not numeric timing.

Why no tuning now:

- Widening pressure windows or reducing pressure would make safe play safer without proving that current warnings are unfair.
- Adding stronger pressure actions would violate the v0.12.2 scope and belongs to a later systems pass.

Risk:

- Human players may miss warnings during dense combat because current visuals remain prototype-level.

Next evidence needed:

- Human Cinderfen review focused on whether the warning is noticed, whether the suggested response is clear, and whether the player has time to act.

## Deferred Items

- Defer any retinue capacity, veterancy, or Training Yard II numeric changes until repeated human play shows this profile trivializes objectives, production, and pressure.
- Defer any Greedy Economy timeout relief until human evidence separates unclear guidance from accepted risky strategy.
- Defer any Fast Army slowdown until speed clears prove low-loss and reward-distorting across repeated play.
- Defer broader AI/economy, live reinforcement, route contest, defensive hold, enemy construction, workers, new maps, new units, new factions, save migrations, and visual overhaul work to future explicit goals.

## Tests

No tests were added or updated because no runtime behavior, copy, data constants, pressure timing, simulator logic, or tuning constants changed.

