# v0.7.2 Pressure Play Review Plan

Date: 2026-05-09

Status: Phase 1 review protocol. This plan defines how v0.7.2 will judge human-perceived Cinderfen pressure feel without adding mechanics, rewards, save changes, maps, units, factions, workers, construction, enemy economy, live reinforcements, capture-site contest AI, defensive hold behavior, or broad systems.

## 1. Review Goal

Judge whether Enemy Strategic Pressure V1 is noticed, understood, and perceived as fair during play-like Cinderfen battles.

The goal is human-perceived feel, not simulator-only balance. The simulator already says the current pressure is structurally safe: Cinderfen Crossing and Cinderfen Watch have no pressure-caused defeats, no enemy-pressure analyzer warnings, no structural too-hard flags, and no structural too-easy flags. v0.7.2 should answer the softer questions the simulator cannot prove:

- Does the warning line catch attention during normal battle motion?
- Does the warning make the player understand what changed?
- Does the player know what to do next?
- Does pressure improve Cinderfen identity without feeling like hidden spawning?
- Do the strongest and fastest profiles make pressure irrelevant in a way that is acceptable?

## 2. Review Targets

Primary targets:

- `cinderfen_crossing` / `cinderfen_causeway`
- `cinderfen_watch` / `cinderfen_watchpost`

Explicit exclusions:

- Ashen Outpost remains pressure-free.
- Chapter 1 remains pressure-free.
- Tutorial / Proving Grounds remains pressure-free.
- Skirmish remains pressure-free.

## 3. Review Profiles

Use four review profiles as lenses rather than new gameplay modes.

| Profile | Purpose | Current Automated Read |
| --- | --- | --- |
| Safe Beginner style | Checks whether a normal stabilizing player can notice pressure while capturing income and building an army. | Crossing 13/13 wins; Watch 12/12 wins. |
| Greedy Economy style | Checks whether delayed aggression plus pressure warnings makes timeout causes clearer. | Crossing 1/13 wins and 12 timeouts; Watch 3/12 wins and 9 timeouts. |
| Fast Army style | Checks whether quick clears bypass pressure in a satisfying strategy-expression way. | Crossing pressure triggers only 1/13; Watch pressure triggers 12/12 while still mostly winning. |
| Retinue + Training Yard II style | Checks whether saved veterans plus Training Yard II make pressure meaningless. | 6/6 wins across Crossing and Watch with 0 losses after pressure. |

The profiles are review perspectives. v0.7.2 should not create new profiles, new campaign states, or new mechanics unless a test-only harness note is needed for review access.

## 4. Review Questions

For each pressure-enabled battle, answer:

1. Was the pressure warning noticed?
2. Did it appear too early?
3. Did it appear too late?
4. Did the player understand what changed?
5. Did the warning suggest a practical response?
6. Did pressure feel like commander intent rather than hidden spawning?
7. Did the status line remain readable without a new panel?

Crossing-specific questions:

- Did Cinder Shrine pressure feel meaningful?
- Did `Cinder Shrine Surge` remain readable when pressure also fired?
- Did the warning make "hold the route before pushing" clear?
- Did Fast Army bypass feel acceptable rather than broken?

Watch-specific questions:

- Did Watch Road pressure feel fair?
- Did the first warning arrive before combat focus became too heavy?
- Did very early triggers feel like punishment for following the correct route?
- Did the raised-road warning make the next-wave timing nudge understandable?

Strategy-specific questions:

- Did Greedy Economy timeouts feel understandable?
- Did pressure warnings help explain why the player needed to move sooner?
- Did Retinue + Training Yard II trivialize pressure as acceptable power fantasy or as a balance smell?

## 5. Evidence Sources

Use multiple evidence sources, with human-play-like observation ranked above raw simulator counts for readability judgments.

Browser/play-like evidence:

- Launch Cinderfen Crossing from a seeded post-Ashen campaign state.
- Trigger or play toward Cinder Shrine pressure.
- Observe status-line text, timing, overlap with Cinder Shrine Surge, and HUD readability.
- Launch Cinderfen Watch from a seeded post-Crossing state.
- Trigger or play toward Watch Road pressure.
- Observe warning timing, road/tower readability, and whether pressure feels fair.

Automation evidence:

- Existing pressure e2e in `tests/e2e/enemy-pressure.spec.ts`.
- Existing Cinderfen route e2e helpers and smoke coverage.
- Existing pressure runtime stats: active plan id, triggered/completed stages, warning counts, first pressure time, and reinforcement-applied false.

Telemetry evidence:

- `PLAYTEST_TELEMETRY.md`
- `PLAYTEST_TELEMETRY.json`
- Strategy split for Safe Beginner, Greedy Economy, Fast Army, and Retinue + Training Yard II.
- Losses after pressure, triggered stages, first pressure times, warning counts, and analyzer warnings.

Feedback evidence:

- Battle status messages.
- Objective messages such as `Cinder Shrine Surge`.
- Results and defeat tips when pressure contributes to a loss.

## 6. Phase Method

Phase 2 should document exact browser review flows and confirm whether existing Playwright helpers can seed the required Cinderfen states.

Phase 3 should review Cinderfen Crossing first because it has the strongest shrine salience and Fast Army bypass question.

Phase 4 should review Cinderfen Watch second because it has the strongest early-trigger and Watch Road fairness question.

Phases 5-7 should only apply or justify tiny readability decisions:

- warning copy
- warning timing
- message duration
- defeat tip clarity
- telemetry wording
- no-change decisions

Phase 8 should decide whether stronger pressure actions remain blocked or future-only.

## 7. Non-Goals

v0.7.2 must not:

- Promote `reinforce_next_wave` into live reinforcement.
- Promote `contest_capture_site` into capture-site contest AI.
- Promote `defensive_hold` into live defensive behavior.
- Add workers or enemy workers.
- Add harvesting, build placement, real enemy construction, or enemy economy simulation.
- Add maps, units, factions, rewards, campaign progression, save fields, or save-version changes.
- Add pressure to Ashen Outpost, Chapter 1, Tutorial / Proving Grounds, or Skirmish.
- Add a new HUD panel, cinematic, icon set, art asset, or broad UI redesign.
- Add desktop packaging, engine switching, 2026 graphics, or external generated assets.

## 8. Change Threshold

Tiny polish is allowed only when evidence identifies a specific readability problem.

Safe examples:

- Shorten a warning that is too long to read in motion.
- Shift a warning a few seconds later if it fires before the player can understand the trigger.
- Shift a warning a few seconds earlier if it consistently arrives after the relevant decision.
- Clarify a defeat tip so Greedy Economy timeouts point toward army timing or route pressure.
- Improve telemetry/report labels when they are too technical.

No-change is the expected default when evidence is mixed. Pressure should stay subtle until a human review proves a concrete problem.

## 9. Completion Criteria

v0.7.2 is complete when:

- Cinderfen Crossing has a review document with evidence and a change/no-change decision.
- Cinderfen Watch has a review document with evidence and a change/no-change decision.
- Retinue + Training Yard II has a review document or section.
- Greedy Economy and Fast Army have a review document or section.
- Stronger pressure actions have a fresh decision gate.
- Final docs and `LLM_GAME_HANDOFF.md` explain completed phases, skipped phases, verification, risks, and the next recommended goal.
- Full final verification is green.
