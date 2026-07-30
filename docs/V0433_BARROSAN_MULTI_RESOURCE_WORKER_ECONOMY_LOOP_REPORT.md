# v0.433 Barrosan Multi-Resource Worker Economy Loop

## Executive result

v0.433 repairs the existing production worker economy path on the stacked v0.432 branch. The patch is intentionally narrow: workers gather the four existing resource kinds through the existing RTS right-click path, respect the ten-unit carry limit, return cargo to a valid friendly drop-off, deposit exactly once, switch resource kinds without losing cargo, and remain auditable through a shared Commander bank.

## Base and branch

- Base SHA: `eb6485805c06ecf7bb92a616ff16de95c0dead5c`
- Branch: `codex/v0433-multi-resource-worker-economy-loop`
- Parent v0.432 branch and PR #6 remain untouched.

## Scope

The implementation stays inside the existing `ResourceNode`, `Unit`, `GameWorld`, `Commander`, HUD, map-definition, and headed-capture paths. It does not add combat, AI behavior, technology, new buildings, new units, new resources, production redesign, save changes, or default-runtime mutation.

## Root causes and repairs

1. Extraction previously requested three units unconditionally, allowing `3 -> 6 -> 9 -> 12`. The worker now requests the minimum of nominal rate, remaining carry capacity, and node amount.
2. Mixed carried-resource switching previously had a no-op branch. The worker now remembers the next node, returns current cargo through the normal drop-off path, deposits it, and then gathers the requested new kind.
3. Gather commands now reject non-workers, dead workers, invalid/depleted nodes, and nodes outside the production battlefield without changing cargo, nodes, or resources.
4. Drop-off lookup failure preserves cargo and retries on a bounded timer rather than scanning every frame.
5. `ResourceNode` clamps extraction and emits one depletion signal with the final remainder.
6. The selected worker card now exposes concise activity, carry, capacity, and target text without raw implementation names.
7. Starting headquarters now receive the authoritative race `main_building` definition ID at the shared creation boundary; blank definition IDs are rejected before a building instance can be created.
8. Deposit evidence now records the live drop-off building ID, runtime ID, team, position, built/friendly flags, and definition name. The compatibility `dropoff_id` field is the same authoritative ID.

## v0.433-R1 identity and evidence repair

The first headed recapture exposed two evidence-truth defects: live starting buildings needed an explicit authoritative definition ID, and the capture driver switched the food worker to gold before the real food deposit had completed. The bounded repair was:

- `cc2ee707f9727f853ce8dae67ef4876c6ed0d9ce` repairs the shared starting-building definition boundary, rejects blank IDs, records authoritative live drop-off identity, and adds the all-race starting-HQ identity test.
- `eed400929f35bc3ac3a8634e8037960ba08f684c` repairs only the headed capture timing so the real carried food deposit completes before the gold switch proof.
- `e322f15b866700c7cd277b7fdcb9ac3ce9465cda` records identity-repair and capture-source provenance separately in the capture metadata.
- `v0433-starting-hq-identity-matrix.json` proves all ten race `main_building` IDs resolve to completed, prebuilt starting HQ definitions.
- `v0433-building-identity-audit.json` proves live building and definition IDs are non-empty, including `barrosan_clan_croft` and `barrosan_war_hall`.
- `v0433-deposit-transaction-audit.json` proves every recorded deposit uses the friendly completed `barrosan_clanhold` with team `0`, a non-empty runtime ID, and the authoritative `dropoff_id` alias.
- `v0433-capture-command.json` records `identityRepairSha=cc2ee707...` and `captureSourceSha=e322f15b...`; the validator reads the current checkout SHA dynamically and rejects self-referential final-commit metadata.

## Four-resource production path

The accepted resource set remains food, timber, stone, and gold. Food nodes were added to the existing map assembly because the prior production map declared food in the economy but did not instantiate a real food node. No external asset was added; the existing repository-authored resource model path is reused.

## Evidence

The headed driver uses the real Forward Plus production scene, real Barrosan workers, actual resource nodes, the right-click context-command method reached by normal RTS input, the real pause method, the live Commander bank, and one real Clan Croft placement spend. It records extraction, deposit, switch, pause, concurrency, fresh-scene, preservation, and black-frame evidence under:

`artifacts/manual-review/v0433-multi-resource-worker-economy-loop/`

Required commands:

