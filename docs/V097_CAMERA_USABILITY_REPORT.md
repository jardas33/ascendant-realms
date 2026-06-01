# v0.97 Camera Usability Report

Status: implemented.

## Audit Summary

The existing camera already supported keyboard panning, minimap jumps, hero focus, and scene-transition centering. v0.97 keeps those systems intact and makes three safe presentation/quality changes:

- Space focuses the currently selected entity first, then falls back to the hero.
- Camera center and scroll positions are clamped through a shared helper so focus/minimap jumps cannot drift outside the map.
- Minimap and focus helpers now emit brief focus feedback and concise status copy.

## Kept Stable

- WASD/arrow keyboard pan.
- Existing zoom bounds.
- Existing minimap click-to-pan.
- Existing scene-transition recentering.
- Existing camera clamp limits.
- Existing settings storage.

## Deferred

- Persistent edge-scroll preference: deferred to avoid new save/settings fields.
- New camera profiles: deferred because v0.97 is not a gameplay or settings-system milestone.
- Drag-to-pan minimap changes: deferred to avoid input churn.

## Help Copy

The in-game help now says:

- `Camera: WASD or arrow keys pan. Space focuses selected units, or Aster if nothing is selected. Click the minimap to jump.`
- `Movement: Select friendly units, then right-click ground. A brief order marker shows where the command landed.`
- `Combat: Hover or click enemies to inspect them; with friendly units selected, right-click or left-click enemies to attack.`

## Save Safety

- No save-version bump.
- No new settings fields.
- No new localStorage keys.
- Reduced-motion behavior reuses the existing setting.

## Tests

- Unit coverage validates the map-bounds clamp helper.
- Hosted coverage verifies Space focus and minimap feedback.
- Existing controls verification continues to cover keyboard input, minimap movement, command routing, and HUD stability.
