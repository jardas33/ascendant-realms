# v0.241 Barrosan Opt-In Playable Runtime Skin

Verdict: `PARTIAL`

## Outcome

- The explicit opt-in scene subclasses the actual Salto 2.5D gameplay scene; it is not a standalone diorama.
- `command_hall`, `barracks`, and `west_stone_cut` are skinned at their real runtime positions while retaining their existing gameplay state and commands.
- House, farm, lumber, blacksmith, watchtower, and market do not exist as live simulation entities. Their imported modules are review-safe, non-interactive placeholders and are labeled only in mapping/debug evidence.
- Default launch and the default 2.5D scene remain unchanged.
- Blender used: no.
- New GLB exported: no.
- The v0.239 GLB was reused unchanged.

## Retained assets

- Mapping: `res://data/v0240_barrosan_playable_art_mapping.json`.
- GLB: `res://assets/v0239/salto_barrosan_roster_silhouette_beauty.glb`.
- Retained GLB SHA-256: `B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB`.

## Runtime behavior

- Existing unit selection, barracks selection, construction progression, production, camera, HUD, objectives, pathing, AI, economy and saves are unchanged.
- The selected barracks receives a restrained runtime ring; unselected buildings have no persistent label clutter.
- Valid and blocked placement previews are evidence-only render states. No placement or collision rule was changed.
- Runtime systems touched: scene selection, player-slice evidence actions, visual rebuilding, runtime selection presentation, and evidence manifests.
- Gameplay systems untouched: simulation rules, economy, production costs/timing, build rules, collision, pathing, commands, AI, objectives, minimap logic, stable IDs, and saves.
- Fully mapped live roles: `main_base`, `barracks`, `mine`.
- Review placeholders: `house`, `farm`, `lumber`, `blacksmith`, `watchtower`, `market`.
- Placement/footprint status: completed footprints are visual-only; valid/blocked preview proof is not connected to build-rule evaluation.

## Exact source files changed

- `desktop-spikes/godot-salto/scenes/salto_barrosan_playable_runtime_skin.tscn`
- `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd`
- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
- `tools/godot/captureGodotV0241BarrosanPlayableRuntimeSkinWindows.ps1`
- `tools/godot/validateGodotV0241BarrosanPlayableRuntimeSkinWindows.ps1`
- `tools/godot/buildV0241BarrosanPlayableRuntimeSkinReviewPack.py`
- `tools/godot/saltoV0241BarrosanPlayableRuntimeSkinTool.mjs`
- `package.json`
- `docs/V0241_BARROSAN_PLAYABLE_RUNTIME_SKIN_REPORT.md`

## Validation results

- `npm test`: PASS (122 files, 887 tests).
- `npm run build`: PASS.
- `npm run godot:test`: PASS.
- `npm run godot:all`: PASS, including Windows export and package.
- `npm run validate:content`: PASS.
- `npm run validate:art-intake`: PASS.
- `npm run validate:runtime-art-slots`: PASS (52 stable slots).
- `npm run godot:validate:salto-experimental-artifact-retention`: PASS.
- `npm run godot:validate:salto-barrosan-playable-runtime-skin`: PASS.
- `git diff --check`: PASS.
- Retained v0.239 GLB SHA-256: `B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB`.

## Honest assessment

The live runtime wiring and default boundary are proven, but the visual result is not strong enough for opt-in gameplay testing. The imported buildings are readable yet visually tiny and disconnected inside the legacy procedural battlefield; the six absent roles remain scenery rather than entities; and the placement previews are evidence overlays, not build-system feedback. The lane is technically useful as integration scaffolding, but calling it a finished runtime skin would oversell it.

Ready for opt-in gameplay testing: no.

Stop after v0.241. Do not begin v0.242.
