# v0.436 G0 Runtime Startup Investigation

## Result

`PASSED_G0_COLD_IMPORT_ENVIRONMENT_ONLY`

The reported long startup failure was reproduced only against a cold checkout import state. After the certified Godot 4.6.3 editor import completed, ordinary menu startup, the automated startup path, and the F2 startup path all reached `GameRoot`, `GameWorld`, HUD, and a loader-settled first playable frame. No startup-sequence re-entry was observed.

The optional existing `v0436_r1h_capture.gd` autoload still emits its pre-existing parse errors (`initial_count` and `bank_before` type inference), so the F2 capture autoload itself does not instantiate. That is recorded as a separate harness finding; it was not repaired because it was not causal to the G0 startup stall and direct G0-C still reached the playable frame.

## Scope and safety

- Base: `07e55140acd737433dce9f14565310320aa0355a`
- Parent: `e3134b023192495cbca38ca51e057c529acf55ef`
- Branch: `codex/local-runtime-startup-g0`
- Worktree: `D:\CodexData\worktrees\ascendant-realms-runtime-startup-g0`
- Protected checkout was not modified: `D:\Code for projects\WB game like\ascendant-realms-v0223-recovery`
- No push, PR mutation, merge, promotion, v0.437, R1K, save, stable-ID, gameplay, economy, or combat change was made.

The only repository changes are tool-owned startup observation/validation files, the G0 package commands, the stage map, and this report. The observer writes only evidence outside the repository and uses the same Barrosan/Lioraen Easy/Hollowspan/Rich/Conquest/2.0x match configuration as the authorized opt-in startup path.

## Certified environment

- Godot: `4.6.3.stable.official.7d41c59c4`
- Executable: `D:\CodexData\tools\godot-4.6.3-stable\Godot_v4.6.3-stable_win64.exe`
- SHA-256: `EF90E929BA1A6A4322860285D97F40F4AA349C90329A91B0E8B55B8DF0F4CB00`
- Evidence root: `D:\CodexData\evidence\ascendant-realms-runtime-startup-g0\`
- Logs: `D:\CodexData\logs\ascendant-realms-runtime-startup-g0\`
- Runtime/cache diagnostics: `D:\CodexData\runtime\ascendant-realms-runtime-startup-g0\`

The Godot CLI help was captured before use. The editor import was run without deleting caches, and the generated import cache was allowed to populate on D:.

## Startup stage map

`startup-stage-map.md` records the observation-only chain:

1. project and autoload boot;
2. main menu;
3. normal skirmish selection;
4. match configuration;
5. loading overlay entry;
6. synchronous preload sequence;
7. scene swap;
8. GameRoot/GameWorld construction;
9. first playable HUD frame;
10. loading overlay exit.

The observer records loader busy/progress/cache state, scene changes, GameRoot/GameWorld/HUD readiness, loader settlement, and screenshots. Its parse check passed with the certified Godot binary.

## Runs and evidence

Final evidence is in:

`D:\CodexData\evidence\ascendant-realms-runtime-startup-g0\FINAL\`

The final pack contains a real main-menu frame, loading-entry and progress frames, two ordinary menu-equivalent runs, an automated run, an F2-path run, and a settled gameplay/HUD frame. The settled gameplay images were visually inspected and are not loading/title-card frames.

| Run | Path | Result | Approx. startup duration | Evidence |
| --- | --- | --- | ---: | --- |
| Ordinary run 1 | `G0-A5` | GameRoot + GameWorld + HUD + settled frame | 23.6 s | `04_GAMEWORLD_ORDINARY_RUN1.png`, `07_FIRST_PLAYABLE_HUD.png` |
| Ordinary run 2 | `G0-A6` | GameRoot + GameWorld + HUD + settled frame | 23.8 s | `05_GAMEWORLD_ORDINARY_RUN2.png` |
| Automated | `G0-B2` | GameRoot + GameWorld + HUD + settled frame | 23.4 s | `07_FIRST_PLAYABLE_HUD.png` |
| F2 startup path | `G0-C2-F2hook` | GameRoot + GameWorld + HUD + settled frame | 24.1 s | `06_GAMEWORLD_F2_HARNESS.png` |

All three required post-observation execution classes reached a first playable frame. Each had one startup invocation. Progress was monotonic in the recorded traces; no loader re-entry was observed.

The consolidated machine-readable record is `FINAL\startup-manifest.json`. It includes run statuses, stage timings, invocation counts, Godot identity, screenshot sizes and SHA-256 hashes. `FINAL\cold-import-blocker-ledger.json` records the initial cold-cache observations and the separate pre-existing capture-hook parse errors.

## Cold-cache finding

The initial cold run showed missing `.godot/imported` resources, missing imported scene/texture artifacts, and script-cache/class-resolution diagnostics. The certified editor import then populated the project cache. Warm B, A, C, and repeated A runs reached the playable frame without any preload re-entry.

This supports `PASSED_G0_COLD_IMPORT_ENVIRONMENT_ONLY`, not a production preload-loop claim. No global shader disable, content skip, asset deletion, random asset removal, or production loading change was made.

## F2 hook finding

The existing optional capture autoload reports:

- `res://tests/v0436_r1h_capture.gd:523` — `initial_count` type inference parse error;
- `res://tests/v0436_r1h_capture.gd:528` — `bank_before` type inference parse error;
- dependent `v0436_r1j_capture.gd` and `v0436_r1k_capture.gd` instantiation failures.

The G0 observer’s C mode intentionally used the same configuration and F2 environment without the F2 capture autoload as a causal dependency. It reached GameWorld/HUD and saved a real settled gameplay frame. The hook parse defect is therefore a separately bounded future candidate, not a reason to change production startup in G0.

## Validation

Passed:

- `npm run godot:validate:v0436-g0-runtime-startup`
- `npm run godot:test:v0436-g0-runtime-startup` — 3 tests
- `npm test` — 134 files / 954 tests
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run validate:runtime-art-slots`
- `npm run godot:all` with the certified `GODOT_BIN` — exit 0
- `git diff --check`
- certified Godot observer parse check

`npm run validate:artifact-retention` remains the known historical `FAIL_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION` diagnostic for missing retained v0.148/v0.150/v0.155/v0.152/v0.157/v0.175/v0.180/v0.189/v0.202 artifacts. It was reproduced and left unchanged; G0 did not repair historical retention debt.

## Exact local changes

- `startup-stage-map.md`
- `tools/godot/v0436G0StartupObserver.gd`
- `tools/godot/v0436G0StartupValidator.mjs`
- `tools/godot/v0436G0StartupValidator.test.ts`
- `package.json` — two dedicated G0 commands
- this report

No production runtime file was changed. The final candidate is ready for the authorized local commit and ChatGPT audit handoff.
