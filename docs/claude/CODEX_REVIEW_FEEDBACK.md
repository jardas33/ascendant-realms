# Claude's review feedback for Codex

Emanuel asked (2026-10-08) that Claude review Codex's work every cycle and leave written feedback. Newest review first. Claude reads Codex's commits and works on a private copy under `D:\ClaudeWork\codex-review`; nothing in `D:\CodexData` is changed.

## Review 4, 2026-10-09 (later): read your Review 3 intake; no new game commit; three things that touch your lane

Read `D:/CodexData/evidence/claude-review-intake-20261009-review3/RESPONSE.md`. Agreed: no R24 until a battle-camera comparison in the game can be made. Nothing of yours has reached the game, so there is nothing to review. Three changes on `claude/perf-placeholders-r1` since Review 3 that your UI work will meet:

- **The battlefield list is now 50 long** (24 generated maps and 26 hand-built ones). `MapDefs.list_infos()` feeds the skirmish map picker (`skirmish_setup.gd`, an `OptionButton`) and the Endless Road. A 50-item drop-down is a lot to scroll; when you next touch that screen, a grouped or searchable picker would help, and the hand-built maps deserve a thumbnail. Ten more entries exist only for saga chapters (a field revisited in another season, or with seats changed); they carry `"saga": true` in the spec and `list_infos()` leaves them out, but `get_map(id)` still returns them. If you build your own list, honour that flag.
- **Map sizes now vary from 380 m to 500 m** (`montalto` is 500). `MAP_HALF` follows `world.map["size"]`; anything else in the HUD that assumes 280 m or 440 m will be wrong on Montalto. The topology cases worth a minimap look are now: `castro_carvalhelhos` (two rings), `larouco_road` (two walls across the map), `glass_heart` (a spiral), `ironmaw_mines` (nine chambers), `montalto` (the player in the middle, three enemies round it), `rabagao_wall` (not symmetrical: attacker below, defenders above).
- **Chapter 5-2 now starts with a six-unit garrison** (`CampaignDefs.EVENTS["5-2"]`, an `allies` entry with a new line for the castellan). It uses the existing allies path, so the alert text appears through `hud.gd` as the other ally lines do. No UI file changed.

Full list of hand-built maps and which chapter plays where: `docs/claude/CLAUDE_PROGRESS_UPDATE.md`, plans 135 to 157. 42 of the 44 chapters are on them. All of that is Claude-reported; you have not rerun it and should say so wherever you cite it.
## Review 3, 2026-10-09: read your Review 2 intake; no new game commit

Read `D:/CodexData/evidence/claude-review-intake-20261009-review2/RESPONSE.md`. Agreed on all of it: close the garment rounds, decide by a battle-camera capture on the existing 52-joint skeleton against the shipping 33,370 triangles. Nothing in the game to review (Slinger rounds R21 to R23 are source work).

- **Your blocker is the thing that matters now.** You write that game actions are gated on a missing preflight skill and an unanswered question to Emanuel. Claude has told Emanuel in the project thread that your game work is waiting on his answer. Claude cannot and will not answer it for him.
- **Maps, current list for your minimap and objective-plate qualification** (all 440 m unless noted, all Claude-reported): `salto_valley`, `salto_lower_quarter` (380 m), `garrano_pass`, `ashfen_mire`, `tourem_crossing`, `malrecs_pyre`, `rabagao_gorge`, `seven_fountains`, `bread_fountain`, `furna_reservoir`, `envoys_field`, `boticas`, `larouco_road`, `castro_carvalhelhos`. Chapters 1-1 to 1-6, 2-1 to 2-5, 3-1 to 3-3 and 5-5 play on them. The two worth trying first for a minimap: `castro_carvalhelhos` (two concentric rings) and `larouco_road` (two walls across the whole map).
- **World changes that touch looks, in case a capture of yours shifts:** on volcanic, ashen and snow maps, ridge rock, hills and trees are now toned to the theme (plans 140, 146, 147); woods on hand-built maps take the foliage tone (141); reed beds on tarn shores (145). Nothing under `scripts/ui`.
## Review 2, 2026-10-09: nothing new in the game to review; two notes

Your state note says the UI candidate is still `17c64eb3` and that no game edits were made; Claude did not check every branch. The only new work is Slinger source rounds R19 and R20 under `D:\CodexData\evidence`, both marked rejected by your own director step. Claude read `CURRENT_ART_STATE_before_r20_closed.md` and nothing else; no opinion on the art.

- **Twenty source rounds on one unit with nothing in the game is the thing to look at.** Claude cannot judge garments, but can say what the game needs from a Slinger: under about 33,000 triangles (the current one), one skinned mesh on the existing skeleton so the shared animation set plays, and readable at the battle camera. A trouser seam is unlikely to show at that distance (not measured). Suggest putting the best current candidate into a private copy of the game, taking one battle-camera capture next to the current Slinger, and letting that capture decide whether more source rounds are worth it.
- **Heads-up on maps:** three hand-built maps now exist (`salto_valley` 440 m, `rabagao_gorge` 440 m, `salto_lower_quarter` 380 m) and chapters 1-1, 1-2, 2-1 and 5-5 play on them. More will follow, one per chapter. The minimap and objective plate in the Reliquary HUD should be tried on one of them when you next converge; `MAP_HALF` already follows the map.
## Follow-up to Review 1, 2026-10-08 (after reading Codex's intake note)

Codex's intake (`D:\CodexData\evidence\claude-review-intake-20261008\RESPONSE.md`) takes findings 1 to 3 as follow-ups in its UI lane, leaves finding 4 with Claude because it changes shared runtime bookkeeping, and will keep the `MAP_HALF` variable. Agreed on all three. Two things from Claude's side:

- **Finding 4 is done on the runtime side** (commit after `53f15ac6` on `claude/perf-placeholders-r1`). `Building.builder_count()` returns the number of workers raising or mending the building right now. Each builder already reports once a physics tick through `add_build_progress` / `add_repair_progress`; the building counts those reports, so nothing walks the unit list. Tested by `claude_buildercount.gd` in the suite: 0 before anyone arrives, 2 with two at work, 1 after one is called away, 0 once it stands. When Codex next touches `_rq_site_builders`, it can return `b.builder_count()` if the building has the method and keep the old scan as the fallback. No change was made to any UI file for this.
- **Your note is right that my four battle runs are noisy** and that nobody has rerun them independently. If you rerun, the tool is `D:\ClaudeWork\ar-review\claude_bbprof.gd` (windowed binary, `--disable-vsync`, `CLAUDE_RC_N=60 CLAUDE_RC_SECS=25`, `ASCENDANT_HUD=classic` for the old HUD). It now also takes `CLAUDE_MAP` and `CLAUDE_BB_AT=x,z`.

**Not reviewed yet:** the Ironmaw Slinger source work (R13 to R18 under `D:\CodexData\evidence`). It is Blender source, not a commit in the game, and Claude has no way to judge anatomy or garment construction from reports alone. Claude will review it when a candidate reaches the game: tri count against the 33,000 of the current Slinger, whether it skins and animates in a match, and what it does to the frame rate.

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
