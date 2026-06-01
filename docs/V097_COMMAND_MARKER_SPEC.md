# v0.97 Command Marker Spec

Status: implemented.

## Goal

Show the player where an accepted or rejected command landed, using short-lived procedural markers for existing commands only.

## Marker Kinds

| Marker | Trigger | Shape/readability |
| --- | --- | --- |
| Move | Existing right-click move and site assignment movement | Ground ring |
| Attack Move | Existing attack-move mode orders | Ground ring with attack-move label |
| Attack Target | Existing attack target clicks | Hostile crosshair |
| Patrol | Existing Patrol destination | Route marker with origin line |
| Rally | Existing building rally point updates | Banner marker |
| Build | Existing construction placement or construction-site order | Build square/tool marker |
| Ability | Existing successful ability cast target/readiness point | Spark marker |
| Invalid | Existing invalid placement or invalid no-selection command | Cross/blocked marker |
| Focus | Existing focus-selected, minimap focus, and Lume focus helpers | Focus reticle |

## Behavior

- Markers are battle-session-only Phaser primitives.
- Markers are capped to prevent clutter.
- Markers fade automatically.
- Reduced-motion mode uses a shorter static hold instead of animated fade/scale.
- Markers do not create new command types.
- Markers do not alter pathing, target selection, save data, or command validation.

## Command Copy

Routine confirmations stay concise:

- `Patrol route set.`
- `Rally point updated.`
- `Camera focus updated.`
- `Cannot build here - blocked terrain.`
- `Select combat units before issuing an attack.`

## Tests

- Pure presentation coverage validates marker label, tone, shape, duration, and reduced-motion behavior.
- Hosted coverage verifies marker rendering, marker cleanup, reduced-motion cleanup, minimap camera feedback, and no permanent marker leak.
- Existing hosted controls coverage continues to verify move, attack, Patrol, rally, Worker build/repair/site assignment, and minimap commands.
