# v0.436 H1 Combat Positioning and Building Occupancy

## Scope

H1 repairs only combat approach positioning and building occupancy in the isolated
playtest-3 remediation worktree. It does not add combat systems, balance, units,
resources, saves, stable IDs, or new player actions.

## Root cause

The previous unit attack state repeatedly targeted a building center on a flat
navigation surface. Buildings were not represented as navigation exclusions, so
units could enter footprints and orbit around targets without a stable attack
position. Unit collision was also intentionally non-physical, so collision alone
could not solve the player-visible failure.

## Repair

- Added deterministic building-footprint route detours in `GameWorld`.
- Added attack-position anchors outside building footprints.
- Added attack settle/resume hysteresis so melee units stop at a stable reach
  distance instead of constantly re-requesting the target center.
- Preserved the existing unit-vs-unit melee reach contract and all public command
  semantics.
- Added typed locals to the retained R1H capture harness so the certified Godot
  parser can load its dependent R1I/R1J/R1K harnesses.

## Validation

Certified Godot 4.6.3 focused navigation and combat contract validators pass:

- `npm run godot:test:v0436-r1-navigation-repair`
- `npm run godot:test:v0436-r1-navigation-behavioral-proof`
- `npm run godot:test:v0436-r1i-combat-causality`
- `npm run godot:test:v0436-r1j-complete-combat-attribution`
- `npm run godot:test:v0436-r1k-controlled-combat-matrix`

The fresh headed H1 rehearsal was launched with the certified executable and
produced real PNG frames under:

`D:/CodexData/worktrees/ascendant-realms-playtest3-remediation-h/artifacts/manual-review/v0436-r1h-natural-player-assault-viability/`

The rehearsal remains truthfully classified as a blocker: the prepared mixed
force can still be eliminated in the first Easy wave before stable assault
resolution. No success-only frame is being relabeled as a pass.

## Safety

The change is isolated to this H worktree. No push, PR mutation, merge,
promotion, protected-checkout mutation, R1K retry, or v0.437 work occurred.
