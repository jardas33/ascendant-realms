# v0.436-R1D Headed Godot Startup Recovery

## Status

`PASSED_V0436_R1D_HEADED_STARTUP_RECOVERY_R1C_NOT_RUN` for the startup gate. R1C was then resumed and reached real natural-conquest frames, but its bounded result wait expired with `match_ended=false` before result/replay evidence; that separate production blocker remains open.

## Scope and preconditions

- Branch: `codex/v0436-first-complete-conquest-victory`
- Exact source SHA: `f05ba19f8398d1a1bfd01bbe31b05fe3eeff1779`
- Remote remained synchronized before the R1D edits.
- Existing user-owned/generated dirty files were preserved; no reset, clean, restore, broad deletion, or mass staging was used.
- R1D was limited to headed Godot launch diagnostics, capture tooling, provenance, and reports.

## Root cause and repair

Windows recorded repeated `Godot_v4.3-stable_win64.exe` Application Error events with exception `0xc0000005`, faulting module the Godot executable itself. The reproducible launch failure occurred when Godot 4.3 was started with the previous hidden-window/absolute-or-nested `--log-file` contract. The same reviewed executable rendered a real frame when started in a normal headed window without that Godot logging flag. The spaced repository path also required explicit argument quoting; otherwise Godot opened Project Manager instead of the production project.

The smallest repair was therefore tooling-only:

- use a real headed window;
- quote the production project path;
- omit Godot `--log-file` from the R1C launch contract and keep the log filename local to the session working directory;
- use the project’s normal Forward Plus/default renderer unless explicitly overridden;
- add a capture-only startup frame hook and structured R1D validator;
- add the R1C capture-only menu bypass so the opt-in driver reaches `scenes/game_world.tscn`.

No gameplay source, balance, economy, AI, navigation, combat, conquest rule, HUD semantics, result state, or save behavior was changed.

## Executable and environment evidence

- Official URL: `https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_win64.exe.zip`
- Archive SHA-256: `8f2c75b734bd956027ae3ca92c41f78b5d5a255dacc0f20e4e3c523c545ad410`
- Fresh executable: `%LOCALAPPDATA%\AscendantRealms\tools\godot-4.3-stable-r1d-probe\official-extracted\Godot_v4.3-stable_win64.exe`
- Current and fresh executable version: `4.3.stable.official.77dcf97d8`
- Current/fresh executable SHA-256 recorded in the diagnostic JSON.
- Host: Windows 11 build `26200`, AMD64, NVIDIA GeForce GTX 1070, driver `32.0.15.8228`, 1920×1080 desktop.

## Startup matrix

The matrix was run without using headless output as visual proof.

- Current binary, normal headed minimal project: real rendered frame.
- Fresh official binary, default/project renderer minimal project: real rendered frame.
- Fresh official binary, explicit GL Compatibility minimal project: real rendered frame.
- Fresh official binary, production project default renderer: real rendered 1280×720 production frame.
- Three consecutive headed production starts with the same configuration remained alive for 32 seconds and each wrote a genuine production frame.
- The renderer contact sheet contains actual rendered minimal/production images.

The primary production frame was visually inspected and shows the actual Ascendant Realms menu and authored background, not a blank frame, black frame, Project Manager, or title card.

## R1C resumption result

After the startup gate passed, R1C was resumed with the fresh reviewed executable. The corrected entry path reached the actual production game and wrote real frames through the conquest predicate, plus live configuration, production transaction, and assault-navigation audits. The bounded natural-conquest result wait then expired with `match_ended=false`; no genuine victory result, Continue, Play Again, fresh-replay, or final result-HUD proof was produced. The truthful status is:

`BLOCKED_R1C_NATURAL_CONQUEST_NOT_RESOLVED_AFTER_REAL_FRAMES`

The R1C validator remains fail-closed. The partial frames are not promoted to a conquest-result pass.

## Files and commands

- Diagnostic tool: `tools/godot/v0436R1DHeadedStartupRecoveryTool.mjs`
- Startup hook: `production/ascendant-realms-godot/tests/v0436_r1d_startup_capture.gd`
- R1C launch correction: `tools/godot/v0436R1CConquestResultReplayTool.mjs`
- Opt-in menu routing repair: `production/ascendant-realms-godot/scripts/main_menu.gd`
- Diagnostic command: `npm run godot:diagnose:v0436-r1d-headed-startup`
- Dedicated validator: `npm run godot:validate:v0436-r1d-headed-startup`
- Review pack: `artifacts/manual-review/v0436-r1d-headed-godot-startup-recovery/`

## Validation

Passed:

- `npm run godot:diagnose:v0436-r1d-headed-startup`
- `npm run godot:validate:v0436-r1d-headed-startup`
- exact source SHA and branch checks
- real headed frame and nonblack sample checks
- three consecutive 32-second production stability checks
- no headless substitution check

The R1C focused/smoke/validator ladder remains available and the R1C validator is intentionally blocked by missing final result/replay evidence. The new R1C production blocker is recorded in `artifacts/manual-review/v0436-r1c-natural-conquest-result-replay-proof/r1c-production-blocker.json`.

## Final disposition

R1D startup recovery is proven. R1C natural conquest result/replay proof is not complete. P0-RESULT-001 remains open. No v0.437 work was started.
