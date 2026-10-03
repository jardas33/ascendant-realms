# UI overhaul: plan, state and handoff

Last updated: 2026-10-03. Owner today: Claude. Written so Codex (or anyone)
can take over at any step without asking.

**Branch:** `claude/project-thread-h7p2wb` (based on `claude/perf-placeholders-r1`).
**Art rules:** `docs/claude/UI_ART_PILLARS_R1.md`. Read it first; every rule
below comes from it.

## 1. Decisions already made (do not reopen)

| Decision | Why |
| --- | --- |
| Direction A, **Reliquary**, for the battle HUD. The UI is a relic forged by the player's people; Lume light in its seams grows with each Age. | Fastest to read in battle, and per-people materials give every faction its own look with one layout. Picked from three real-game mockups (A Reliquary, B War Codex, C Lumen). |
| Direction B's illuminated manuscript style goes to the **campaign map, Chronicle and skill constellation**, not the battle HUD. | It is the most distinctive look, but too slow to read under pressure. |
| No GUI design tools (Penpot, Affinity, Cavalry, Figma). Everything is code: Godot `_draw()` painters plus SVG glyphs. | Emanuel cannot operate design tools, and code is reproducible by any agent. |
| **No AI-generated or bought art.** Painted art only for identity (portraits, buildings, crests from the existing Codex astra_r1 set). Actions use vector glyphs. | Emanuel: "if the art is crappy then better not do it". Earlier AI art was judged horrendous. Spend no money. |
| One source of truth for style: `RqKit` (`scripts/ui/reliquary/rq_kit.gd`). It is the token file. | A new people or Age is a data change, never new drawing code. |
| The new HUD **extends** `hud.gd` and overrides only builders and layout. Every signal, handler and command action stays in `hud.gd`. | Gameplay code keeps working; `ASCENDANT_HUD=classic` brings the old HUD back for comparison. |
| Every screen is checked by rendering the real game in the cloud before it counts as done. Emanuel does not playtest. | He has no time to test; renders plus the validator are the gate. |

## 2. Plan and status

