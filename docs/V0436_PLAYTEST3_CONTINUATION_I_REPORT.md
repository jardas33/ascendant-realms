# Ascendant Realms — Playtest 3 Continuation I Report

## Scope

Continuation I was run from accepted source `896bd9355602a76b9157b497c0ac5f8623e12941` on the isolated branch `codex/local-playtest3-continuation-i`. The current local presentation tip is `c9da810022be93aada908ce417b7bafd7e51f4c0`. The authorized bounded lanes were:

- I0: certify the portable Godot runtime and establish whether a normal headed run is ready for gameplay evidence.
- I2: improve the real player-facing command panel without changing command semantics.
- I3: improve minimap framing and tactical readability without inventing new map geometry.
- I4: make construction state visibly truthful without changing build rules or timings.

I1 normal Easy combat-retention matches were not run because I0 did not satisfy the authorized runtime-ready gate.

## I0 runtime result

The official portable Godot 4.6.3 stable runtime was certified outside the repository at:

`D:\CodexData\tools\godot-4.6.3-stable\Godot_v4.6.3-stable_win64.exe`

Version: `4.6.3.stable.official.7d41c59c4`.

`npm ci`, dependency resolution, the cold import, and two headed startup attempts succeeded at the process level. The production scene reached Forward+ and `GameWorld`, but each headed attempt reached the existing R1H economy-stalled endpoint after roughly 221 seconds. Because the requirement was GameWorld plus playable HUD within 180 seconds, `I0_RUNTIME_READY=false`.

Evidence:

- `D:\CodexData\logs\ascendant-realms-playtest3-continuation-i\I0_NPM_CI.log`
- `D:\CodexData\logs\ascendant-realms-playtest3-continuation-i\I0_COLD_PREP.log`
- `D:\CodexData\logs\ascendant-realms-playtest3-continuation-i\I0_HEADED_WARMUP.log`
- `D:\CodexData\logs\ascendant-realms-playtest3-continuation-i\I0_WARM_START_CONFIRMATION.log`

This is not an H1/Easy gameplay verdict. No I1 gameplay result is claimed.

## I2 command panel

`production/ascendant-realms-godot/scripts/ui/hud.gd` now gives the existing command panel a clearer player-facing hierarchy:

- widened the panel from the previous 334px contract to a centralized 390px presentation width;
- increased the two-column command cards to 174px by 62px with clearer spacing;
- added explicit BUILD, TRAIN, RESEARCH, and CONSTRUCTION section labels with short action guidance;
- added existing resource/portrait-frame icon treatment, `[READY]`/`[LOCKED]` state tags, costs, and disabled-action tooltips;
- removed keyboard-focus noise from action cards while preserving their existing button text, disabled states, costs, tooltips, and callbacks;
- exposed live construction percentage in the command card and selected-building card.

No action, button meaning, production rule, affordability rule, or command callback changed.

The first fresh capture attempt failed closed because the driver captured the world before the HUD surface existed. A second attempt exposed a real Godot 4.6.3 runtime exception from the unsupported `Button.icon_max_width` property; the driver synchronization and property-removal repairs were committed locally before the final pack.

## I3 minimap

The existing minimap remains the same coordinate projection and input target. It now has:

- a `TACTICAL MAP` header;
- a compact ally/enemy/structure/view legend;
- an explicit bridge cue derived from the existing `world.map["bridge"].pos` definition;
- a deterministic tactical miniature derived from live map/world data: terrain edge/start zones, water overview shape, road/bridge geometry, capture points, buildings, units, resources, and the camera rectangle;
- the existing input transform and world/gameplay geometry unchanged.

No new navigation geometry, route, terrain, resource, or gameplay data was added.

## I4 construction presentation

The construction model presentation in `scripts/buildings/building.gd` no longer sinks by `footprint * 0.9`. It remains grounded with a restrained `-0.15` starting offset and rises to zero as progress reaches 100%. A small non-colliding timber-post/beam stage visual is shown only while construction is incomplete. Existing transparency and completion semantics are unchanged. The authored worker animation library has no dedicated work-prop clip; the existing runtime safely falls back to its authored idle clip, so no unsupported animation claim is made.

## Fresh visual evidence

The fresh real runtime capture is:

- `D:\CodexData\evidence\ascendant-realms-playtest3-continuation-i\I2_I3_1366_selected.png`
- geometry manifest: `D:\CodexData\evidence\ascendant-realms-playtest3-continuation-i\I2_I3_1366_selected.json`

