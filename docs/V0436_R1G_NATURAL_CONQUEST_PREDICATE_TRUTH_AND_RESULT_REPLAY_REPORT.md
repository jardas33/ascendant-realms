# v0.436-R1G Natural Conquest Predicate Truth and Result/Replay Proof

## Executive disposition

R1G is a truthful evidence-integrity checkpoint, not a completed conquest result/replay checkpoint. The isolated headed capture path reached real gameplay-scale combat and recorded live read-only state, but the player assault force was eliminated before the enemy HQ reached a destroyed terminal state. The capture therefore stopped with `BLOCKED_R1G_PLAYER_ASSAULT_FORCE_ELIMINATED`. No victory, result screen, Continue, Play Again, or fresh replay claim is made.

## Scope and authorization

- Branch: `codex/v0436-first-complete-conquest-victory`
- Base/publication HEAD: `cce2fea33accf68d0494385b97a75b72d03d5e88`
- Exact publication CI: `30683815157` — success for the base SHA
- PR: `#10`, open, draft, and unmerged
- Authorized scope: opt-in capture, read-only predicate snapshots, bounded lifecycle evidence, fail-closed validation, and documentary follow-up only
- No production balance or gameplay repair was authorized in R1G

R1G preserves the accepted R1F/R1F-V1 navigation and boundary-physics work. It does not start R1H, v0.437, or a new gameplay repair milestone.

## Why this checkpoint exists

The historical R1C attempt could not prove a headed production run and had unsafe evidence assumptions around short waits, ignored false outcomes, and direct replay-signal emission. R1G replaces those assumptions with an isolated runner that records real frames and live state, and that is only allowed to publish success-only result/replay evidence after the normal runtime itself proves a terminal conquest predicate.

## Capture contract

The opt-in implementation is:

- `production/ascendant-realms-godot/tests/v0436_r1g_capture.gd`
- `tools/godot/v0436R1GNaturalConquestTruthTool.mjs`
- `package.json` commands `godot:*:v0436-r1g-natural-conquest-truth`
- autoload `V0436R1GCapture`, selected only by `ASCENDANT_V0436_R1G_CAPTURE=1`

The capture launches the production `scenes/main.tscn -> scenes/game_world.tscn` path in two headed sessions with the normal Barrosan-versus-Lioraen Easy, Hollowspan, standard Conquest configuration. It owns stdout/stderr, uses the reviewed Forward Plus executable, records branch/source SHA/session provenance, and writes isolated artifacts under:

`artifacts/manual-review/v0436-r1g-natural-conquest-predicate-truth/`

The capture uses public RTS selection and attack commands, samples live commander/building/unit/predicate/navigation/combat state, and uses actual mouse input against the real Continue/Play Again buttons if and only if a live result state is reached. It does not write HP, death, defeat, result, match-ended, or game-running state; it does not emit result/replay signals directly; it does not teleport units or call button handlers directly.

## Truthful result

Both sessions produced real headed frames through combat contact, real damage, and enemy-HQ state inspection. The dedicated validator selected session A as the blocker and found:

- blocker: `BLOCKED_R1G_PLAYER_ASSAULT_FORCE_ELIMINATED`
- player assault force: empty at the terminal observation
- player Barrosan Clanhold: alive, 2200/2200 HP
- player War Hall: alive, 950/950 HP
- enemy Lioraen Groveheart HQ: alive, 1749.12/2000 HP
- enemy Thornhall: alive, 850/850 HP
- enemy Lifewell: alive, 500/500 HP
- both commanders: not defeated; both still have a live HQ and live workers
- `match_ended=false`
- `game_running=true`
- `game_over_count=0`
- `profile_record_count=0`
- `result={}`
- sole non-defeated commanders: `[0, 1]`

The target lifecycle for the enemy HQ ended with the same blocker disposition. The proof is internally consistent: a real assault occurred, the player force was eliminated, and the enemy HQ survived. The validator returns `passed: true` for the integrity of this blocked evidence pack; it does not mean that conquest succeeded.

## Evidence produced

Each session contains actual rendered frames:

- `01_R1G_MATCH_CONFIGURATION.png`
- `02_R1G_INITIAL_PRODUCTION_MATCH.png`
- `03_R1G_NAVIGATION_READY.png`
- `04_R1G_PLAYER_PRODUCTION_READY.png`
- `05_R1G_ASSAULT_COMMAND.png`
- `06_R1G_REAL_COMBAT_CONTACT.png`
- `07_R1G_REAL_DAMAGE.png`
- `08_R1G_ENEMY_HQ_ACTUAL_STATE.png`
- `21_R1G_BLOCKER_CONTACT_SHEET.png`

The root pack also contains capture provenance, launch contract, match configuration, target-lifecycle audit, navigation monitoring audit, combat/destruction audit, predicate sequence, victory-check audit, result-state audit, freeze audit, Continue and Play Again audit placeholders, fresh-replay audit, accepted/rejected evidence, and `final-validation.json`.

Success-only result/replay frames were rejected because the terminal fact was not proven. The pack does not reuse the historical R1C pack.

## R1C follow-up and retained history

