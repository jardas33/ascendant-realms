# v0.435 First Autonomous Easy Opponent Wave

## Outcome

v0.435-R1 is the repaired, bounded, opt-in technical gameplay checkpoint. It adds one real Easy Lioraen opponent lane against a Barrosan player that gathers real resources, constructs through the shared placement contract, produces a six-unit mixed-role force, launches one autonomous first wave, reaches real contact, damages a player unit and building, records at least two AI casualties, and queues a same-race replacement. It does not add strategic AI, a second wave, destruction, victory/defeat, or any excluded combat system.

## Base and branch

- Base HEAD: `6d52ec1309b09401ed6c705b6dda98707d26b33e`
- Branch: `codex/v0435-first-autonomous-easy-opponent-wave`
- Stacked target branch: `codex/v0434-first-combat-casualty-loop`
- Repair commits: `b252bbad` and `403e9ba0`.
- The final evidence/docs commit and exact-SHA CI evidence are added during closeout.

## v0.435-R1 repair reason

The first v0.435 evidence was rejected because it used the wrong opponent/resource presentation, changed Easy tuning and wave size, claimed mixed roles without deriving them from launched participants, and carried capture provenance from the v0.434 baseline. R1 replaces that evidence rather than treating it as authoritative. The latest headed capture was generated after the AI repair SHA and is the only accepted evidence set.

The repaired match contract is exact: Barrosan player, one Lioraen Easy opponent, `hollowspan`, skirmish/conquest, Standard starting resources, and the fastest existing selectable speed of `2.0x`. The restored Easy values are think interval `2.0`, worker target `7`, army attack size `6`, economy efficiency `0.7`, technology aggression `0.6`, and brutal income `0.0`.

## Scope

The implementation is isolated to the opt-in v0.435 capture/test lane. The true default runtime, stable IDs, saves, accepted v0.432-v0.434 semantics, and existing production fallback remain preserved.

The Easy lane uses the same real worker nodes, resource nodes, drop-offs, costs, population limits, production queues, building placement, attack-move command path, combat damage path, casualty path, and replacement queue as the player lane. Easy has no income bonus, free construction, free queue insertion, passive income, refund, direct spawn, timer damage, or capture-driver AI command. `_brutal_income` is explicitly zero.

## Implemented contracts

### Real economy and construction

- Exact resource assignment is explicit and never silently falls back to a mixed cargo kind.
- AI workers are produced only through the real HQ queue/spawn path.
- Deposits require a valid friendly built drop-off and are recorded in the world bank ledger.
- Shared `GameWorld.can_place_building(...)` validates definition/team, map bounds, footprint overlap including unfinished buildings, resource overlap, worker access, and affordability as separate concerns.
- Easy construction uses a deterministic bounded search for a legal location near the AI HQ.
- Housing and military buildings use the ordinary queue/build path.

### First wave and bounded contact

- A data-driven Lioraen Age-I composition is queued and staged: `lioraen_thorn_ranger` (ranged), `lioraen_bloomdancer` (melee), and `lioraen_rootwarden_guard` (defender).
- One first wave is launched with the public attack-move command path.
- The launched wave contains six non-worker/non-hero participants and three distinct roles; `mixed_roles` is derived from the actual launch payload.
- The wave targets the known player-side objective and reaches real contact.
- Real combat events record player-unit damage and player-building damage.
- At least two AI units die in the bounded encounter; the replacement manager queues a replacement through the ordinary production path.
- No second wave, destruction proof, victory/defeat, or strategic opponent behavior is included.

### Fresh-scene reset

The capture driver starts a fresh scene after the first-run proof and verifies a new AI node with no stale AI state, target, wave, or selection. The replay reset no longer overwrites the authoritative first-run economy/wave/damage/casualty audits.

## Authoritative evidence

Authoritative evidence is the latest validator-green headed capture only. Earlier attempts were rejected during development: the first headed attempt exposed menu handoff and strict-type parse issues; subsequent runs exposed and repaired HQ target handoff, capture-side HQ selection, replacement ordering, AI worker resource validation, and replay-audit overwrite. Rejected runs are not counted as proof.

Latest audit facts:

