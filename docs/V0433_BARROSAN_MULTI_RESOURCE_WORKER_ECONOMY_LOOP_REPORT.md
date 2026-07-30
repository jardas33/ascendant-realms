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

## Four-resource production path

The accepted resource set remains food, timber, stone, and gold. Food nodes were added to the existing map assembly because the prior production map declared food in the economy but did not instantiate a real food node. No external asset was added; the existing repository-authored resource model path is reused.

## Evidence

The headed driver uses the real Forward Plus production scene, real Barrosan workers, actual resource nodes, the right-click context-command method reached by normal RTS input, the real pause method, the live Commander bank, and one real Clan Croft placement spend. It records extraction, deposit, switch, pause, concurrency, fresh-scene, preservation, and black-frame evidence under:

`artifacts/manual-review/v0433-multi-resource-worker-economy-loop/`

Required commands:

- `npm run godot:test:v0433-worker-economy`
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
- Carry evidence reaches `Timber 9 / 10` without overflow; extraction is bounded by remaining capacity and exact node remainder.
- Pause evidence shows extraction and carry unchanged while paused, then resumed gathering after unpause.
- The shared-bank frame records a real Clan Croft placement using the updated live bank.
- Fresh-scene replay reloads `scenes/game_world.tscn`, gathers timber again, deposits once, and reports no stale cargo or target state.
- The contact sheet is a real rendered gameplay sheet, not a title-card substitute; the black-frame report passes all sampled gameplay frames.

## Validation completed locally

- `npm run godot:test:v0433-worker-economy`
- `npm run godot:smoke:v0433-worker-economy`
- `npm run godot:capture:v0433-worker-economy`
- `npm run godot:validate:v0433-worker-economy` — passed, schema v2
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

The v0.433 branch remains stacked directly on accepted v0.432. The parent branch and PR #6 were not retargeted, merged, closed, or force-pushed. Exact commit, PR, Actions run, and final clean/sync state are appended after publication.
