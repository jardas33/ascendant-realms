# Ascendant Realms — UI Art Pillars R1

Status: direction A (Reliquary) picked 2026-10-03; build notes in docs/claude/UI_RELIQUARY.md. Owner: Claude (UI art direction). Applies to every screen: battle HUD, menus, campaign, hero, skill constellation, War Chest.

## 0. The signature: the interface is an Ascension relic

The saga is about the Seventy-Seventh Ascension and Lume, remembered light. The UI is not a frame around the game; it is an object from inside the world: a relic forged by the player's people, with Lume sleeping in its seams.

- **Opening Age:** the relic is mostly matter: metal, wood, stone, leather. Lume shows only as a hairline in one seam.
- **Age of Iron:** structural metalwork thickens, heraldry is stamped into the chassis, the Age plaque gains a second ring.
- **Age of Lume:** the seams wake. Thin light runs through the chassis joints, the faction crest breathes, ready abilities carry a travelling glint.

Same layout, same components in all Ages. Only the material layer changes. A late-game screenshot should be recognisable from one cropped corner.

## 1. Rules that decide every pixel

1. **One structure, many skins.** Six master components (Surface, ActionTile, Portrait, Metric, Tooltip, Notice) plus Minimap and Progress. Factions and Ages are token skins, never separate implementations.
2. **Three surface tiers, never competing.**
   - Tier A, chassis: minimap housing, command deck, top ribbon, modal frames. The only place ornament lives.
   - Tier B, controls: abilities, build/train tiles, orders. Clean faces, state carried by light and edge, not by frames.
   - Tier C, information: numbers, bars, costs, cooldowns. Zero ornament.
3. **Ornament budget.** Gold/brass edge and filigree ≤ 10% of visible UI area. Ornament sits on corners, joints and the crest; never runs the full length of every edge.
4. **No nested perimeters.** A control inside a chassis shares the chassis edge; never frame-inside-frame-inside-frame. Max three depth planes (world, chassis, raised control).
5. **Light means state.** Glow is reserved for: ready ability, selected item, critical alert, Lume element. Nothing glows "for decoration".
6. **Identity dominates, orders recede.** In the selection deck the portrait and name are the heaviest mass, abilities second, generic orders (Attack Move/Stop/Hold/Patrol) are the quietest row.
7. **Never stretch art.** Painted pieces render at native ratio; frames are multi-slice (corners fixed, runs tile). Vector glyphs scale; painted portraits never get squashed.
8. **The world is the hero.** HUD occupies ≤ 18% of a 1920×1080 frame during battle (current: ~24%). Nothing floats over the centre third.
9. **Readable under pressure.** Essential numbers ≥ 15px at 1080p; names 24–30px; no tiny caps for essential information. Every state readable without colour (shape, icon or text also changes).
10. **Motion guides, never decorates.** 120–180 ms panel reveals, 1–2 px hover lift, number roll on gains, one ambient sweep on the crest every 6–8 s. Reduced-motion token turns all ambient motion off.

## 2. Materials (max five per faction)

| | Chassis | Edge metal | Inlay | Glass / Lume | Accent |
|---|---|---|---|---|---|
| Barrosan | blackened hammered iron | warm brass, rivets | oxhide leather | amber Lume, like heat in a forge seam | oxblood |
| Lioraen | dark living timber | verdigris bronze | root filigree | jade river-glass, Lume flows like water | moss gold |
| Vorthak | basalt and black iron | gunmetal, sharp | oxblood enamel | violet Lume trapped behind cracks | ember red |

Shared base (all factions): text ivory `#EDE3CF`, text secondary `#A79C88`, surface `#0F1113` at 92%, raised `#171A1D`.

## 3. Shape grammar

- **Barrosan:** rectangular and heavy, 45° clipped corners, thick lower lip, rivets at joints, symmetric.
- **Lioraen:** elongated arcs, leaf-point terminals, asymmetric sweeps, light embedded in the edge.
- **Vorthak:** inward notches, narrow verticals, broken symmetry, suspended crystal shards at joints.

## 4. Typography

- Display (names, titles): Cinzel (already shipped), tracked +2%, never below 18px.
- Body and numbers: a humanist sans with tabular figures (candidate: Alegreya Sans or Source Sans 3, both OFL/free). Numbers always tabular so counters do not jitter.
- Scale (1080p): 30 / 24 / 19 / 16 / 14. Labels may be 12px small caps only when the same information also has an icon.

## 5. Iconography

- Gameplay actions: one silhouette each, filling 80–90% of the square, readable at 32px.
- Painted art (portraits, building art, order paintings, crests): kept where it is already top quality (Codex astra_r1 set). Steel-disc skill glyphs are below the bar and will be replaced.
- Resource and status glyphs: crisp vector (SVG → Godot DPITexture with PNG fallback).

## 6. What is banned

Gold frame around every rectangle; per-card bespoke frames; glow on idle items; AI-generated text baked into art; one giant HUD painting sliced up; layout dictated by an image generator; tiny uppercase labels for essential data; components that only work at 1920×1080.

## 7. Golden screens (the acceptance set)

Battle: hero selected, worker build menu, HQ with queue, military group, construction in progress, tooltip open. Menus: main menu, campaign map, skill constellation, hero sheet, War Chest. Each at 1920×1080 and 1366×768. A screen is done only when the Godot capture matches the approved target and UI tests pass.