SHA-256: PNG `F31C70743364B4DC2AC57D0CA4EDC95AC2351779E28B0EBEBF520559DDCEB8AD`; manifest `DB2D2689602D41537876E874C325EEC8B6E540C6A4A421A663CDE83966E00A9D`.

The PNG is a non-blank 1366x768 gameplay frame. It visibly contains the revised tactical-map header/legend, bridge cue, BUILD section and readable two-column command cards, selection card, and normal game scene. The manifest reports `all_visible_surfaces_inside=true` for the top bar, minimap, selection panel, command panel, menu button, and result surface.

The focused final R22 pack is:

- root: `D:\CodexData\evidence\ascendant-realms-playtest3-continuation-i\P1R22\run-20260810025424-c9da8100`;
- aggregate manifest: `D:\CodexData\evidence\ascendant-realms-playtest3-continuation-i\P1R22\p1r22-capture-manifest.json`;
- validator report: `D:\CodexData\evidence\ascendant-realms-playtest3-continuation-i\P1R22\p1r22-validator-report.json`;
- source SHA: `c9da810022be93aada908ce417b7bafd7e51f4c0`;
- 8/8 manifests PASS, with 1920x1080 and 1366x768 images, visible HUD surface, 5/3 command buttons as applicable, and PNGs above the capture threshold.

Final fresh PNG hashes include worker 1920 `8CF68801954393AB824A4ACCCA1B58176AA278B6A17F76261D440560ECDD8E13`, HQ `A31B0216067484AD3504FA63FBA7A6581DE2179E61C5E6DCA5DC2F671D2CEC42`, and worker 1366 `D2912DE48C7729F9771AE36811D1FDE83331ECAF2106CCB6089274A15D4E6518`.

## Validation

Passed:

- `npm test` — 134 test files, 954 tests passed.
- `npm run build` — TypeScript and Vite production build passed.
- project-level Godot parse/import: `Godot_v4.6.3-stable_win64.exe --headless --editor --path production/ascendant-realms-godot --quit` — exit 0.
- `npm run godot:all` — exit 0 for the repository orchestration; its doctor/package subreports still say `BLOCKED_PENDING_LOCAL_GODOT_SETUP` because they only discover a PATH/editor-managed Godot, while the certified portable runtime was used explicitly above. The repository command itself did not fail.
- `git diff --check` — passed.

The warm-start log SHA-256 is `F8485BD362CEAD4A0459C0B5D9362B974D9E4ADA7F421D8D6893076ACBCCD2A8`.

The two direct isolated-script checks were not used as project validation because those scripts depend on the project autoload contract (`GameData` and `Sfx`). The project-level Godot invocation is the valid parse check.

The continuation-specific R22 validator passed against the fresh evidence root: 8/8 headed frames are mapped to actual PNGs and contain live command-card buttons. The retained P1-R3/P1-R16/P1-R17/P1-R19/P1-R20/P1-R21 validators were not green for this continuation because their retained manifests carry older source SHAs and, where checked, report scope contamination from Godot-generated or previous review artifacts. They were not silently counted as passing.

## Safety and preservation

- Source base remains `896bd9355602a76b9157b497c0ac5f8623e12941` before this local presentation pass. Local source commits are `e41c852d`, `04fe40f9`, `3bc44783`, `989bbfbf`, `8db90f28`, `1cf0591f`, `3dd4107d`, `b987f684`, and `c9da8100`.
- Work is isolated at `D:\CodexData\worktrees\ascendant-realms-playtest3-continuation-i`.
- Protected checkout `D:\Code for projects\WB game like\ascendant-realms-v0223-recovery` was not modified.
- No push, PR mutation, merge, promotion, v0.437, R1K, save, stable-ID, economy, combat, AI, navigation, movement, or balance change was made.
- Godot/import and prior capture runs produced generated or pre-existing dirty artifacts in the continuation worktree; those are not part of this source commit and are not broadly cleaned or staged.

## Classification and next priority

Classification: `I0_BLOCKED_RUNTIME_NOT_READY_WITHIN_180S__I2_I3_I4_PASS_LOCAL_PRESENTATION_LANES__R22_EVIDENCE_GREEN`.

The immediate next safe priority is to resolve the already observed startup/economy-stall blocker in a separately authorized gameplay lane before claiming I1 Easy combat evidence. The UI/minimap/construction pass is locally validated and does not justify balance tuning or a broader renderer rewrite.
