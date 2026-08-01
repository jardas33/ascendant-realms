# v0.436-R1H Natural Player Assault Viability

## Executive disposition

R1H is a truthful, opt-in, headed viability checkpoint. It did not prove natural conquest, victory, result freeze, Continue, Play Again, or fresh replay. Both fresh sessions reached the same real gameplay blocker:

`BLOCKED_R1H_PREPARED_ASSAULT_FORCE_ELIMINATED`

The dedicated validator passed because the blocked evidence is internally consistent and fail-closed. “Passed” means the evidence contract passed; it does not mean the assault or conquest passed.

## Scope and exact base

- Branch: `codex/v0436-first-complete-conquest-victory`
- R1G published base: `756cc7e7bd42bdcef9f4d212bfbde9d626fa7ccc`
- R1H Stage-A implementation SHA: `2f18357a64f3a8869ecf52481136cbc799370e5f`
- Stage-A exact GitHub Actions: `30687260709` / run 663 — success
- Production scene: `scenes/main.tscn -> scenes/game_world.tscn`
- No v0.437 work was started.

## Why R1H exists

R1G established that headed production combat could be observed truthfully, but its first normal assault died before the enemy HQ was destroyed. R1H tests whether a sustainable normal economy and a deliberately prepared mixed force can reach a viable player assault without adding capture-only power, free units, resource injection, or direct result-state writes.

## Allowed implementation

R1H adds only the isolated capture, validator, package commands, opt-in autoload/menu/game-root wiring, and the retained R1F descendant allowlist. It does not alter production unit/building definitions or gameplay semantics.

The capture uses standard match resources, normal workers, real construction, real gathering, real-cost `queue_unit`, public selection/attack-move/attack-target commands, bounded focus, and read-only state snapshots. It does not write HP, death, defeat, result, match-ended, replay, or resource state.

## Normal economy and production evidence

Both sessions recorded standard resources with no injection, real worker construction commands for a War Hall, War Hall completion through the normal build path, workers returning to a live food resource through normal gather commands, a real resource transaction timeline, the food threshold needed for production, real-cost mixed-force queues, and force readiness before assault.

Source files in the pack include `economy-audit.json`, `force-readiness-audit.json`, `construction-audit.json`, `production-audit.json`, and each session’s `r1h-final-state.json`.

## Assault evidence and blocker

The bounded plan used two Spear Guards and two Crag Archers in addition to normally spawned forces, staying below the declared live-force cap. It targeted active enemy combatants first through the public RTS command surface. The live frames show real combat context and lifecycle progression; one enemy defender was destroyed. The remaining enemy hero survived while the prepared player combat force was eliminated.

The final read-only state recorded `match_ended=false`, `game_running=true`, `game_over_count=0`, empty result and match result, both commanders not defeated, and no victory/result/replay state. Success-only frames `17_R1H_FINAL_CONQUEST_PREDICATE.png` through `25_R1H_FRESH_REPLAY.png` are absent by design.

## Evidence and review pack

Review pack:

`artifacts/manual-review/v0436-r1h-natural-player-assault-viability/`

It contains fresh sessions A/B, preflight and executable provenance, launch and match contracts, real PNG frames, economy and production audits, force-readiness evidence, target lifecycles, predicate sequences, accepted/rejected evidence, a black-frame rejection report, blocker contact sheet, and `final-validation.json`.

Manual inspection covered `session-a/08_R1H_WAVE_ONE_COMBAT.png` and `session-a/09_R1H_WAVE_ONE_TERMINAL_STATE.png`; both are non-blank headed gameplay images. The visual pack is real runtime evidence, not a title-card substitute.

## Validator and commands

```text
npm run godot:test:v0436-r1h-natural-assault-viability
npm run godot:smoke:v0436-r1h-natural-assault-viability
npm run godot:capture:v0436-r1h-natural-assault-viability
npm run godot:validate:v0436-r1h-natural-assault-viability
```

