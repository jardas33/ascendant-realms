# v0.136 HUD Hierarchy Spec

Classification: `USABILITY_PRESENTATION_GREEN`

## Contract

The player-facing Salto HUD uses one primary objective line, one compact secondary hint, and one bottom command card. Battle guidance must not repeat as top and bottom banners, and no debug/proof/workload text may appear in the player path.

## Layout

- Top left: compact resources and the current objective only.
- Bottom left: selected entity, short context, progress/wave state, status, and five command buttons.
- Bottom center: one secondary hint, one alert line, and one short tooltip.
- Bottom right: larger minimap with safe click-to-orient.
- Battle shell: no separate Pause or tutorial label over the battlefield.

## Required HUD States

- Selected entity card updates for Aster, Worker, Barracks, and squad selection.
- Progress line shows conversion, construction, recruitment, countdown, wave remaining, Lume ready, or no active progress.
- Alerts are concise and disappear behind the current step.
- Results recap is short and player-facing.

