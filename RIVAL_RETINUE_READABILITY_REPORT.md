# Rival / Retinue Readability Report

Date: 2026-05-03

## Scope

This is an automated readability review for Unit Veterancy V1, Retinue Camp V1, Rival / Nemesis Persistence V1, and Rival Rewards and Trophies V1. It uses existing view models, unit tests, Playwright flows, telemetry reports, and non-visual text assertions to reduce the need for immediate manual playtesting.

No gameplay, balance, map, faction, worker, enemy-construction, or diplomacy changes were made for this review.

## Evidence Sources

- `LLM_GAME_HANDOFF.md`: current v0.2.1 baseline candidate and known readability risks.
- `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json`: no structural too-hard or too-easy nodes; retinue and rival systems remain useful but not mandatory in deterministic coverage.
- `QA_RUN.md`: current automated QA status and remaining human-only review areas.
- `BALANCE.md`: current balance posture for retinue, veterancy, enemy heroes, rivals, and trophies.
- View-model/unit coverage in `src/game/campaign/CampaignMapViewModel.test.ts`, `src/game/results/ResultsViewModel.test.ts`, `src/game/core/RetinueRules.test.ts`, `src/game/core/RivalRules.test.ts`, and `src/game/core/unitVeterancy.test.ts`.
- Browser-flow coverage in `tests/e2e/deep-flow.spec.ts`.

## Automated Verdict

Automated readability surrogate: Pass with caveats.

The text/view-model surface now covers the largest player-confusion risks:

- Retinue capacity, active units, death/removal, recruitment eligibility, Training Yard II bonus, and deployed-unit identity.
- Veterancy rank, XP progress, kills, rank bonuses, notable veterans, and rank-up feedback.
- Rival commander preview, known rival intel, battle-start commander/rival copy, Results outcomes, one-time rewards, duplicate prevention, and trophies.
- Rival defeat/readiness flow through Results copy and retry/prep actions.

Remaining caveat: automated text checks cannot fully judge visual salience, emotional satisfaction, moment-to-moment stress, or whether mixed-retinue Ashen Outpost feels too clean in human play.

## Retinue Readability

| Question | Automated read | Evidence |
| --- | --- | --- |
| Is capacity visible? | Pass | Retinue Camp and Results recruitment panels show active capacity, base capacity, and current slots. |
| Are active retinue units visible? | Pass | Retinue Camp lists unit type, rank, XP, kills, and dismiss action. |
| Is permanent death/removal explained? | Pass | Retinue Camp and Results retinue copy explain permanent V1 removal. |
| Are eligible and ineligible veterans explained? | Pass | Results recruitment view shows eligible candidates and disabled reasons such as capacity full or not eligible. |
| Is Training Yard II capacity bonus visible? | Pass | Retinue Camp and Results recruitment copy show the +1 Training Yard II bonus when active. |
| Are deployed retinue units identifiable in battle? | Pass | Selected-unit panel labels deployed retinue veterans separately from normal battle units. |

## Veterancy Readability

| Question | Automated read | Evidence |
| --- | --- | --- |
| Does selected-unit panel show rank, XP, kills, and bonuses? | Pass | Selected-unit panel assertions cover rank, XP-to-next-rank, kills, and bonus text. |
| Does Results screen show notable veterans clearly? | Pass | Results view-model and e2e coverage assert Notable Veterans, rank-ups, records, and retinue candidates. |
| Does rank-up feedback appear? | Pass | Playwright now asserts battle status feedback when a selected unit is promoted to Veteran by test hook. |

## Rival Readability

| Question | Automated read | Evidence |
| --- | --- | --- |
| Does campaign map show known rivals? | Pass | Rival Intel panel coverage checks known rival state, encounters, outcomes, modifiers, rewards, and trophies. |
| Does selected node preview show enemy commander? | Pass | View-model coverage now checks first-encounter and known-rival commander previews, name/title, abilities, and current rival status. |
| Does battle-start copy mention commander/rival where relevant? | Pass | Playwright now asserts the Aether Well battle-start status mentions Veyra by name/title and her rival warning. |
| Does Results screen show rival outcome? | Pass | Results view-model coverage checks defeated, escaped/known, repeated-defeat, and triumphant outcome copy. |
| Are one-time rewards/trophies explained? | Pass | Results and Rival Intel coverage assert first-defeat reward and trophy messaging. |
| Are repeat rewards blocked and explained? | Pass | New Results view-model coverage asserts repeat rival defeats show the one-time reward as already claimed. |

## Trophy Readability

| Question | Automated read | Evidence |
| --- | --- | --- |
| Are earned trophies shown? | Pass | Rival Intel and Results tests assert earned trophy labels and descriptions. |
| Are trophy effects/copy understandable? | Pass | Rival Intel coverage asserts trophy effect copy such as first-defeat resource notes. |
| Are first-defeat rewards clearly one-time? | Pass | Rival Intel and Results coverage asserts claimed/unclaimed state and duplicate prevention messaging. |

## Defeat / Readiness Clarity

| Question | Automated read | Evidence |
| --- | --- | --- |
| If player loses to a rival, does Results explain what happened? | Pass | New Results view-model coverage checks Captain Malrec triumphant/emboldened defeat copy and future +5% damage warning. |
| Is retry/prep flow clear? | Pass | New Results view-model coverage asserts Retry, Open Hero Inventory, and Campaign Map actions remain available. |

## Checks Added In This Pass

- Added first-encounter enemy commander preview coverage for Gorak Emberhand on Bandit Hillfort.
- Expanded known-rival campaign map coverage for commander name/title, ability preview, trophy explanation, and first-defeat reward copy.
- Expanded Results coverage for persisted rival state after first defeat.
- Added repeat rival defeat coverage proving first-defeat rewards are not duplicated and the UI explains that they were already claimed.
- Added rival-triumph defeat coverage proving the Results screen explains the loss, disposition, future modifier, and retry/prep actions.
- Expanded e2e veterancy flow to assert battle-status rank-up feedback.
- Expanded e2e rival flow to assert battle-start commander name/title copy before the existing rival warning.

## Remaining Human-Style Review Areas

- Mixed-retinue Ashen Outpost can sweep in deterministic profiles and remains marked for human review in telemetry, though it is not structurally too easy.
- Manual play can still judge whether retinue identity feels satisfying enough during live combat beyond selected-panel text.
- Manual play can still judge whether rival commander/trophy copy has enough visual weight without feeling noisy.
- The live rival-defeat combat path is covered through view-model and Results-state assertions rather than a long brittle e2e battle-loss reproduction.

## Recommendation

Do not change balance from this readability review alone. The automated checks show the main text and view-model states are readable enough for v0.2.1 baseline work, while `PLAYTEST_TELEMETRY.md` still correctly keeps mixed-retinue Ashen Outpost and human-style readability under review before v0.3 planning.
