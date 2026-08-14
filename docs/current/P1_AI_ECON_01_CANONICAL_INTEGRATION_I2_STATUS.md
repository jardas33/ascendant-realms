# P1 AI-ECON-01 — Canonical Integration I2 Status

## Classification

`PASSED_CANONICAL_INTEGRATION_I2_AI_ECON_PROJECTED_DROPOFF`

The accepted Easy-AI worker projected-dropoff repair is now integrated locally on
the canonical Godot baseline. The integration claim is deliberately bounded to
legitimate worker deposits, bank reconciliation, construction progression, and
housing completion. The broader Easy opening remains parked at the pre-existing
first-contact boundary.

## Repository and provenance

- Worktree: `D:\CodexData\worktrees\ascendant-realms-current-godot-baseline`
- Branch: `codex/current-godot-baseline`
- Starting canonical HEAD: `32db11e8e444540d466015a32056ca1228a4b55f`
- Specialist candidate: `f0ef4208208e169c86c381875e080f586fa1b9a6`
- Specialist parent: `32db11e8e444540d466015a32056ca1228a4b55f`
- Local production integration commit: `6e8c94ea35f6a2bc6dcfbb8b75fc712d7b00f06e`
- Production commit parent: `32db11e8e444540d466015a32056ca1228a4b55f`
- Integration commit message: `I2 integrate AI-ECON projected dropoff repair`
- Final canonical HEAD at this report: `6e8c94ea35f6a2bc6dcfbb8b75fc712d7b00f06e`

## Exact integrated source

Only this authored production path was integrated:

`production/ascendant-realms-godot/scripts/units/unit.gd`

The committed diff is exactly 9 insertions and 1 deletion. It preserves the
existing resource definitions, rates, costs, states, commands, difficulty, and
combat semantics. It accepts the existing deposit branch when a worker has
legitimately reached the authoritative navigation-projected drop-off target
within the existing arrival tolerance. No specialist evidence, stale metadata,
temporary telemetry, import files, UID files, or generated files were staged.

## Root cause and result

The Easy AI worker reached the walkable point projected around a friendly
drop-off, but `_state_return()` compared only the worker's position against the
unprojected building-center footprint threshold. The worker could therefore
remain in `RETURNING` with full cargo and never enter the existing deposit path.

After integration, the fresh official headed run recorded repeated real deposits
for timber, stone, food, and gold, reconciled bank deltas, placed Thornhall and
Lifewell with real resource debits, and reported `real_construction: true` with
housing count 1.

## Validation

Certified runtime:

- Godot: `4.6.3.stable.official.7d41c59c4`
- Executable: `D:\CodexData\tools\godot-4.6.3-stable\Godot_v4.6.3-stable_win64.exe`
- SHA256: `EF90E929BA1A6A4322860285D97F40F4AA349C90329A91B0E8B55B8DF0F4CB00`

Passed:

- official Godot 4.6.3 headless import/parse
- `node --check tools/godot/v0435EasyAiWaveTool.mjs`
- `node tools/godot/v0435EasyAiWaveTool.mjs focused-tests`
- `node tools/godot/v0435EasyAiWaveTool.mjs smoke`
- `node tools/godot/v0433WorkerEconomyTool.mjs focused-tests`
- `node tools/godot/v0434CombatTool.mjs focused-tests`
- `node tools/godot/v0433WorkerEconomyTool.mjs capture`
- `git diff --check` on the authored integration path

Smoke and focused runs retain the known Godot shutdown ObjectDB/resource-leak
warnings; no gameplay test failed because of them.

## Fresh current-source proof

Fresh Easy proof root:

`D:\CodexData\worktrees\ascendant-realms-current-godot-baseline\artifacts\manual-review\v0435-first-autonomous-easy-opponent-wave\`

The fresh official 4.6.3 headed run reached the economy, worker production,
building placement, housing, military construction, staging, and wave-launch
phases. It then stopped fail-closed at the known later assertion:

`v0.435 autonomous wave did not reach player contact`

This is recorded as a remaining PLAY-01C contact blocker, not an I2 economy
failure. The old `v0435-validation.json`, old later frames, and any metadata
whose source/branch does not match the current canonical run are excluded from
proof.

Fresh proof files and SHA256:

- `v0435-ai-deposit-ledger.json` — `637F3CCAFC9801F21333FC297DF25C80287C8CFD09B5320BE25B62EB2A868ABD`
- `v0435-ai-bank-reconciliation.json` — `1740285DB67AE8F3D1382141137993067E11D017DD8EE712BDC8131AC4DF642A`
- `v0435-ai-building-validation-audit.json` — `163BCD99E4067FFAF18D2EE2E0175A1A057AC074C10214FC5197C739D42BAF1E`
- `v0435-ai-housing-audit.json` — `D41C8BDF8C0B9E94333BCAAC06A854B80D25029FD5E1C348F852679C9BFA64E5`
- `07_V0435_AI_HOUSING_CONSTRUCTION.png` — `56BC9622003B702AFCE4F0FF7E0E6D0E40176167B8E58A64945A91086E375B32`
- current v0433 normal economy validation — `1AF41F52F059953552A047848EC8D4452079B8AD657EC98287F61B9FC4F1398B`

The housing frame was visually inspected and is a real 1920x1080 gameplay-scale
render showing terrain, units, resource piles, minimap, and the constructed
Lioraen housing structure. It is not a title card or blank frame.

## Protected-state and scope confirmation

- No push, PR mutation, merge, promotion, or remote action.
- Protected checkout was not modified.
- No destructive Git operation, rebase, reset, or broad cleanup.
- Ambient generated/import/evidence drift remains preserved and unstaged.
- No balance, economy design, stable ID, save, movement, navigation, combat,
  AI difficulty, or victory semantics were broadened.

## Remaining yellow blocker and next safe priority

`YELLOW_PLAY01C_EASY_WAVE_FIRST_CONTACT_NOT_REACHED`

Create the fresh PLAY-01C lane from this new canonical HEAD. Do not use the old
PLAY-01B lane or the AI-ECON specialist branch. Treat the first failed current
transition as the next causal frontier; do not fold a broad combat rewrite into
the opening rehearsal.

