# v0.436-R1I Prepared Assault Combat Causality Diagnosis

## Primary status

`BLOCKED_R1I_COMBAT_CAUSALITY_INCONCLUSIVE`

R1I is a diagnosis-only checkpoint. It does not repair combat, rebalance units, change navigation, or claim conquest. Two fresh comparable headed production sessions reproduce the R1H force-eliminated outcome. The evidence proves accepted attack commands and real damage resolution, but it does not prove one unique causal defect.

## Scope and provenance

- Branch: `codex/v0436-first-complete-conquest-victory`
- R1I Stage-A implementation SHA: `bfc04f73a152bdeb108184dec72328ab5a3cfd9c`
- R1I Stage-A exact CI: `30705488494` / run 668 — required before Stage-B publication
- Evidence source SHA: `bfc04f73a152bdeb108184dec72328ab5a3cfd9c`
- Production scene: `scenes/main.tscn -> scenes/game_world.tscn`
- Renderer: headed Windows Godot 4.3 Forward Plus
- Configuration: Barrosan vs one Lioraen Easy opponent, Hollowspan, Standard resources, Skirmish, Conquest, game speed 2
- PR: #10, open, draft, unmerged
- Final publication SHA: the Stage-B commit containing this report and the review pack; exact SHA is reported in closeout after push

R1I was run only through the explicit opt-in capture environment. No historical R1H screenshots were copied or relabeled as fresh R1I frames.

## Why R1I exists

R1H proved a repeatable natural-assault blocker: the prepared player force was eliminated before the enemy commander was defeated. R1I narrows that observation without silently converting it into a gameplay repair. It adds read-only event slices, attacker samples, command ledgers, casualty ledgers, target histories, and comparable-session analysis around the same production path.

## Exact force and enemy composition

The normal economy and production path produced the declared mixed force in both sessions:

- one starting `barrosan_spear_guard` plus two normally queued Spear Guards;
- two normally queued `barrosan_crag_archer` units;
- the live `barrosan_hero_thane`.

The relevant enemy target sequence was a `lioraen_thorn_ranger` followed by `lioraen_hero_warden`. The live defender inventory also contained the remaining Lioraen combatants recorded by the R1H session audits. No free units, resource injection, AI suppression, direct result writes, or capture-only power were used.

## Damage and armor model

The audited production formula is:

`max(1, raw_damage * type_vs_armor_multiplier - max(0, flat_armor) * 0.5)`

The player definitions used by the audit are Spear Guard: 14 pierce, heavy armor, flat armor 4, 1.3-second attack cooldown; Crag Archer: 16 pierce, light armor, flat armor 0, range 16, 1.4-second cooldown; and Thane: 34 slash, heavy armor, flat armor 6, 1.1-second cooldown. The relevant enemy definitions are Thorn Ranger: 85 HP, light armor, 1.3-second cooldown; and Hero Warden: 340 base HP, medium armor, 1.2-second cooldown. The runtime may apply progression to live maximum HP; the captures record observed HP rather than substituting base definitions.

## Observed damage and timing

Session A recorded 12 damage events while destroying the Thorn Ranger in 24.381 seconds, then 97 damage events against the Hero Warden over 20.585 seconds; the Hero Warden ended at 127.9 HP. Session B recorded 16 damage events while destroying the Thorn Ranger in 23.869 seconds, then 96 damage events against the Hero Warden over 20.090 seconds; the Hero Warden ended at 169.2 HP. These are target-lifecycle/event observations, not a proof of exact per-attacker DPS or time-to-kill because the current runtime does not expose a complete attacker-to-target attack cadence ledger.

The session ledgers record two accepted public orders per session: attack-move destination and attack-target. The target histories show real movement toward the fight and real damage. Attacker samples captured state and navigation-command snapshots at the bounded sampling interval. The samples do not prove uninterrupted attack uptime or a unique target assignment for every attacker.

## Casualty attribution and navigation findings

The two sessions recorded seven death events in the bounded target-lifecycle slices while the player combat force was eliminated. The event records preserve available source and victim runtime identifiers, but they do not provide a complete causal timeline for every casualty across the whole assault. The player force was empty at the blocker terminal state; the match remained running, `match_ended=false`, and no Victory/result/replay state was produced.

Both sessions had accepted attack-move and attack-target returns and live navigation snapshots. Formation interference and navigation interference were not proven. Projectile/hit resolution was not globally broken because the Thorn Ranger was destroyed and the Hero Warden received damage; a projectile-specific root cause was not proven. Target priority, hero overmatch, damage/armor interaction, force composition insufficiency, unintended target switching, and formation/collision interference remain inseparable with the available telemetry.