| # | Step | Status |
| --- | --- | --- |
| 1 | Pillars, three directions, pick A | Done (artifact https://claude.ai/artifact/PGCvbHJHsyTPPKv5TgAeKV) |
| 2 | Kit: tokens, fonts (Cinzel, Alegreya Sans, OFL), 43 glyph SVGs, painters | Done |
| 3 | Battle HUD: top ribbon, Age medallion, objective, minimap housing, deck, unit and building dossiers, spell tiles, orders, cards, tooltips, heralds, toasts, build-site card, min UI scale for small windows | Done, render-validated |
| 4 | Validator in `tests/ui_review_capture.gd` updated for the Reliquary layout | Done (military, building, worker, construction, hero, 1366 views) |
| 5 | PR into `claude/perf-placeholders-r1` | Open: https://github.com/jardas33/ascendant-realms/pull/11, CI green |
| 6 | **Skill constellation** in style B: `scripts/ui/codex/star_chart.gd` now drives `scenes/ui/skill_tree.tscn` (old `skill_tree.gd` kept, unused). Radial chart, 8 paths from the hero crest, keystones on gilt rings, codex page, claim button, zoom/pan, label collision. Kit: `scripts/ui/codex/codex_kit.gd`, `codex_button.gd` | Done (first pass), renders reviewed |
| 7 | **Campaign map** (`scripts/ui/campaign_map.gd`, 1208 lines, `campaign_region_button.gd`) in style B: illuminated map of the Terras Frias, region seals, chapter cards with the saga text | Done 2026-10-03: `scripts/ui/codex/saga_map.gd` subclasses the old script and redraws it (inked chart, Act seal strip, wax chapter seals, hero standard, codex briefing page with opening line and Chronicle entry); the Act title card is restyled there too. `campaign_map.tscn` points at it |
| 8 | Chronicle / saga log screen in style B (new or inside campaign map) | Done 2026-10-03: `scripts/ui/codex/codex_chronicle.gd` (open book: contents page with unwritten chapters, reading page). Also `codex_endless.gd`, the Endless Road folio. Both opened from `saga_map.gd` |
| 9 | Menus and modals on RqKit: `main_menu.gd`, `pause_menu.gd`, `settings.gd`, `skirmish_setup.gd`, `hero_creation.gd`, `hero_sheet.gd`, `inventory.gd`, `gilt_confirm.gd`, `tutorial.gd` | In progress: action buttons on the display face (hero sheet, war chest, settings, hero creation), hero sheet record shown as a ledger, "The Star Chart" button. Tried Alegreya as the project body font (`gui/theme/custom_font`) and reverted: its small x-height made 12-14 px menu text unreadable; a body-font switch needs every size raised ~2 px first |
| 10 | Page-by-page audit of every screen at 1920x1080 and 1366x768 (no stretched frames, no clipped text, no frame inside frame) | Started 2026-10-03: campaign map, star chart, Chronicle and Endless Road pass at 1366x768 (the project stretches the 1920 layout, so they scale cleanly). Pause menu fixed (stays centred, spell keys on two rows, crest follows the plate; `ASCENDANT_UI_PAUSE=1` on the HUD capture opens it). gilt_confirm checked over the star chart (`ASCENDANT_UI_CALL=_on_respec`), clean. Still to audit: menus at 1366, tutorial, loading screen, in-battle modals |
| 11 | Retire old styling helpers (`ornate_panel_style.gd`, `hud_plate.gd`, inline StyleBoxFlat in hud.gd) once nothing uses them | Not started |

How to do steps 7 to 9: use the style B kit `CodexKit` (`scripts/ui/codex/codex_kit.gd`: night vellum, leather page, gilt rules, vermilion capitals, wax seal, Cormorant Garamond), then rebuild each screen the same way as the HUD:
subclass or restyle, keep its logic, render, compare against the B frame in
`/mnt/project-files/notes/ui/r1_mockups`, fix, repeat.

## 3. Where the HUD code lives

| File | Role |
| --- | --- |
| `scripts/ui/reliquary/rq_kit.gd` (`RqKit`) | Colours, type sizes, fonts, people materials (`PEOPLES`), Age light (`AGE_LUME`), spell glyph map (`ABILITY_GLYPHS`), shared painters (matter, worked edge, Lume seam, rivet, engraving, plate). |
| `scripts/ui/reliquary/reliquary_hud.gd` | `extends hud.gd`. Rebuilds visuals and layout (`_fit_to_viewport`). |
| `rq_deck.gd` | Bottom chassis and minimap housing. Panels taller than the deck raise a shoulder instead of adding a frame. |
| `rq_ribbon.gd` | Top ribbon, Age medallion (Lume ring and three Age notches), Age plaque. |
| `rq_medallion.gd` | Octagonal portrait medallion. Ring shows battlefield XP for heroes, construction progress for build sites. |
| `rq_tile.gd` | Every action surface: spells (cooldown sweep, mana cost, hotkey), orders, build/train/research cards, menu button. |
| `rq_site.gd` | Build site card: three stages on a Lume rail, percent, workers on site. |
| `rq_bar.gd`, `rq_tooltip.gd` | Vital gauges; smoked-glass tooltip for command tips, world hover, heralds, toasts. |
| `assets/ui/kit/glyphs/*.svg` | 43 white vector glyphs, tinted at draw time. Imported lossless at 2x with mipmaps. |
| `assets/fonts/` | Cinzel 600/700 (display), Alegreya Sans 400/500/700 (body), SIL OFL. |

`scripts/world/game_root.gd` creates the Reliquary HUD.

## 4. Rules for anyone extending it

- No colour, size or edge treatment outside `RqKit`. A new people adds one
  entry to `RqKit.PEOPLES`; nothing else changes.
- A new spell needs one line in `RqKit.ABILITY_GLYPHS` (and a new SVG only if
  no existing gesture fits; unknown ids fall back to the `lume` glyph).
- Light means state. Ready spells glow; recovering spells darken under a sweep;
  short mana turns the cost red. Nothing glows for decoration.
- Labels placed inline in a row must use `_rq_inline()`: hud.gd's ellipsis
  trimming otherwise lets the row squeeze them to nothing.
- Layout is done in the HUD's local space. On small windows the HUD scales up
  so it never drops below 85% of its 1080p size (`RQ_MIN_UI_SCALE`;
  `ASCENDANT_UI_MIN_SCALE=0` turns it off).
- Never frame inside frame. Cards sit on the deck; only the chassis has ornament.

## 5. Verifying a change

The cloud (Linux, no GPU) renders the real game with Godot 4.6.3, mesa
lavapipe and xvfb. On Windows, drop `xvfb-run` and run Godot directly.
From `production/ascendant-realms-godot`, after one `godot --headless --import`:

```
ASCENDANT_UI_VALIDATE=1 ASCENDANT_UI_CLEAN_POINTER=1 ASCENDANT_UI_SIZE=1920x1080 \
ASCENDANT_UI_SELECT=hero ASCENDANT_UI_CENTER_SELECTED=1 ASCENDANT_UI_FRAMES=60 \
ASCENDANT_UI_OUTPUT=/tmp/hero.png xvfb-run -a -s "-screen 0 1920x1080x24" \
godot --path . --rendering-driver vulkan --resolution 1920x1080 -s res://tests/ui_review_capture.gd
```

- `ASCENDANT_UI_SELECT`: `hero`, `building`, `worker`, `military`,
  `construction`, `war_hall`.
- `ASCENDANT_UI_HERO_SPELLS=rally,slam,sig_bull,bar_horn` grants spells to the
  hero so spell tiles render (a fresh profile has none).
- `ASCENDANT_UI_TOOLTIP_CHECK=1 ASCENDANT_UI_TOOLTIP_TITLE="Rallying Cry"` opens a tooltip.
- The log prints `UI_VALIDATION PASS` or the list of failures.
- `tests/claude_compileall.gd` compile-checks every script (`COMPILEALL bad=[]`).
- A cloud render takes about 7 minutes; run several in the background.

## 6. Current step and loose ends

- Battle HUD validated in the cloud on 2026-10-03: `hero` (with and without
  spells, tooltip open), `military`, `worker`, `building` and `construction`
  at 1920x1080, `hero` and `building` at 1366x768. All `UI_VALIDATION PASS`.
- `war_hall` (scrolling barracks list) has not been re-rendered on the new HUD.
- Current step: step 9, menus and modals. Renders: `ASCENDANT_UI_CALL=_open_chronicle`,
  `_open_endless:24` or `_show_act_card:1` opens a modal on the screen under test. Menus render with
  `tests/zz_screen_capture.gd` (`ASCENDANT_UI_SCENE=res://scenes/ui/skill_tree.tscn`,
  `ASCENDANT_UI_REVIEW_HERO=1` for a level 12 review hero, `ASCENDANT_UI_SELECT_STAR=act_4`,
  `ASCENDANT_UI_FLY_PATH=active`). Campaign map: `ASCENDANT_UI_SCENE=res://scenes/ui/campaign_map.tscn`
  with `ASCENDANT_UI_REVIEW_SAGA=1` (three chapters walked) and `ASCENDANT_UI_SKIP_ACT_CARD=1`.
- A hero with no learned spells shows four empty "Unlearned" sockets; the
  validator checks for those sockets instead of spell tiles.
