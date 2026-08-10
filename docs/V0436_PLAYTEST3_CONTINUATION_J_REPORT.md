# Ascendant Realms Playtest 3 Continuation J

## Scope

Continuation J qualified the accepted I0/I1/I2 work and ran the authorized J2/J3/J4/J5 sequence on an isolated local branch. The protected checkout and remote state were not changed.

## Provenance

- Worktree: `D:\CodexData\worktrees\ascendant-realms-playtest3-continuation-j3`
- Branch: `codex/local-playtest3-continuation-j3`
- J2 base: `2d4b71e557e8e492c0db077c18d00c92a639f802`
- Current local HEAD: `33ae1f998ef3b112446be287215640ce8c2cc04e`
- Local commits: `73aad4d5` (minimap resource-marker accessor repair), `33ae1f99` (Easy opening pressure timing)
- Godot: `D:\CodexData\tools\godot-4.6.3-stable\Godot_v4.6.3-stable_win64.exe`, Godot 4.6.3 stable, headed Forward Plus

## I0/I1/J1 disposition

The earlier startup issue is classified as `PASSED_J1_RUNTIME_REACHES_GAMEWORLD__AUTOMATED_WARM_START_SLOW`. The headed production process reached the live GameWorld; the remaining cost is startup/import latency, not a new loading-screen production defect. The c9da-to-current command-panel diff remains report-only.

## J2 result

J2 passed as a player-quality presentation pass. The deterministic minimap now uses a rasterized terrain background, bent overview roads, region shelves, water bands, live resource markers, live building markers, live unit diamonds, and the camera footprint. Fresh captures were produced for Hollowspan, Emberfall Rift, and Frostmere Basin at 1920x1080 and 1366x768.

- Minimap evidence: `D:\CodexData\evidence\ascendant-realms-playtest3-continuation-j\J2_MINIMAP_FINAL\`
- Construction evidence: `D:\CodexData\evidence\ascendant-realms-playtest3-continuation-j\J2_CONSTRUCTION\`
- Construction content debt retained honestly: the existing worker animation library contains Idle/Walk/Punch/Death clips but no authored work/hammer clip; the capture therefore proves worker construction state and movement, not a dedicated hammer animation.

## J3 result

Three fresh headed Barrosan versus Lioraen Easy, Hollowspan, Rich Conquest rehearsals were run with the F2 natural-conquest harness. Each reached the real match and recorded real construction, worker queue, resource transaction, and enemy production telemetry. All three reproduced the same bounded pre-combat failure:

`BLOCKED_F2_ECONOMY_OR_PRODUCTION_STALLED`

The player could not establish a surviving combat force before Easy pressure reached the base. The final inventories were:

| Match | Player combat units | Player buildings | Enemy units | Result |
|---|---:|---:|---:|---|
| 1 | 1 | 1 | 14 | War Hall/hero pressure before mixed-force queue |
| 2 | 0 | 0 | 14 | War Hall and player force lost before queue completion |
| 3 | 1 | 1 | 14 | Same pre-combat stall |

Evidence roots:

- `D:\CodexData\evidence\ascendant-realms-playtest3-continuation-j\J3_MATCH_1\`
- `D:\CodexData\evidence\ascendant-realms-playtest3-continuation-j\J3_MATCH_2\`
- `D:\CodexData\evidence\ascendant-realms-playtest3-continuation-j\J3_MATCH_3\`

This is not a combat-positioning verdict: the player never reached a valid mixed-force engagement. No orbiting, building penetration, or ranged-overclose claim is made.

## J4 repair

The smallest justified Easy repair was a 300-second simulation-time opening grace before the first autonomous Easy wave. It preserves the Easy six-unit force threshold, role selection, public commands, combat resolution, and damage semantics while giving a normal player opening time to complete the first military building and queue defenders/hero. The repair is in `scripts/ai/enemy_ai.gd`.

The capture harness also received fail-safe handling for an empty HQ sample and a destroyed War Hall reference, preventing evidence collection from throwing `front()`/previously-freed-object errors. The HUD minimap resource marker now reads the typed `ResourceNode.resource_kind` property instead of calling `Object.get` with two arguments.

### Post-J4 rehearsal result

A fresh headed post-tuning Easy rehearsal was started from the J4 HEAD with the normal F2 configuration. It produced real 1920x1080 start, economy, production, housing, and partial mixed-force frames, plus live configuration/worker/production ledgers. The bounded runner reached its 15-minute execution limit before the GDScript's 40-minute F2 wall-clock terminal classifier completed; no first-wave, mixed-force engagement, combat result, or victory claim is made. The partial evidence is retained under `D:\CodexData\evidence\ascendant-realms-playtest3-continuation-j\J4_EASY_AFTER_TUNING\` and copied truthfully into the `FINAL` review root. The exact missing proof is recorded in `FINAL\evidence-gap.json` rather than synthesized or mislabeled.

## J5 tooling result

- `npm run godot:test:v0435-easy-ai-wave`: passed.
- `npm run godot:test:v0436-f2-natural-conquest`: passed.
- `npm run godot:smoke:v0435-easy-ai-wave`: process exit 0; Godot reported only pre-existing resource-leak shutdown warnings.
- General headed production parse/import: passed before the J4 commits.
- `npm run godot:test:v0436-conquest-victory`: failed on a pre-existing static assertion requiring the absent literal `_move_target = _target.global_position` in `unit.gd`; neither J2 nor J4 changed `unit.gd`. This is retained as an existing validator-contract mismatch, not silently reclassified.
- `npm run godot:all`: still required for final closeout; the package's internal doctor previously reported `BLOCKED_PENDING_LOCAL_GODOT_SETUP` despite the supplied official runtime being usable for headed captures.

## Final classification

`IMPROVEMENT__J2_MINIMAP_AND_CONSTRUCTION_PRESENTATION_PASS__J3_PRECOMBAT_EASY_OPENING_BLOCKER__J4_MINIMAL_OPENING-GRACE_REPAIR`

The batch is not a combat qualification. The post-J4 repair remains technically unqualified for player-facing combat because the bounded rehearsal did not reach first contact. The next safe bounded priority is a narrowly scoped continuation of the Easy rehearsal with a truthful terminal outcome, followed by Normal smoke only if the Easy opening is accepted. Do not claim combat positioning success from the pre-repair runs or from the partial post-tuning frames.

## Protected state

- Protected checkout remains untouched.
- No push, PR mutation, merge, promotion, R1K work, v0.437 work, or destructive Git action occurred.
- All new evidence and worktrees were placed on D.
