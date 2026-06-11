# v0.221 Battlefield Composition Report

Status: PASS

v0.221 refines the isolated Godot Salto presentation-reboot path with a visual-only battlefield composition, lighting, value and camera pass. It keeps the selected v0.216 ground, v0.217 road/riverbank/water, v0.218 bridge, v0.219 structure shell and v0.220 environment dressing context intact.

## Scope

- Launcher: `tools/godot/launchGodotSaltoPresentationRebootWindows.ps1`
- Capture wrapper: `tools/godot/captureGodotSaltoCompositionLightingSelectionWindows.ps1`
- Validation wrapper: `tools/godot/validateGodotSaltoCompositionLightingSelectionWindows.ps1`
- Benchmark wrapper: `tools/godot/runGodotSaltoCompositionLightingSelectionBenchmarkWindows.ps1`
- Review tool: `tools/godot/saltoCompositionLightingSelectionTool.mjs`

## Composition Changes

- Added an explicit `--salto-composition-lighting-selection` opt-in flag for the isolated review path.
- Added a small set of deterministic, visual-only v0.221 overlays for terrain value, road-to-bridge hierarchy, river depth, structure contact and unit grounding.
- Tuned review-path camera posture for a clearer normal RTS overview while preserving pan and zoom checks.
- Reduced selected material overlay strength in this path so roads, river, banks, bridge and units separate more cleanly.
- Adjusted the v0.221 light preset toward restrained warm daylight with better surface separation.

## Review Pack

Manual review PNGs:

- `artifacts/manual-review/v0221-composition-lighting-selection/01_initial_overview.png`
- `artifacts/manual-review/v0221-composition-lighting-selection/02_road_bridge_composition.png`
- `artifacts/manual-review/v0221-composition-lighting-selection/03_structures_grounded.png`
- `artifacts/manual-review/v0221-composition-lighting-selection/04_hero_selected.png`
- `artifacts/manual-review/v0221-composition-lighting-selection/05_squad_selected.png`
- `artifacts/manual-review/v0221-composition-lighting-selection/06_hostile_pressure.png`
- `artifacts/manual-review/v0221-composition-lighting-selection/07_pan_zoom_near.png`
- `artifacts/manual-review/v0221-composition-lighting-selection/08_pan_zoom_default.png`
- `artifacts/manual-review/v0221-composition-lighting-selection/09_pan_zoom_wide.png`
- `artifacts/manual-review/v0221-composition-lighting-selection/10_minimap_correlation.png`
- `artifacts/manual-review/v0221-composition-lighting-selection/11_before_after_contact_sheet.png`
- `artifacts/manual-review/v0221-composition-lighting-selection/12_review_contact_sheet.png`

## Visual Assessment

The pass improves normal RTS framing, unit contact, route hierarchy and marker scale. The largest remaining visual limitation is inherited from the selected shell-v2 material/compositor stack: some broad terrain-material surfaces still read as explicit selected review surfaces rather than finished production terrain. v0.221 intentionally does not replace that architecture.

Decision: selected for the isolated review path.
