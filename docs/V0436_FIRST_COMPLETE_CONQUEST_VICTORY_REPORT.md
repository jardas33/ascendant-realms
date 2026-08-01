# v0.436 First Complete Conquest Victory — Blocked Closeout

Status: `BLOCKED_PREEXISTING_NAVIGATION_SYSTEM`

## Scope

v0.436 implemented the first complete conquest result contract: real building damage and one-time destruction cleanup, the conquest rebuild-capability predicate, an atomic game-over freeze, one profile/game-over record, a structured Victory/Defeat result, result HUD wiring, and a fresh Play Again path. The headed capture was required to prove that the existing production movement, combat, destruction, victory, freeze, and replay paths work together.

No v0.437 work was started.

## Base and branch

- Accepted base: `642fcb67bf38f1ca76874b33bfb8dd254ee6eeff` (v0.435-R1)
- Branch: `codex/v0436-first-complete-conquest-victory`

## Implemented and retained

- Building damage provenance and one-time destruction cleanup.
- Conquest defeat predicate: no live completed HQ, no live rebuilding workers, and no live buildings.
- Atomic `match_ended` / `game_running` freeze and single result/profile recording.
- Structured result snapshot with reason, kills, building kills, XP, time, and defeated teams.
- Victory/Defeat HUD result, Continue, Play Again, and `Match.clear_result()` wiring.
- Shared MapDefs-sourced playable bounds contract.
- Bounded invalid-path repath, safe stop after three consecutive invalid path results, avoidance-velocity rejection, and normal-speed nearest-boundary recovery for already-outside units.
- Live-unit position watchdog and structured navigation audits.

## Capture truth

Three repaired headed attempts were run after the navigation-containment repair:

1. Attempt 1 failed during War Hall construction because the initial containment sanity threshold rejected a legitimate initial navigation point.
2. Attempt 2 retained bounded containment but still failed setup; workers remained inside the field in BUILDING state with no progress.
3. Attempt 3 completed the real War Hall build, four real Standard-resource Crag Archer queue transactions, and four real trained archers, then timed out before the conquest assault resolved.

The containment repair prevented the former catastrophic out-of-bounds drift. It did not produce a genuine Victory result. No Victory review pack is accepted, and stale Victory-looking files in this working directory are not evidence for v0.436.

Failure records:

- `artifacts/manual-review/v0436-first-complete-conquest-victory/v0436-capture-failure-audit-attempt-01.json`
- `artifacts/manual-review/v0436-first-complete-conquest-victory/v0436-capture-failure-audit-attempt-02.json`
- `artifacts/manual-review/v0436-first-complete-conquest-victory/v0436-capture-failure-audit-attempt-03.json`
- `artifacts/manual-review/v0436-first-complete-conquest-victory/v0436-navigation-boundary-contract.json`
- `artifacts/manual-review/v0436-first-complete-conquest-victory/v0436-invalid-next-point-audit.json`
- `artifacts/manual-review/v0436-first-complete-conquest-victory/v0436-unit-position-watchdog.json`

## Root cause

The production `NavigationAgent3D` / avoidance path can return unusable or stalled path results for legitimate headed commands. Before the repair, units could drift hundreds of metres outside the ±140 battlefield. After the repair, invalid output is rejected, units stop safely or recover toward the nearest in-bounds point, and the watchdog records the event; however, the same navigation system still prevents the full assault from resolving within the allowed three attempts.

## Validation evidence

Green before the blocked headed attempts:

- `npm run godot:test:v0436-conquest-victory`
- `npm run godot:smoke:v0436-conquest-victory`

The capture command was run three times and failed closed; therefore no claim is made for a completed Victory, freeze, or Play Again review capture. The accepted v0.435 runtime and all prior gameplay semantics remain preserved. No AI difficulty, costs, HP, armor, damage, movement speed, projectile speed, economy, resource values, or true-default behavior were changed.

## Blocked exit

## R1/R1A/R1B/R1C supersession history — 2026-07-30

R1 repaired the production navigation lifecycle, R1A proved the focused navigation behaviors, and R1B added and passed the isolated real-`Unit` boundary-recovery proof. R1C then added an isolated evidence-integrity capture/validator path for the still-open natural conquest -> result -> Continue/Play Again requirement. The first authorized R1C headed session was blocked before the production scene rendered because the installed Godot 4.3 executable crashed with Windows signal 11 during headed startup. The R1C report records the exact command and preserves the fail-closed state. No Victory-looking historical frames are promoted, and P0-RESULT-001 remains open.

`BLOCKED_PREEXISTING_NAVIGATION_SYSTEM`

The safe next repair is a separately scoped navigation-system repair with focused tests for bounded repath, safe stop, avoidance velocity, and recovery, followed by a new bounded headed capture budget. Do not treat the stale Victory-looking images as v0.436 proof and do not begin v0.437 until the navigation defect is repaired or explicitly re-scoped.
