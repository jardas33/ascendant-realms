# v0.222 Minimal Contextual HUD Report

Date: 2026-06-11

## Scope

v0.222 replaces the v0.214-style always-open dashboard HUD with an isolated, opt-in, compact contextual HUD for the Godot Salto presentation-reboot review path.

The default stabilized launcher remains procedural. Browser runtime, gameplay, pathing, collisions, objectives, AI, economy, saves, stable IDs, balance, production art slots and imported art slots are unchanged.

## Implemented HUD Posture

- Slim resource strip at the top of the battlefield.
- Compact objective ribbon, with detail available only on demand.
- Bottom-left minimap retained without drawer overlap.
- Bottom-center selected-context bar for selected-unit actions.
- Compact utility cluster.
- Event, production, hostile alert and tooltip surfaces are contextual drawers, hidden by default.
- Original procedural icon chips only; no generated or downloaded image assets.

## Manual Review Pack

Path:

```text
artifacts/manual-review/v0222-minimal-contextual-hud/
```

Required PNGs:

```text
01_default_compact_hud.png
02_objective_expanded.png
03_event_drawer_expanded.png
04_production_drawer_build.png
05_production_drawer_train.png
06_production_drawer_research.png
07_hostile_alert_active.png
08_tooltip_docked.png
09_resolution_matrix.png
10_v0214_vs_reboot_contact_sheet.png
11_occupancy_measurements.png
```

Optional contact sheet:

```text
12_review_contact_sheet.png
```

## Acceptance Notes

- Default HUD state is compact and battlefield-first.
- Default event log, production grid, hostile alert and tooltip are hidden.
- Objective detail, event history, production actions, hostile alert and tooltip are available on demand.
- Tooltip is docked to contextual UI rather than the battlefield center.
- Production cards use v0.222 compact rendering so disabled/future text stays within the drawer.
- The v0.214/full-HUD comparator is preserved as evidence only.