The focused contract suite passed 6/6. The dedicated validator passed with status `BLOCKED_R1H_PREPARED_ASSAULT_FORCE_ELIMINATED`; it confirms branch/source provenance, two sessions, required live frames, normal-economy evidence, no direct gameplay-write patterns, blocker fields, and rejection of success-only evidence while blocked.

## Preserved boundaries

- The R1G blocker remains verbatim in the R1G report.
- R1F/R1F-V1 navigation and boundary-physics evidence remains retained.
- Production unit/building definitions were not changed.
- No movement repair, pathfinding repair, combat balance repair, AI repair, resource mutation, result mutation, replay mutation, save mutation, or renderer change was made.
- No true-default runtime change was introduced; R1H requires `ASCENDANT_V0436_R1H_CAPTURE=1`.
- No v0.437 work was started.

## Validation evidence

Stage-A local checks passed: R1H contract tests 6/6, retained R1F contract tests 10/10, Godot project load, R1H headless smoke, and `git diff --cached --check`.

Stage-A exact CI passed: run `30687260709` for SHA `2f18357a64f3a8869ecf52481136cbc799370e5f`.

Stage-B evidence checks passed: two fresh headed captures, dedicated R1H validator, real PNG manual inspection, blocker contact sheets, and black-frame rejection report.

The retained R1F boundary-physics validator was re-run after the Stage-A descendant and passed after the exact documentation allowlist was completed. No production gameplay file was changed for that compatibility repair.

The retained R1B navigation-behavior validator remains a truthful pre-existing blocker: its retained boundary evidence is sourced from `6b14ba305afc4b3090d57f400da885550d512183`, reports `BLOCKED_BOUNDARY_RECOVERY`, and fails its historical speed/no-teleport predicates. The retained v0.436 conquest-victory validator also remains blocked with `BLOCKED_PREEXISTING_NAVIGATION_SYSTEM` because its three repaired headed attempts did not produce a genuine Victory result. These retained failures are not R1H failures and were not weakened or rewritten.

Final publication implementation commit: `bebd64ef511a36ea10a99a8cda80486c5f11ebc7`.
Final publication implementation exact GitHub Actions: `30688551166` / run 664 - success for that exact SHA.
Final closeout metadata commit: `a09c6e37072a4978911449179672bec8000dd711`.
Final closeout metadata exact GitHub Actions: `30689101262` / run 665 - success for that exact SHA.
PR #10 remains open, draft, and unmerged.

## Dated R1I follow-up — 2026-08-01

R1I is the authorized diagnosis-only follow-up to this preserved R1H blocker. It ran two fresh comparable headed sessions at Stage-A SHA `bfc04f73a152bdeb108184dec72328ab5a3cfd9c` and reproduced the same prepared-force-eliminated outcome. It adds no production repair and does not relabel the R1H result.

The exact classification is `BLOCKED_R1I_COMBAT_CAUSALITY_INCONCLUSIVE`. Public attack-move and attack-target commands returned true, one enemy defender was destroyed, the enemy hero received real damage, and the player force was eliminated before a result. The available evidence still cannot separate target priority, hero overmatch, damage/armor interaction, formation/navigation interference, projectile/hit failure, unintended target switching, or force composition insufficiency. The exact R1I report and evidence pack are `docs/V0436_R1I_PREPARED_ASSAULT_COMBAT_CAUSALITY_REPORT.md` and `artifacts/manual-review/v0436-r1i-prepared-assault-combat-causality/`.

`P0-RESULT-001` remains open. `P0-GAME-001` is updated only with the exact inconclusive classification. `P0-NAV-001` is not marked proven, P1–P4 remain unchanged, and no R1J, v0.437, production repair, or PR merge occurred.

## Final disposition and next action

R1H is a truthful blocked viability result. Keep `P0-RESULT-001` open. The next authorized checkpoint should be a bounded diagnosis of the natural assault-force-eliminated blocker, not an automatic balance or gameplay rewrite.
