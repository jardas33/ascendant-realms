# v0.12.1 Tuning Decision

Date: 2026-05-17

Scope: Phase 5 evidence-based tuning check for the v0.12.1 Human-Paced Core Feel Playtest Review.

## Decision

No numeric tuning was made because the playtest issues were readability/friction rather than balance failures.

## Evidence Observed

- Human-paced review found clear small copy/friction issues:
  - Cinderfen map names were inconsistent across campaign route names, skirmish setup, battle status, and results.
  - Cinder Shrine objective copy was accurate but too internal/mechanic-like for a small objective tracker.
  - Skirmish defeat guidance suggested campaign-only camp/Chapel support.
- Human-paced review did not isolate movement speed, cooldowns, wave timing, unit stats, reward amounts, retinue strength, or enemy pressure timing as a safe immediate tuning target.
- `npm run playtest:sim` passed after the copy changes and simulated 255 runs across 85 campaign battle nodes.

## Changes Made Instead Of Tuning

- Player-facing map display names now align with the route names `Cinderfen Crossing` and `Cinderfen Watch`; map ids and mechanics are unchanged.
- Cinder Shrine objective copy now says to claim the shrine for a one-time +20 Aether surge, then hold it.
- Skirmish defeat guidance now uses `Hold after each wave`; campaign defeats still keep camp/Chapel preparation guidance.

## Risk

- Low balance risk: no numbers changed.
- Low-medium copy/test risk: exact copy was updated in unit, smoke, layout, and visual QA coverage.
- Remaining human-review watchpoints from v0.12 still stand: retinue + Training Yard II, Greedy Economy timeouts, Fast Army quick clears, and pressure readability under real play stress.

## Next Tuning Gate

Only consider numeric tuning after a longer human playtest shows a repeated unfairness pattern, such as unavoidable early defeats, confusing wave timing despite clear warnings, or a dominant strategy that trivializes the current slice.
