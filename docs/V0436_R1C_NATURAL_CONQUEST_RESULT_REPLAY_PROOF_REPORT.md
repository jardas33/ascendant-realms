# v0.436-R1C Natural Conquest, Result, Continue, and Play Again Proof

## Status

`BLOCKED_HEADED_GODOT_SIGNAL_11`

R1C is intentionally fail-closed. The new capture and validator path is implemented, but the first authorized headed capture session never reached the production scene: the installed Godot 4.3 executable crashed during headed startup with Windows signal 11. No Victory, result, Continue, Play Again, or fresh-replay claim is made.

## Scope and preflight

- Branch: `codex/v0436-first-complete-conquest-victory`
- Required HEAD: `1ef22db8809719b0fbb9d399d7f1897aa993467c`
- Upstream: exact match, `0 ahead / 0 behind`
- PR #10 remains open, draft, and unmerged against `codex/v0435-first-autonomous-easy-opponent-wave`.
- Initial R1C worktree ownership count: 6 tracked dirty paths and 3,130 untracked files. Those paths were preserved.
- Final pre-publication working state after scoped R1C edits: 15 tracked dirty paths and 3,132 untracked files. The additional tracked paths are the R1C source/package wiring; the additional untracked paths are the isolated R1C pack and capture source.
- After the scoped commit and retained validation commands, the final checkout has 12 tracked dirty paths and 3,130 untracked files. These are preserved/generated non-R1C artifacts; `git diff --check` is clean and no scoped R1C path remains dirty.

No reset, clean, restore, broad staging, or deletion was used.

## Why the capture is blocked

The authorized command was:

`npm run godot:capture:v0436-r1c-conquest-result-replay`

Session A launched the production Godot 4.3 executable with the exact R1C source SHA and branch. It produced no rendered frame and no production-scene audit. The process remained alive without advancing to the capture scene, so it was stopped safely. A direct headed production diagnosis reproduced the same environment failure:

`Godot_v4.3-stable_win64.exe --path production/ascendant-realms-godot --resolution 1280x720 --rendering-method gl_compatibility --quit-after 10`

Result: `CrashHandlerException: Program crashed with signal 11` before a runtime log or scene frame was produced. A headless display-driver run still exits normally, and the focused/smoke gameplay gates pass; headless output is not substituted for the required headed proof.

## R1C evidence-integrity implementation

The new isolated capture path is:

- `production/ascendant-realms-godot/tests/v0436_r1c_capture.gd`
- `tools/godot/v0436R1CConquestResultReplayTool.mjs`
- `artifacts/manual-review/v0436-r1c-natural-conquest-result-replay-proof/`

It is opt-in through `ASCENDANT_V0436_R1C_CAPTURE=1`, records the exact source SHA/branch/production scene/session/timestamp, and uses two bounded sessions only when headed execution is available:

- Session A: natural Victory, actual `Continue` button action, and destination proof.
- Session B: second natural Victory, actual `Play Again` button action, and fresh-scene proof.

The runner reads live match configuration, navigation, unit transforms/velocity, resource transactions, queues, combat damage, projectile/building ledgers, destruction, conquest state, result snapshot, HUD nodes, freeze samples, scene identity, and fresh replay state. It does not write AI state, HP, death, destruction, defeat, result, match state, or post-initialization positions. It does not emit the old HUD replay signal directly; it locates and activates the actual `Button` node.

The old `v0436-first-complete-conquest-victory` pack remains historical and is not accepted as R1C evidence. Its original hardcoded success fields and direct replay emission are not reused.

## Validation evidence

Passed before the headed attempt:

- `npm run godot:test:v0436-r1-navigation-repair`
- `npm run godot:smoke:v0436-r1-navigation-repair`
- `npm run godot:validate:v0436-r1-navigation-repair`
- `npm run godot:test:v0436-r1-navigation-behavior`
- `npm run godot:smoke:v0436-r1-navigation-behavior`
- `npm run godot:validate:v0436-r1-navigation-behavior`
- `npm run godot:test:v0436-r1-boundary-recovery`
- `npm run godot:test:v0436-conquest-victory`
- `npm run godot:smoke:v0436-conquest-victory`
- `npm run godot:test:v0436-r1c-conquest-result-replay`
- `npm run godot:smoke:v0436-r1c-conquest-result-replay`

The dedicated R1C validator was run and failed closed because the headed process produced no rendered session evidence. It reports the missing runtime audits/frames, missing genuine result/UI/replay evidence, and does not convert the blocker into a pass.

The full repository test/build/content/art/runtime ladder and exact-SHA publication are not claimed for this blocked capture checkpoint. No production gameplay source, balance, economy, AI, conquest rule, visual, HUD, portrait, minimap, menu wording, command-panel, or unrelated gameplay code was changed.

The scoped publication commit is `dec93d7ad3af338328abb156de87ad51677afee9`. Exact GitHub Actions run `30599677742` completed successfully for that SHA. The PR remains open, draft, and unmerged.

## Backlog and next safe action

`P0-RESULT-001` remains open. `P0-NAV-001` remains accepted for focused R1/R1A/R1B behavior and still requires monitoring during natural conquest. The safest next action is to restore a functioning headed Godot 4.3 execution environment, then rerun the bounded R1C capture without changing gameplay values or adding a new milestone.

## Final disposition

This is a truthful R1C tooling-and-blocker record, not a completed natural conquest proof. Do not close P0-RESULT-001, do not claim Continue/Play Again success, and do not start v0.437.
