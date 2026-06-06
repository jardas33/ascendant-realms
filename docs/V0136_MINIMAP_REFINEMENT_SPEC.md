# v0.136 Minimap Refinement Spec

Classification: `USABILITY_PRESENTATION_GREEN`

## Contract

The minimap remains procedural placeholder UI, but it must read as an authored Salto orientation map instead of a tiny schematic.

## Markers

- terrain outline;
- main road, water strip, and ford crossing;
- hero marker;
- Worker marker when relevant;
- friendly group marker;
- active Ashen attackers only;
- current objective marker;
- West Stone Cut Mine target and controlled markers;
- Barracks marker when relevant;
- Lume endpoints and link;
- camera viewport indicator.

## Interaction

Clicking the minimap safely recenters the camera on the active objective family. This click-to-orient behavior is allowed only when it stays inside the packaged player-facing slice and does not mutate saves, stable IDs, content fixtures, or require editor work.