## Causal decision

The only supportable decision is:

`BLOCKED_R1I_COMBAT_CAUSALITY_INCONCLUSIVE`

What is proven:

- two fresh sessions are comparable;
- normal production and standard resources were used;
- public attack commands returned true;
- one enemy defender was destroyed;
- the enemy hero received real damage;
- the prepared player force was eliminated before a result.

What is not proven:

- a single target-priority defect;
- hero overmatch as the root cause;
- a damage/armor formula defect;
- formation or navigation interference;
- projectile or hit-resolution failure;
- that the declared force composition alone is insufficient.

R1I therefore does not update the production gameplay cause, does not close `P0-RESULT-001`, and does not alter `P0-NAV-001` unless a later checkpoint proves navigation/formation interference.

## Evidence pack

Review pack:

`artifacts/manual-review/v0436-r1i-prepared-assault-combat-causality/`

The pack contains preflight and executable provenance, launch and baseline contracts, session comparability, production definition and damage-formula audits, command ledgers, combat-event copies, casualty ledgers, target retention, uptime, navigation, projectile, expected/observed damage, time-to-kill, causal decision, accepted/rejected evidence, fresh headed frames for sessions A/B, causal comparison/contact-sheet images, capture manifest, and final validation.

The inspected `session-a/08_R1I_WAVE_ONE_COMBAT.png` is a real non-blank headed production gameplay frame. No Victory, Continue, Play Again, or replay frames are present.

## Validator and commands

```text
npm run godot:test:v0436-r1i-combat-causality
npm run godot:smoke:v0436-r1i-combat-causality
npm run godot:capture:v0436-r1i-combat-causality
npm run godot:validate:v0436-r1i-combat-causality
```

The dedicated validator passes with the blocked diagnosis status. It rejects stale R1H/R1G frames, wrong source provenance, non-headed evidence, mismatched sessions, forbidden injection/direct writes, missing attribution, unsupported causal claims, and contradictory success/blocker evidence.

## Two-stage publication and retained validation

Stage A contains only the R1I runner, validator, focused tests, package commands, opt-in wiring, and bounded read-only instrumentation. Stage B contains only fresh R1I evidence, this report, the append-only R1H follow-up, authorized backlog metadata, and publication validation.

The retained R1F contract and R1H viability validator remain passing and truthful. The retained R1B navigation-behavior validator remains the pre-existing `BLOCKED_BOUNDARY_RECOVERY` blocker, and the retained conquest validator remains `BLOCKED_PREEXISTING_NAVIGATION_SYSTEM`; neither was weakened or relabeled.

## What did not change

- no production combat semantics;
- no unit/building definitions;
- no movement, pathfinding, or formation repair;
- no AI, waves, resource, economy, save, stable-ID, result, replay, or renderer changes;
- no true-default runtime change;
- no R1J or v0.437 work;
- no P1–P4 changes;
- no PR merge.

## Backlog disposition

- `P0-RESULT-001` remains open;
- `P0-GAME-001` receives only the exact R1I inconclusive classification;
- `P0-NAV-001` is not updated as proven because navigation/formation interference was not established;
- P1–P4 remain untouched.

## Final validation and state

The final publication validation records exact local command results, exact Stage-A and Stage-B CI runs, PR metadata, and unrelated dirty/generated-file counts. The branch must remain at its pushed Stage-B SHA with `HEAD == origin/codex/v0436-first-complete-conquest-victory` and ahead/behind `0/0`. The broader worktree is intentionally not claimed clean because unrelated user/generated files are preserved.

## Dated R1J follow-up — 2026-08-01

R1J completed two fresh comparable headed production sessions and published the
complete command, target-transition, attack, projectile, damage, and death
attribution graphs at the final R1J evidence SHA. The dedicated R1J validator
passes the causal evidence contract. The resulting classification remains
`BLOCKED_R1J_COMPLETE_ATTRIBUTION_INCONCLUSIVE`: no single localized production
defect was proven, so no combat or balance repair was authorized. R1I's status,
evidence, and conclusions remain unchanged and are not relabeled. See
`docs/V0436_R1J_COMPLETE_COMBAT_ATTRIBUTION_AND_CONDITIONAL_REPAIR_REPORT.md`
and
`artifacts/manual-review/v0436-r1j-complete-combat-attribution-and-conditional-repair/`.
