# v0.207 UI Implementation Blueprint

## Sequence

1. v0.208: Build a private comparator HUD shell with fixed representative state, original controls, procedural icons, and screenshot validation.
2. v0.209: Wire the shell into a new explicit opt-in Godot launcher only; preserve the default procedural launcher.
3. v0.210: Polish selected hero and command context, including Aster, Worker, Militia, and Ashen target states.
4. v0.211: Add build, train, research, objective, event-log, and alert polish.
5. v0.212: Harden minimap, tooltips, disabled states, resolution behavior, and accessibility contrast.
6. v0.213: Run full HUD/environment cohesion QA and safe cleanup.
7. v0.214: Freeze or defer with one recommended next milestone.

## Implementation Constraints

- Keep all new HUD code isolated until the v0.209 opt-in launcher exists.
- Use Godot `Control`, `Panel`, `Label`, `Button`, `TextureRect`, `StyleBoxFlat`, and procedural SVG textures before any raster asset.
- Use stable dimensions for resource, minimap, selected context, command, and alert regions.
- Do not scale font size with viewport width.
- Keep bottom panels out of character silhouettes and tactical markers.
- Do not add production art slots or browser runtime hooks.

## Recommended Code Shape

- Add a small style/theme helper for palette, panel styleboxes, button states, and tooltip style.
- Add a HUD shell builder with named sub-regions matching the component inventory.
- Keep live state mapping separate from presentation assembly.
- Keep fallback mode explicit: if opt-in shell construction fails, use the existing procedural HUD.

## Visual Acceptance Bar

The finished v0.213 HUD should feel like a working fantasy RTS battle interface rather than debug overlay boxes. It should improve scan order and presentation while preserving the hard gameplay and runtime boundaries.
