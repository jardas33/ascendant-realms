# v0.128 HUD Spec

v0.128 makes the Godot Salto player slice use a compact desktop RTS/RPG HUD for the 3-5 minute review path. The HUD remains procedural placeholder UI only.

## Required Surface

- Corner resource row: Crowns, Stone, Iron, and Aether.
- Current objective strip: one short objective at the top of the battle view.
- Selected entity card: Aster, Worker, or squad selection summary.
- Hero posture: health and ability readiness when Aster is selected or defaulted.
- Worker posture: mine or shrine support prompt when the Worker is selected.
- Squad posture: protect Aster and hold the road when multiple units are selected.
- Command row: Move, Attack, Hold, Work, and Lume.
- Pause affordance.
- More Details disclosure for extra review context.

## Constraints

- No final UI art.
- No imported images or generated art.
- No mobile card stack layout.
- No oversized panels that hide the battlefield.
- No developer jargon in the player-facing HUD.
- No save writes, stable-ID changes, browser-runtime changes, final engine choice, or full-port work.