- `npm run godot:test:v0433-worker-economy`
- `npm run godot:test:v0433-worker-economy` — passed focused economy and all-race building identity tests
- `npm run godot:smoke:v0433-worker-economy`
- `npm run godot:capture:v0433-worker-economy`
- `npm run godot:validate:v0433-worker-economy`

## Preserved

- v0.432 War Hall and Clan Levy production loop
- Clan Croft construction regression
- existing Commander resource bank and gather multiplier
- existing production definitions and carry capacity value of 10
- original Tesana export, complete asset library, legacy/fallback project, and true default runtime
- no combat, damage, death, enemy AI, waves, technology, fog, economy redesign, or external assets

## Validation and closeout

The dedicated validator checks the exact base ancestry, branch, source repairs, four resource definitions, carry/switch/deposit/pause/spend/replay evidence, real capture metadata, and black-frame rejection. The retained v0.432 smoke/validator is run separately before closeout. Final CI SHA, run ID, and clean-sync state are recorded after push.

## Concrete headed proof

- All 20 required headed frames exist at 1920x1080 and are non-black with meaningful luminance variance.
- The real input audit records timber, stone, and food assignment through `RTSController._issue_context_command -> Unit.command_gather`.
- The deposit ledger contains food, timber, stone, and gold transactions; the gold entry follows the food-to-gold switch and updates the shared Commander bank exactly once.
- Carry evidence reaches `Timber 10 / 10` without overflow; extraction is bounded by remaining capacity and exact node remainder.
- The switch sequence proves `FOOD 9/10` in the pre-switch frame, a real food deposit before the next command, `GOLD 10/10` while returning, and the subsequent gold bank update.
- All deposit transactions contain a non-empty authoritative drop-off ID; blank-ID count is zero and every current deposit resolves to the live friendly completed Clanhold.
- Pause evidence shows extraction and carry unchanged while paused, then resumed gathering after unpause.
- The shared-bank frame records a real Clan Croft placement using the updated live bank.
- Fresh-scene replay reloads `scenes/game_world.tscn`, gathers timber again, deposits once, and reports no stale cargo or target state.
- The contact sheet is a real rendered gameplay sheet, not a title-card substitute; the black-frame report passes all sampled gameplay frames.

## Validation completed locally

- `npm run godot:test:v0433-worker-economy` — passed focused economy and all-race building identity tests
- `npm run godot:smoke:v0433-worker-economy`
- `npm run godot:capture:v0433-worker-economy`
- `npm run godot:validate:v0433-worker-economy` — passed, schema v3 identity-repair
- `npm run godot:smoke:v0432-war-hall-production` — passed
- `npm run godot:validate:v0432-war-hall-production` — passed on the documented v0.433 descendant branch
- `npm test` — 122 test files / 887 tests passed
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run validate:runtime-art-slots`
- `npm run validate:artifact-retention`
- `npm run godot:all`
- `git diff --check`

## Closeout

The v0.433 branch remains stacked directly on accepted v0.432. The parent branch and PR #6 were not retargeted, merged, closed, or force-pushed.

## Published closeout proof

- Implementation commit: `fa8fb0516a80ebbfb6eac71bb1412281e78816e3`
- Stacked draft PR: `https://github.com/jardas33/ascendant-realms/pull/7`
- Exact-SHA GitHub Actions: run `30503818802` (`CI Release Matrix Dry Run`) completed with `success` for the implementation commit.
- The dedicated v0.433 validator passed before publication; its capture provenance is an ancestor of the implementation commit, and the pushed branch contains the report and review pack.
- Tracked working tree is clean after publication. Historical untracked backlog remains intentionally preserved and unstaged; no unrelated files were deleted or reset.
- Remote branch `origin/codex/v0433-multi-resource-worker-economy-loop` resolves to the implementation commit.

## R1 publication record

The original implementation and documentation publication remain preserved above. The identity/evidence repair is intentionally stacked on the same draft PR #7.

- Evidence/report commit: `e1d4ac1675d780c1848bc2d78084fa0b0a1d0c42`.
- Exact pushed branch: `codex/v0433-multi-resource-worker-economy-loop`.
- Exact-SHA GitHub Actions: run `30507590120` (`CI Release Matrix Dry Run`) completed with `success` for `e1d4ac16...`.
- The post-publication dedicated validator passed with `validationInputSha=e1d4ac16...`, identity repair `cc2ee707...`, and capture source `e322f15b...`; the validation schema contains no self-referential `finalCommitSha`.
- Final documentation refresh and its exact-SHA CI result are recorded by the closing commit and branch proof that follow this evidence update.
