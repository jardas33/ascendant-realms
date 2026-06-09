# v0.177 Prompt: Terrain Material Opt-In Integration

Execute this bounded goal exactly as written.

# v0.177 - Godot Salto terrain-material single opt-in integration and human-review stop

## Run condition

Run only after v0.176 passed, was committed, pushed, clean, synced, and remote-green.

Expected prior message:

`Checkpoint v0.176 terrain-material opt-in player-slice integration readiness packet`

## Purpose

Integrate exactly one terrain-material player-slice opt-in slot using the v0.175 selected Barrosan foothold ground-material derivative.

Use zero new images.

Add exactly one terrain-material slot.

Do not add character slots.

Do not replace broad terrain systems.

Do not enable art by default.

Do not wire the browser runtime.

Do not begin v0.178.

## Approved Candidate

Use only:

- Candidate: `GROUND_MATERIAL_LOCAL_1024`
- File: `artifacts/desktop-spikes/godot-salto/v0175/local-ground-material-slot/barrosan_foothold_ground_material_v0175_1024.png`
- SHA-256: `818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8`

Preserve v0.175 private comparator source, derivatives, fallback, metadata, and evidence.

## Integration Scope

Add one explicit opt-in launcher for the existing five-slot Godot Salto player-facing review slice plus one terrain-material slot.

Recommended launcher:

- `GODOT_LAUNCH_SALTO_FIVE_SLOT_TERRAIN_MATERIAL_EXPERIMENT_WINDOWS.bat`

Recommended wrappers:

- `GODOT_VALIDATE_SALTO_FIVE_SLOT_TERRAIN_MATERIAL_EXPERIMENT_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_FIVE_SLOT_TERRAIN_MATERIAL_EXPERIMENT_WINDOWS.bat`

Bind the material only to the constrained battlefield base ground surface. Keep roads, shoulders, river, bridge, site markers, approach lanes, minimap, structures, HUD, units, and VFX procedural.

## Required Fallback Proof

Prove both:

- Missing selected terrain material falls back to procedural ground.
- Hash-mismatched selected terrain material falls back to procedural ground.

Fallback modes must keep the selected Worker, Barracks material, Militia, Aster, and Ashen slots active when the new opt-in launcher is used.

## Required Visual QA

Capture and review:

- Title and briefing labels.
- Full battlefield.
- Close material view.
- Normal RTS gameplay distance.
- Zoomed-out gameplay view.
- Road network.
- River and banks.
- Bridge crossing.
- Site markers.
- Five-slot coexistence.
- Combat onset/readability.
- Missing-art fallback.
- Hash-mismatch fallback.

Fail the gate if roads, bridge, river banks, site markers, selection rings, minimap, or unit silhouettes become less readable and cannot be repaired within this single-slot scope.

## Required Performance QA

Benchmark:

- M0 default procedural baseline.
- M5 five-slot opt-in baseline.
- M5+T1 terrain-material opt-in.
- Missing-art fallback.
- Hash-mismatch fallback.

Gate:

- M5+T1 average-FPS ratio versus M5 must be `>= 0.90`.
- M5+T1 p95 frame-time worsening versus M5 must be `<= 15%`.

## Required Boundaries

Prove:

- Default launcher remains procedural.
- Stabilized launcher remains procedural.
- Prior opt-in launchers remain preserved.
- Browser runtime untouched.
- No production package leakage.
- No save or stable-ID mutation.
- No gameplay/objective/AI/balance/campaign mutation.
- Exactly one terrain-material slot added.
- No sixth character slot added.

## Cleanup

Run retention validation and cleanup dry-run. Delete only positively identified safe transient residue through existing safe-only tooling if and only if the prompt scope explicitly permits it. Preserve selected local art, derivatives, metadata, tracked fallbacks, latest required evidence, historical evidence, and unknown files.

## Docs

Create the future v0.177 QA, benchmark, fallback, boundary, and implementation docs required by the implementation. Update standard docs/index.

Commit exactly:

`Checkpoint v0.177 Godot Salto terrain-material single opt-in integration and human-review stop`

Push safely and stop.

Return visual decision, fallback proof, benchmark, cleanup state, boundaries, commit, CI, and confirmation v0.178 was not started.
