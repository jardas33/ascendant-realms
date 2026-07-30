# v0.436-R1 Production Navigation System Repair

Status: implementation complete; bounded local proof is green. This is a navigation repair follow-up to v0.436, not v0.437.

## Scope and baseline

- Repository: `D:\Code for projects\WB game like\ascendant-realms-v0223-recovery`
- Branch: `codex/v0436-first-complete-conquest-victory`
- Base handoff HEAD: `73f01bdd76b35c1b7c43886d9fb48ffd9d936803`
- Previous v0.436 status: `BLOCKED_PREEXISTING_NAVIGATION_SYSTEM`
- Preserved: conquest/result semantics, balance, stable IDs, saves, resources, combat rules, true default runtime, and the existing v0.436 evidence backlog.

## Root-cause findings

The production world built the `NavigationMesh` polygons after assigning the resource to `NavigationRegion3D`. That made the live server region depend on a late resource mutation rather than a deterministic authored mesh assignment. There was also no explicit `NavigationServer3D` synchronization/readiness gate before agents were evaluated.

Unit targets were only clamped to rectangular playable bounds. They were not projected onto the active navigation map, so “inside bounds” did not prove “on the map.” The runtime also treated `NavigationAgent3D.is_navigation_finished()` as a repeated invalid-path event while the query was pending, and reissued target positions every physics frame from state handlers. Finally, three transient invalid/rejected callbacks called `command_stop()`, erasing legitimate build, gather, return, attack-move, and pursuit context.

The previous fixed 48-unit next-waypoint guard was also invalid for this production map: a flat region legitimately returns a direct long segment for a distant target. The v0.436 headed audit showed the resulting false `implausible_next_path_jump` rejection on attack movement.

## Repair implemented

1. The flat navigation polygons are authored before the mesh is assigned to the region.
2. `GameWorld.is_navigation_ready()` checks the live map RID, region list, and `map_get_iteration_id()`.
3. `navigation_target_snapshot()` records requested/bounded/projected target information and uses `map_get_closest_point_owner()` plus `map_get_closest_point()`.
4. Units defer agent targets until the active map is ready and avoid resetting an unchanged target every physics frame.
5. The path lifecycle distinguishes readiness/deferred target, pending path, genuine arrival, and invalid/non-finite/out-of-bounds next points.
6. Repaths use a 0.20-second cadence and a 2.5-second bounded retry budget.
7. Transient failures preserve the owning command. A single structured `navigation_terminal_failure` record is emitted before the deliberate terminal safe stop.
8. Avoidance remains enabled. Non-finite, excessive-speed, and genuinely out-of-bounds velocities remain rejected, but stale callbacks cannot restart an idle command.
9. The fixed long-waypoint rejection was removed; finite and in-bounds validation remains authoritative.

## Runtime evidence

The headed production capture reached the real player setup with the repaired path:

- `01_V0436_REAL_SKIRMISH_INITIAL_STATE.png` is a real rendered production frame.
- `02_V0436_PLAYER_WAR_HALL_BUILT.png` is a real rendered construction scene.
- `v0436-player-assault-setup-audit.json` records `hall_built: true` and four trained archers.
- `v0436-navigation-runtime-probe.json` records `ready: true`, one live region, map iteration `1`, and direct server paths of two correct endpoints for build, attack, gather, and return targets.

The probe is intentionally taken before the long conquest assault sequence, so it isolates navigation truth from the pre-existing conquest-capture blocker.

## What did not change

No new gameplay, states, actions, balance, economy, resources, combat resolution, conquest predicate, unit definitions, stable IDs, save format, or default-runtime behavior was added. The boundary recovery path remains the only direct physical recovery movement and remains bounded, normal-speed, and non-teleporting.

## Validation

Dedicated commands:

- `npm run godot:test:v0436-r1-navigation-repair`
- `npm run godot:smoke:v0436-r1-navigation-repair`
- `npm run godot:validate:v0436-r1-navigation-repair`

Retained checks run during this repair:

- `npm run godot:test:v0436-conquest-victory`
- `npm run godot:smoke:v0436-conquest-victory`
- `git diff --check`

The validator writes `artifacts/manual-review/v0436-first-complete-conquest-victory/v0436-r1-navigation-validation.json` and checks the headed runtime probe, synchronized map, projected targets, mesh assignment order, bounded retry contract, command-preservation contract, and removal of the false fixed-distance waypoint rejection.

## Remaining v0.436 boundary

The existing full conquest capture remains a separate v0.436 evidence gate. This R1 repair proves the navigation map and the first real construction/training path; it does not relabel the prior failed conquest attempts as a victory. Any final v0.436 conquest closeout still requires a fresh headed run that produces genuine victory, freeze, result HUD, Continue, and Play Again evidence.
