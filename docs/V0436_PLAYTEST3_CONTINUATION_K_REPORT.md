# v0.436 Playtest 3 Continuation K Report

## Scope

K is the bounded beginner-economy qualification lane. It restores the untuned Easy baseline, then runs one deterministic, normal public-action opening benchmark before any player attack is issued. K1 is not an Easy-combat judgment and does not start K2.

## Exact base and candidate

- Worktree: `D:\CodexData\worktrees\ascendant-realms-playtest3-continuation-k`
- Branch: `codex/local-playtest3-continuation-k`
- K base: `e88261812b017f825014783bf40077d7c9ebbe4f`
- K0 commit: `1d44407a65991fae6f28477dac07ab1e2d27f698`
- K0 message: `K0 restore untuned Easy baseline`
- Current candidate before closeout: K0 plus the K1 harness/tooling/report changes listed below

The protected checkout remains `D:\Code for projects\WB game like\ascendant-realms-v0223-recovery` at protected SHA `ad4ef9f895a60748af3ac0be8def9028adaa9f6c`. It was not opened for mutation. No push, PR mutation, merge, promotion, R1K, v0.437, or destructive Git operation was performed.

## K0 result

K0 removed the temporary 300-second Easy opening grace from `production/ascendant-realms-godot/scripts/ai/enemy_ai.gd`. The accepted Easy baseline is therefore untuned again. No other production gameplay source was changed in K1.

## K1 benchmark contract

The harness launched the normal Barrosan versus Lioraen Easy match on Hollowspan with Rich resources at 2.0x speed. It used public placement, worker build/gather commands, HQ worker queues, housing placement, and War Hall queues. It issued no player attack or other player offense before the 600-second safety bound. The benchmark finished at simulation time 129.6 seconds after reaching its qualification predicates.

The trace records the required actions and their return values:

- `BUILD_WAR_HALL`
- `ASSIGN_WORKER`
- `BUILD_HOUSING`
- `BUILD_MORE_HOUSING`
- `TRAIN_WORKER`
- `QUEUE_MILITARY`
- `QUEUE_NEXT_MILITARY`

Every five simulated seconds the harness records resources, workers and worker classification, population, HQ/housing/War Hall state, foundations, queues, completed combatants, resource transactions, and intended next action fields. The public action ledger records resources and population before/after, prerequisites, result, reason, and target.

## Classification

`PASS_K1_BEGINNER_ECONOMY_DRIVER`

The normal opening produced a functioning economy, a completed War Hall, housing, seven peak workers, and five completed combat units. The final worker count is lower because the untuned Easy opponent later killed workers; that is observed pressure, not a failed production driver.

Final benchmark facts from the validated manifest:

- Samples: 26 five-second samples plus terminal sample
- Action records: 29
- Peak workers: 7
- Terminal workers: 3
- Housing: 1 completed housing building
- War Hall: 1 completed
- Completed combat units: 5
- Resource transactions: 11
- Player offense count: 0
- Simulation time: 129.6 seconds

All six worker-queue attempts in the worker-expansion ledger returned `{ok:true}` and completed. Military queue calls accepted the normal public queue path; later `Need more housing` returns are recorded as `QUEUE_NEXT_MILITARY` results rather than silently skipped. The attempted second housing placement returned the explicit `BUILD_PLACEMENT_FAILED` classification because no valid position was found. This is a harness-observed placement result, not a production-driver failure, and the first housing building was sufficient for the K1 qualification.

The benchmark therefore does not justify a gameplay production repair or balance edit. The accepted F1 comparison remains the reference that a functioning public production path can reach a larger force; K1 proves the shorter beginner opening reaches its own bounded threshold without state injection.

## Evidence

Evidence root:

`D:\CodexData\evidence\ascendant-realms-playtest3-continuation-k\`

The root contains the preflight and configuration records, action/economy/worker/production ledgers, six real rendered gameplay captures, the contact sheet, runner result, capture manifest, benchmark markdown, and validator summary. `02_K1_ECONOMY_AND_FORCE_READY.png` is a nonblank wide gameplay frame showing the active map, completed structures, units, resources, and minimap. `26_K1_CONTACT_SHEET.png` is the generated multi-frame overview.

Two rejected development attempts remain archived under the same D: evidence root:

- `rejected-attempt-telemetry-get` — initial worker telemetry used an invalid Godot `Object.get` call.
- `rejected-attempt-standard-config` — capture startup omitted the Rich configuration environment.

They are not presented as final proof. The final capture used the corrected worker record path and explicit Rich configuration. The raw benchmark/blocker JSON also preserves the failed second-housing placement coordinates as the engine's `1e99999` representation of `Vector3.INF`; the validator summary is the authoritative machine-readable K1 verdict and passed. This is documented rather than silently rewriting the captured evidence.

## Changed files

K1 changes are limited to the capture harness, package scripts, K1 tooling/tests, and this report:

- `package.json`
- `production/ascendant-realms-godot/tests/v0436_r1h_capture.gd`
- `tools/godot/v0436K1BeginnerEconomyTool.mjs`
- `tools/godot/v0436K1BeginnerEconomyTool.test.ts`
- `tools/godot/v0436K1BeginnerEconomyValidatorContract.mjs`
- `docs/V0436_PLAYTEST3_CONTINUATION_K_REPORT.md`

No production gameplay code was changed after K0. Generated Godot import/UID churn from the isolated capture environment was excluded from the candidate; the historical `FAIL_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION` condition remains untouched.

## Commands and validation

- `npm run godot:test:v0436-k1-beginner-economy` — passed
- `npm run godot:validate:v0436-k1-beginner-economy` — passed
- K1 final capture command — exit 0; manifest and real frames present
- `npm run godot:all` — exit 0; the repository's legacy doctor/report still records `BLOCKED_PENDING_LOCAL_GODOT_SETUP` because it does not discover the certified portable binary through its standard PATH contract. The K1 harness itself used the certified binary below and completed successfully.
- Godot: `D:\CodexData\tools\godot-4.6.3-stable\Godot_v4.6.3-stable_win64.exe`
- Godot SHA-256: `ef90e929ba1a6a4322860285d97f40f4aa349c90329a91b0e8b55b8df0f4cb00`
- `git diff --check` — passed for the K1 candidate paths

The standalone Godot script check still reports the repository's pre-existing shared-class warning when the capture script is checked outside its project class context; the actual imported project runtime completed the K1 capture successfully. Historical artifact-retention diagnostics remain inherited and were not repaired.

## Truthful next handoff

K1 is qualified. K2 has not started. The next safe step is for ChatGPT to issue the explicit K2 bounded instruction and its required contract. This candidate is local-only and must not be pushed or promoted.