- `v0435-match-config-audit.json`: Barrosan versus one Lioraen Easy opponent, Standard resources, `hollowspan`, skirmish/conquest, and displayed/stored/engine speed `2.0`.
- `v0435-easy-difficulty-contract-audit.json`: exact restored v0.434 Easy values; no QA wave override.
- `v0435-lioraen-production-contract-audit.json`: Lioraen HQ, worker, housing, military building, and legal Age-I production roles; all AI units/buildings are same-race.
- `v0435-ai-deposit-ledger.json`: `entry_count=177`; exact kinds are `food`, `timber`, `stone`, and `gold`.
- `v0435-wave-launch-audit.json`: `launched=true`; one `first_wave_launched` event; `count=6`; `threshold=6`; `attack_move=true`; three distinct roles.
- `v0435-player-building-damage-audit.json`: `real_building_damage=true`; damage events are authored by AI units through the real combat path.
- `v0435-casualty-replacement-audit.json`: `ai_deaths=2`; `replacement_queued=true`; same-race replacement `lioraen_thorn_ranger` through `lioraen_thornhall`.
- `v0435-fresh-scene-replay-audit.json`: fresh scene and new AI node; stale AI state, target, wave, and selection are all false.
- `v0435-validation.json`: `passed=true`.

The capture command metadata records `baseSha=6d52ec13`, `aiRepairSha=403e9ba0`, `captureSourceSha=403e9ba0`, and `validationInputSha=403e9ba0`; the source and validation SHAs are repair descendants, not the v0.434 base or a self-referential final commit.

## Review pack

Review pack (absolute checkout path):

`D:\Code for projects\WB game like\ascendant-realms-v0223-recovery\artifacts\manual-review\v0435-first-autonomous-easy-opponent-wave\`

The pack contains 20 real rendered PNG frames, a real gameplay contact sheet, headed and smoke logs, capture command metadata, black-frame rejection evidence, and the JSON audit set (52 files total after R1). The key frames are:

- `01_V0435_INITIAL_EASY_AI_SCENE.png`
- `02_V0435_AI_WORKERS_GATHERING.png`
- `04_V0435_AI_RESOURCE_DEPOSITS.png`
- `08_V0435_AI_MILITARY_BUILDING_CONSTRUCTION.png`
- `12_V0435_AI_FIRST_WAVE_LAUNCHED.png`
- `13_V0435_AI_ATTACK_MOVE_CONTACT.png`
- `14_V0435_PLAYER_UNIT_DAMAGED_BY_AI.png`
- `15_V0435_PLAYER_BUILDING_DAMAGED_BY_AI.png`
- `16_V0435_AI_FIRST_CASUALTY.png`
- `18_V0435_AI_REPLACEMENT_QUEUE.png`
- `19_V0435_FRESH_SCENE_REPLAY.png`
- `20_V0435_EASY_AI_CONTACT_SHEET.png`

These are actual rendered production-scene captures, not title cards or blank placeholders. The capture driver rejects black/blank evidence.

## Preservation and exclusions

Preserved:

- v0.434 real bounded combat and casualty loop
- v0.433 worker economy and exact-resource contracts
- v0.432 production/building foundations
- stable IDs, saves, and true default runtime
- existing debug/fallback renderer and retained validation lanes

Explicitly not added:

- strategic AI or adaptive planning
- waves beyond the single bounded first wave
- destruction, siege, towers, victory/defeat
- hero abilities, spells, healing, status effects, fog, formations, tech, ages
- campaign/story/dialogue/multiplayer/save migration
- new unit/building types or external/protected assets
- direct AI commands from capture tooling
- direct HP, resource, death, spawn, queue, or timer mutation from capture tooling

## Validation

Dedicated commands:

```text
npm run godot:test:v0435-easy-ai-wave
npm run godot:smoke:v0435-easy-ai-wave
npm run godot:capture:v0435-easy-ai-wave
npm run godot:validate:v0435-easy-ai-wave
```

The focused tests, smoke run, headed capture, and dedicated validator are green for the evidence recorded above. Smoke/headed Godot exit logs may report leaked timer/ObjectDB resources because the capture lane intentionally exits after evidence collection; these are non-fatal cleanup warnings and do not invalidate the rendered captures or validator result. The latest visual inspection confirms the pack contains real rendered gameplay frames and a real contact sheet; no black, blank, or title-card-only frame is being used as proof.

Retained validators and full repository checks are green on the v0.435 continuation branch. The retained validators accept this exact continuation branch while preserving their original checkpoint and provenance assertions:

- v0.434 combat validator
- v0.433 worker-economy validator
- v0.432 production validator
- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run validate:runtime-art-slots`
- `npm run validate:artifact-retention`
- `npm run godot:all`
- `git diff --check`

Observed local results:

- v0.432, v0.433, v0.434, and v0.435 dedicated validators: passed with empty failure lists.
- `npm test`: 122 test files / 887 tests passed.
- `npm run build`: production TypeScript/Vite build passed.
- content, art-intake, and runtime-art-slot validation: passed.
- artifact retention: `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`.
- `npm run godot:all`: passed.
- `git diff --check`: passed; only normal Windows line-ending warnings were emitted.

## Closeout

- Commit: recorded after all local validation is green.
- Exact-SHA GitHub Actions run: recorded after push and completion.
- Final tracked repository state: clean and synchronized with origin after closeout.
