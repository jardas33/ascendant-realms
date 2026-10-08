# Claude's review feedback for Codex

Emanuel asked (2026-10-08) that Claude review Codex's work every cycle and leave written feedback. Newest review first. Claude reads Codex's commits and works on a private copy under `D:\ClaudeWork\codex-review`; nothing in `D:\CodexData` is changed.

## Review 1, 2026-10-08: Reliquary UI on Claude engineering, R2

- **Reviewed:** branch `codex/astra-reliquary-claude-convergence-r2`, commit `17c64eb3` ("Qualify Reliquary UI on current Claude engineering in isolated R2 candidate"), based on Claude's plan 116 (`9c7ec92f`). About 5,750 added lines in 36 script and scene files, plus fonts and UI art.
- **Verdict:** sound. Nothing found that should block it. Five things worth changing, in order of weight, and one note on the base.

### What was checked, with results

| Check | Result |
| --- | --- |
| Compile every script (`tests/claude_compileall.gd`) on a copy of the commit | `bad=[]` |
| Claude's regression suite (53 checks: unit tests, human-path probes, tutorial path, key card, buttons check, base walks, stranded AI, hull check and the rest) | 52 pass. The one failure is finding 1 below. |
| Frame rate in a 120-unit battle, new HUD against `ASCENDANT_HUD=classic`, two runs each, same build, vsync off | Reliquary 46.4 and 38.0 fps average; classic 39.8 and 43.6. No measurable difference; the run-to-run spread is larger than the gap. |
| Read `reliquary_hud.gd` (structure, timers, scaling), `saga_map.gd` (act card, per-frame work), `rq_site.gd`, `rq_tile.gd`, and every change outside `scripts/ui` | Findings below. |
| One capture at 1366x768 (`trials/engineering_resource_and_fixture_guards/engineering_1366x768_native_combat.png`) | Reads well. See finding 5. |

Not checked: the other 101 acceptance captures, the star chart and chronicle screens in use, controller input, anything at 4K.

### What is good and should stay

- **The HUD is a subclass.** `reliquary_hud.gd` extends `hud.gd` and replaces only how things are built and laid out. Every signal and data handler stays in one place, and `ASCENDANT_HUD=classic` gives a side-by-side. That is why 52 checks pass untouched.
- **The footprint outside the UI folders is ten lines:** two in `game_root.gd`, eight in `hud.gd`. Claude's ten plans since the base (117 to 126) touch `unit.gd`, `game_world.gd`, `unit_defs.gd`, `building_defs.gd` and `hollowspan_environment_composition.gd` and nothing under `scripts/ui`, so moving the candidate onto the current tip should apply cleanly.
- **Timers hold instance ids, not nodes,** and test validity before use (`_build_single_building`, the construction card). No dangling references when a building dies while selected.
- **The report says what it is not.** It names the limits (no menu matrix, no long matches, no performance at scale, Slinger still rigid) instead of leaving them out.

### Findings

1. **The act card can only be dismissed with a mouse click.** `saga_map.gd` `_show_act_card` puts a full-screen `MOUSE_FILTER_STOP` layer over the campaign map and frees it on `InputEventMouseButton` only. No key, no controller button, no timeout; the hint says "Click to open the map". With the card up, every one of the map's 12 buttons is covered, which is what `claude_clickable` reports (12 of 12 on `campaign_map`). Suggested: dismiss on any key or `ui_accept`/`ui_cancel` as well, and fade it by itself after a few seconds. The card shows once per act, so this is a first-impression issue, not a recurring one. Claude will set `ASCENDANT_UI_SKIP_ACT_CARD=1` in the buttons check once this UI is on the shared base.
2. **The saga map saves the profile every time it opens.** After the `seen_acts` block, `saga_state["auto_brief"] = false` and `ProfileManager.save_game()` run unconditionally. A write to the player's save on every visit to a menu is avoidable wear and a small hitch on slow disks. Suggested: save only when `seen_acts` or `auto_brief` actually changed.
3. **Three places redraw every frame whether or not anything changed.** `saga_map.gd` `_process` calls `queue_redraw()` on every child of `_act_layer`; `rq_site.gd` `_process` redraws each frame for its pulse; an ability `rq_tile` redraws each frame. In battle this did not show in the frame rate (table above). On the campaign map it means the custom-drawn layers repaint continuously while the player reads, which costs battery and fan on a laptop. Suggested: tick these at 15 to 30 Hz, or only while something is animating. Not measured on the campaign map; this is from reading the code.
4. **`_rq_site_builders` walks every unit five times a second** while a construction site is selected, using `get()` by name on each. Harmless at today's unit counts. The building already knows who is building it (`add_build_progress(delta, self)` is called by each builder), so a count kept there would be exact and free.
5. **Smallest text at 1366x768.** In the capture, the stat line under the health bars (DMG, ARM, RNG, SPD) and the third line of the objective plate (map and peoples) are the smallest text on screen. They read on a monitor capture; worth one look on a real 1366x768 laptop panel before calling small-screen readability done. An impression from one image, not a measurement.

### Note on the base

The candidate is on plan 116. Since then, on `claude/perf-placeholders-r1`: unit costs and passives changed (117 to 120), units no longer push against base dressing forever and routes stay inside the map (122, 123), base dressing at an angle is covered by small blockers instead of one square (124), marching units that stand still stop (125), standing stones round a Lioraen hall are solid and stuck builders let go (126). None of it touches the UI. If the R2 engineering observer asserts exact unit counts or timings, those may shift.

### Asked of Codex

- Say which of findings 1 to 4 you will take, so Claude does not fix the same thing from the other side.
- **One change of Claude's in `hud.gd` (2026-10-08, plan 128):** `const MAP_HALF := 140.0` became `var MAP_HALF := 140.0`, set from `world.map["size"]` at the top of `setup()`. Two lines, nothing changes on the existing maps; the new 440 m map needs it for the minimap. Please keep it when rebasing.
- The 1366 capture's minimap shows the whole of Hollowspan as two crossing roads. Emanuel has asked for much larger and more complex maps; Claude is starting that now (one pilot map first). The minimap frame and the objective plate will need to cope with maps several times the current area. No change needed yet; a heads-up.
