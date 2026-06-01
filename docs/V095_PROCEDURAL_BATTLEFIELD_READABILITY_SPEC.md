# v0.95 Procedural Battlefield Readability Spec

Checkpoint: v0.95 Procedural Battlefield Readability and Placeholder-World Rescue

## Intent

Improve the current battle scene so it reads less like flat debug geometry and more like a deliberate RTS battlefield while staying strictly placeholder-safe. This milestone changes presentation only: no final art, generated images, imported assets, gameplay rules, balance, save data, pathing, fog logic, Lume mechanics, rewards, IDs, or progression.

## Scope

- Add deterministic procedural terrain readability to existing map rendering.
- Soften fog presentation without changing visibility calculations.
- Give unit and building placeholders clearer silhouettes using Phaser shapes only.
- Reduce label clutter by prioritizing selected, objective, contested, hero, elite, and building/site information.
- Improve capture-site ownership and objective emphasis.
- Improve minimap readability through presentation-only SVG/CSS adjustments.
- Keep Lume link behavior unchanged while preserving Auto, Hidden, and Always modes.
- Extend visual QA screenshots for battle readability review.

## Non-Goals

- Final faction art or generated/imported images.
- New maps, factions, units, buildings, gameplay systems, rewards, saves, or progression rules.
- Pathing, collision, fog-of-war simulation, Lume network mechanics, or balance changes.
- A broad HUD redesign or mobile-first layout.

## Acceptance

- Ordinary battle start at 1920x1080, 1600x900, and 1366x768 is readable without HUD collision.
- Fog still hides unexplored/unseen areas, but looks less like hard debug rectangles.
- Roads, water, buildable ground, blocked ground, and capture-site areas are distinguishable.
- Hero, Worker, frontline, ranged, enemy, building, and capture-site placeholders have different silhouettes.
- Capture sites show neutral, player, enemy, contested, selected, and objective emphasis clearly.
- Routine battlefield labels are quieter; important labels remain visible.
- Minimap remains visible and readable at all target desktop viewports.
- Tutorial, private Lume demo, Act 1 telemetry, controls, hosted battle tests, and package validation remain green.

## Save and ID Safety

No save-version bump is allowed. This checkpoint does not add or alter save fields, serialized values, stable IDs, mission IDs, map IDs, site IDs, Lume IDs, unit IDs, building IDs, relic IDs, or reward IDs.

