# v0.207 Salto UI Architecture Style Lock

## Status

PASS candidate pending validation. This checkpoint defines an original Barrosan fantasy RTS HUD direction for the isolated Godot Salto review path.

## Reference Use Boundary

The attached reference is used only as a benchmark for hierarchy, density, and finish. The implementation must not copy its art, portraits, motifs, geometry, icon silhouettes, fonts, text, color recipe, logos, buildings, characters, or exact layout proportions.

## Original Style Direction

- Panel bodies: charcoal-black, wet-stone, and smoked timber values.
- Trim: restrained iron and weathered bronze, never ornate gold filigree.
- Friendly accent: muted teal/aether for Aster, Lume, valid commands, and map focus.
- Resource accent: warm stone/iron/crown chips with low saturation.
- Hostile accent: controlled ashen ember, reserved for pressure alerts and enemy markers.
- Shape language: practical Barrosan field equipment, straight readable planes, low-radius corners, compact RTS density.
- Typography: built-in Godot text for now, medium-size labels with strong contrast and no negative tracking.

## Locked HUD Regions

- Top center resource ledger for Crowns, Stone, Iron, Aether, population, and review-mode status.
- Left objective and event stack for current goal, recent feedback, and progression warnings.
- Bottom-left minimap with terrain, road, river, bridge, friendly, hostile, objective, and camera cues.
- Bottom-center selected context panel for Aster, Worker, structures, Militia, and Ashen targets.
- Bottom-right build/train/research command surface with grouped tab states and disabled reasons.
- Right alert rail for Ashen pressure and mission-critical notices.
- Contextual tooltip lane above bottom commands.

## Non-Goals

- No player-facing production enablement.
- No browser runtime wiring.
- No default launcher mutation.
- No gameplay, pathing, collision, objective, AI, economy, save, stable-ID, or balance change.
- No generated image, downloaded asset, or copied reference asset.

## Review Pack

Deterministic review PNGs are produced under:

`artifacts/manual-review/v0207-ui-architecture/`

The pack contains a HUD wireframe, component map, and gap-analysis frame.