R1C remains an append-only historical record of its headed-startup blocker and is not overwritten. R1D/R1F/R1F-V1 evidence remains retained. R1G demonstrates that the reviewed headed environment now produces real gameplay frames; the remaining blocker is gameplay-scale natural conquest resolution, not a substituted headless or title-card capture.

## Backlog disposition

- `P0-NAV-001`: focused R1/R1A/R1B/R1F proof remains accepted; R1G natural-match observation reached the assault-force-eliminated blocker. No new navigation repair is authorized by this checkpoint.
- `P0-RESULT-001`: remains open because R1G did not reach a natural terminal victory, result freeze, Continue, Play Again, or fresh replay.
- P1-P4 backlog items are unchanged.

## Validation evidence

The dedicated R1G commands are:

```text
npm run godot:test:v0436-r1g-natural-conquest-truth
npm run godot:smoke:v0436-r1g-natural-conquest-truth
npm run godot:capture:v0436-r1g-natural-conquest-truth
npm run godot:validate:v0436-r1g-natural-conquest-truth
```

Focused tests, smoke, two headed capture sessions, and the dedicated validator passed. The validator reports the exact blocker, confirms the source/branch contract, confirms real session frames and audits, rejects success-only evidence while blocked, and records no direct gameplay writes.

Retained R1/R1A/R1B/R1D/R1F gates also remain green, including the R1F contract tests, boundary-physics test/smoke/validator, navigation-repair test/smoke/validator, navigation-behavior test/smoke/validator, conquest-victory focused test/smoke, and the historical R1B timer diagnostic classification.

## Final disposition and safest next action

This is a truthful blocked R1G capture/tooling publication. Do not close `P0-RESULT-001`, do not claim conquest victory or replay success, and do not alter production gameplay semantics in response to this evidence. The safest next step requires a separately authorized bounded investigation of why the normal player assault force is eliminated before the enemy HQ is destroyed, while preserving this pack as the R1G evidence baseline.

## v0.436-R1H follow-up — natural player assault viability

R1H is an append-only follow-up to the R1G record above. The R1G blocker and all earlier evidence remain unchanged. R1H did not repair production gameplay, balance, navigation, combat values, result semantics, or replay semantics. It added only an opt-in headed capture and fail-closed validator for a normal-economy assault viability observation.

- Stage-A implementation SHA: `2f18357a64f3a8869ecf52481136cbc799370e5f`
- Stage-A exact CI: `30687260709` / run 663 — success
- Branch: `codex/v0436-first-complete-conquest-victory`
- Capture pack: `artifacts/manual-review/v0436-r1h-natural-player-assault-viability/`
- Dedicated commands: `npm run godot:test:v0436-r1h-natural-assault-viability`, `npm run godot:smoke:v0436-r1h-natural-assault-viability`, `npm run godot:capture:v0436-r1h-natural-assault-viability`, and `npm run godot:validate:v0436-r1h-natural-assault-viability`

Both fresh headed sessions used the production `scenes/main.tscn -> scenes/game_world.tscn` path, Barrosan versus Lioraen Easy, Hollowspan, standard resources, Conquest, and game speed 2.0. Workers constructed a real War Hall, resumed gathering through normal commands, crossed the recorded food threshold, and queued the mixed force through the real-cost production path. The readiness audit records the produced Barrosan force and normal resource/queue transactions; no resources, units, HP, death, defeat, result, or replay state were injected by the capture.

The live result was the same in sessions A and B: `BLOCKED_R1H_PREPARED_ASSAULT_FORCE_ELIMINATED`. The bounded assault destroyed one real enemy defender and produced real damage/lifecycle samples, but the remaining enemy hero survived while the prepared player combat force was eliminated. The final read-only predicate remained non-terminal: `match_ended=false`, `game_running=true`, `game_over_count=0`, empty result, both commanders not defeated, and no valid victory/result/replay state.

This is a passed validator result for truthful blocked evidence, not a passed conquest result. Success-only frames `17_R1H_FINAL_CONQUEST_PREDICATE.png` through `25_R1H_FRESH_REPLAY.png` are intentionally absent. The real rendered frames `01_R1H_STANDARD_MATCH_START.png` through `09_R1H_WAVE_ONE_TERMINAL_STATE.png`, the two blocker contact sheets, economy/production audits, target lifecycles, predicate snapshots, and black-frame report are retained under the R1H pack.

R1H disposition: keep `P0-RESULT-001` open, keep `P0-NAV-001` as a separate investigation concern, and do not claim victory, result freeze, Continue, Play Again, or fresh replay. The safest next step is a separately authorized bounded diagnosis of the assault-force-eliminated blocker; no R1H repair is implied by this evidence-only checkpoint.

### R1H closeout validation clarification

After the Stage-A descendant, the retained R1F boundary-physics validator was re-run and passed once its exact documentation allowlist included the R1F contract source itself. This was a validator-provenance compatibility repair only; no production gameplay behavior changed.

The retained R1B navigation-behavior validator remains blocked by its historical boundary-recovery evidence (`6b14ba305afc4b3090d57f400da885550d512183`, `BLOCKED_BOUNDARY_RECOVERY`, with speed/no-teleport predicates still false). The retained v0.436 conquest-victory validator remains blocked because its three repaired headed attempts did not produce a genuine Victory result. These retained statuses remain visible and fail-closed; they are not relabeled as green for R1H.
