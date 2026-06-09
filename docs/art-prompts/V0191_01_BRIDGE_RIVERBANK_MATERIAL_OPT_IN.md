# v0.191 Prompt: Bridge-Riverbank Material Opt-In Integration

Execute this bounded goal exactly as written.

# v0.191 - Bridge-riverbank material opt-in integration

## Run Condition

Run only after v0.190 passed, was committed, pushed, clean, synced, and remote-green.

Expected prior message:

`Checkpoint v0.190 bridge-riverbank material opt-in integration readiness packet only`

## Purpose

Add only the selected v0.189 wet-granite bridge-riverbank material as one normal-slice opt-in environment-material slot behind a new explicit launcher.

Use zero images.

Add exactly one bridge-riverbank material opt-in slot.

Do not generate, replace, or edit the selected source image.

Do not modify the default procedural launcher.

Do not wire anything into the browser runtime.

Do not alter gameplay, pathing, collisions, objectives, AI, saves, stable IDs, production, restoration logic, or campaign data.

Do not add any character slot.

Do not add broad stone replacement.

Do not begin v0.192.

## Selected Candidate

Use exactly:

- Candidate: `BRIDGE_RIVERBANK_MATERIAL_LOCAL_1024`
- File: `artifacts/desktop-spikes/godot-salto/v0189/local-bridge-riverbank-material-slot/barrosan_wet_granite_bridge_riverbank_material_v0189_1024.png`
- SHA-256: `638ce153d7a3d39db729dfa13ba05f3fb05c437c2802ab91b5cd248bd2036753`
- Source SHA-256: `342d058f4749e115569a82bf971bb409ccd63825f93b7428d346150ebd9d003a`
- Initial UV scale target: `0.70`
- Filter posture: linear with mipmaps.

## Scoped Surfaces

Bind only:

- Bridge abutment faces.
- Bridge retaining caps needed to ground the crossing.
- Riverbank retaining-edge stones immediately beside the river/ford edge.
- Small bridge-to-bank transition skirts where the road visually meets the crossing.

Do not bind:

- Base ground.
- Road beds, shoulders, or approach lanes.
- River water, ford water, foam, or water shaders.
- Structures, walls, roofs, rubble fields, site markers, selection rings, unit billboards, combat VFX, HUD, or minimap.

## Launcher

Add one explicit opt-in launcher and matching wrappers, preserving every existing launcher:

- `GODOT_LAUNCH_SALTO_GROUND_ROAD_BRIDGE_RIVERBANK_MATERIAL_OPT_IN_WINDOWS.bat`
- `GODOT_REVIEW_SALTO_GROUND_ROAD_BRIDGE_RIVERBANK_MATERIAL_OPT_IN_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_GROUND_ROAD_BRIDGE_RIVERBANK_MATERIAL_OPT_IN_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_GROUND_ROAD_BRIDGE_RIVERBANK_MATERIAL_OPT_IN_WINDOWS.bat`

The default player-slice launcher and stabilized review launcher must remain procedural.

## Fallback Gates

Prove:

- Missing selected bridge-riverbank material falls back to procedural bridge and riverbank visuals.
- Hash-mismatched selected bridge-riverbank material falls back to procedural bridge and riverbank visuals.
- Existing Worker, Barracks, Militia, Aster, Ashen Raider, ground material, and road material opt-ins remain active when their explicit path is used.
- The v0.189 private comparator fallback remains comparator evidence only.

## Visual Gates

Capture and review:

- Close bridge abutment view.
- Normal RTS gameplay distance.
- Zoomed-out gameplay view.
- Road-to-bridge transition.
- Riverbank beside water.
- Ground and road material coexistence.
- Five selected character-slot coexistence.
- Missing-art fallback.
- Hash-mismatch fallback.

Fail rather than broaden scope if roads, river water, bank shape, bridge hierarchy, character readability, rings, combat onset, minimap, or tactical crossing clarity regresses.

## Performance Gates

Benchmark:

- M0 default procedural baseline.
- M5 existing five-character-slot opt-in baseline.
- M5+G1+R1 existing ground+road material opt-in baseline.
- M5+G1+R1+B1 bridge-riverbank material opt-in.
- Missing-art fallback.
- Hash-mismatch fallback.

Required thresholds:

- M5+G1+R1+B1 average-FPS ratio versus M5+G1+R1 must be `>= 0.90`.
- M5+G1+R1+B1 p95 frame-time worsening versus M5+G1+R1 must be `<= 15%`.

## Cleanup And Retention

Preserve selected local art, active derivatives, metadata, tracked fallbacks, latest required evidence, historical review material, and unknown files.

Run cleanup dry-run only unless positively identified transient sidecars are present and the existing safe-only cleanup wrapper classifies them.

Do not delete or archive historical evidence.

## Docs

Create the implementation report, QA/benchmark report, boundary/rollback report, and update handoff/index/roadmap/changelog/checkpoint/checklist.

Commit exactly:

`Checkpoint v0.191 bridge-riverbank material opt-in integration`

Push safely and stop for human review.

Return selected hash, fallback proof, visual decision, performance result, cleanup state, boundaries, commit, CI, and confirmation v0.192 was not started.
