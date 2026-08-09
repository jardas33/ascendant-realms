# v0.436 E3R Step-8 Natural Lume Capture and Tutorial Completion Repair

## Scope

This bounded repair addressed only the real E3R Step-8 tutorial closure defect. It did not alter capture gameplay semantics, combat, economy, navigation, map geometry, victory logic, or the true default runtime.

## Pre-repair reproduction

The fresh headed run used the normal main-menu How to Play entry, real player units, public movement orders, the real central Lume Spire CapturePoint, and no state injection. Telemetry sampled the live point and units for 142 samples at a nominal 0.1 second cadence. The units entered the authoritative 7.5 m capture radius, team 0 was counted, progress reached 1.0, and owner_team naturally became team 0.

The first failed invariant was tutorial recognition: the tutorial transitioned from Step 8 to completion, but its completed state reported step_index 8 because the snapshot was capped at the number of tutorial steps. The E3R wait for completion index 9 could therefore never observe completion.

## Repair

- production/ascendant-realms-godot/scripts/ui/tutorial.gd: completed snapshots now report step_index = 9.
- production/ascendant-realms-godot/tests/v0436_r1h_capture.gd: added read-only Step-8 telemetry, canonical isolated final captures, and real completion-button routing audit.
- production/ascendant-realms-godot/scripts/main_menu.gd: isolated final-run menu capture output when the E3R repair output root is explicitly provided.
- Added the dedicated v0436-e3r-step8-repair validator and package commands.

Capture radius remained 7.5 m and capture rate remained 0.35. Contest and benefit semantics remained unchanged.

## Final evidence

The authoritative final evidence is outside the repository at:

D:\CodexData\evidence\ascendant-realms-core-playability-e\E3R_STEP8_REPAIR\FINAL\

It contains the required 18 frames, 142-sample telemetry, the generated repair manifest, and the passing validator JSON. 14_STEP8_LUME_OWNED.png shows natural ownership, 15_TUTORIAL_COMPLETE.png shows the completion panel, and 16_RETURN_TO_MAIN_MENU.png shows the real normal menu after exercising the completion Button. Earlier blocked attempts are preserved beside FINAL and are not presented as success evidence.

## Validation

- npm run godot:test:v0436-e3r-step8-repair
- npm run godot:validate:v0436-e3r-step8-repair
- Existing E3R validator and retained validators
- Full repository test/build/content/art/runtime/artifact checks
- npm run godot:all
- git diff --check

No push, PR mutation, merge, promotion, R1K, v0.437, or protected-checkout mutation occurred.
