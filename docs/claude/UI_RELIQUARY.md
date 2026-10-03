# Reliquary HUD (UI direction A)

The battle HUD is being rebuilt to art direction A, "Reliquary": the interface
is a relic forged by the player's people, with Lume light in its seams that
grows with each Age. Rules: `docs/claude/UI_ART_PILLARS_R1.md`.

## Where it lives

| File | Role |
| --- | --- |
| `scripts/ui/reliquary/rq_kit.gd` (`RqKit`) | The only source of colours, type sizes, fonts, people materials, Age light, spell glyph map, and the shared painters (matter, worked edge, Lume seam, rivet, engraving, plate). |
| `scripts/ui/reliquary/reliquary_hud.gd` | `extends hud.gd`. Rebuilds the visuals and the layout; every signal, data handler and command action stays in `hud.gd`. |
| `rq_deck.gd` | Bottom chassis and minimap housing. Panels taller than the deck raise a shoulder instead of adding a frame. |
| `rq_ribbon.gd` | Top ribbon, Age medallion (Lume ring and three Age notches) and the Age plaque. |
| `rq_medallion.gd` | Octagonal portrait medallion. Its ring shows battlefield XP for heroes and construction progress for build sites. |
| `rq_tile.gd` | Every action surface: spells (cooldown sweep, mana cost, hotkey), orders, build/train/research cards, the menu button. |
| `rq_bar.gd`, `rq_tooltip.gd` | Vital gauges; smoked-glass tooltip used for command tips, world hover and heralds. |
| `assets/ui/kit/glyphs/*.svg` | 43 vector glyphs (white, tinted at draw time). Imported lossless at 2x with mipmaps. |
| `assets/fonts/` | Cinzel 600/700 (display) and Alegreya Sans 400/500/700 (body), both SIL OFL. |

`scripts/world/game_root.gd` creates the Reliquary HUD. `ASCENDANT_HUD=classic`
brings back the previous HUD for side-by-side captures.

## Rules for anyone extending it

- No colour, size or edge treatment outside `RqKit`. A new people adds one
  entry to `RqKit.PEOPLES`; nothing else changes.
- Painted art only for identity: portraits, buildings, crests. Actions use the
  vector glyphs. A new spell needs one line in `RqKit.ABILITY_GLYPHS` (and a
  new SVG only if no existing gesture fits).
- Light means state. Ready spells glow; recovering spells darken under a sweep;
  short mana turns the cost red. Nothing glows for decoration.
- Labels placed inline in a row must use `_rq_inline()`: hud.gd's ellipsis
  trimming otherwise lets the row squeeze them to nothing.
- Layout is done in the HUD's local space. On small windows the HUD scales up
  so it never drops below 85% of its 1080p size (`RQ_MIN_UI_SCALE`).

## Verifying a change

The cloud can render the real game. From `production/ascendant-realms-godot`:

```
ASCENDANT_UI_VALIDATE=1 ASCENDANT_UI_CLEAN_POINTER=1 ASCENDANT_UI_SIZE=1920x1080 \
ASCENDANT_UI_SELECT=hero ASCENDANT_UI_CENTER_SELECTED=1 ASCENDANT_UI_FRAMES=60 \
ASCENDANT_UI_OUTPUT=/tmp/hero.png xvfb-run -a -s "-screen 0 1920x1080x24" \
godot --path . --rendering-driver vulkan --resolution 1920x1080 -s res://tests/ui_review_capture.gd
```

`ASCENDANT_UI_SELECT` also takes `building`, `worker`, `military`,
`construction`, `war_hall`. The validator in `tests/ui_review_capture.gd`
knows the Reliquary layout (crest in the Age medallion, glyph tiles, no
command header).

## Next

1. Campaign map, Chronicle and skill constellation in the illuminated style of
   direction B.
2. Menus and modal screens on the same kit.
