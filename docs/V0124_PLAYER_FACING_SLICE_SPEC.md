# v0.124 Player-Facing Salto Slice Spec

Status: implemented as a bounded Godot workflow spike.

The v0.124 default human-review path is `GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat`. It opens the packaged Godot Salto slice in a player-facing flow instead of the private adapter-review harness.

## Flow

1. Title: `JARDAS: Salto Foothold`, a small `Private visual-review slice` ribbon, and Start, Settings, Exit controls.
2. Briefing: one premise line and three objectives.
3. Battle: full-screen 2.5D `CLEAN_READABILITY` battlefield with compact HUD, selected-entity card, command buttons, objective strip, minimap, and pause affordance.
4. Results: short recap with Restart, Return to Title, and Exit.

## Boundaries

- Placeholder-only procedural Godot primitives.
- No image generation, downloads, imported art, final UI, save writes, stable-ID changes, or final Godot decision.
- The browser prototype remains authoritative for gameplay behavior and content.
- The private harness remains available separately through `GODOT_LAUNCH_PRIVATE_HARNESS_WINDOWS.bat`.
