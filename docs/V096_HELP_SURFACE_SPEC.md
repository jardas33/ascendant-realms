# v0.96 Help Surface Spec

Status: implementation spec.

## Purpose

Give new players a compact place to recover basic controls without turning the UI into a manual.

## Surfaces

- Campaign shell: collapsed `Quick Help` card below the first-session recommendation.
- Battle HUD: compact top-bar `Help` disclosure.
- Pause menu: grouped help repeated for safety while the simulation is paused.
- Tutorial: step-local `More Help` plus the battle HUD help surface.

## Groups

| Group | Default Copy |
| --- | --- |
| Camera | WASD or arrow keys pan. Space centers the hero. |
| Selection | Click units or drag a box. H selects the hero. |
| Movement | Right-click ground to move selected friendly units. |
| Combat | Right-click enemies to attack. Group units before pushing. |
| Workers and Sites | Capture sites, then assign Workers for stronger income. |
| Construction and Training | Command Hall trains Workers. Workers build. Barracks trains army. |
| Control Groups | Ctrl+1 to Ctrl+5 assigns; 1 to 5 recalls. |
| Patrol | Use Patrol with combat units, then click a patrol point. |
| Lume | Lume links appear only in eligible missions and demos. |

## Rules

- Help is collapsed by default.
- No help text writes saves or changes gameplay.
- Lume help appears in campaign/general help, but Tutorial does not show Lume controls.
- The surface uses native `details` / `summary` controls.

## Deferrals

- No searchable codex.
- No animated tutorial overlays.
- No persistent dismissed-help state.
