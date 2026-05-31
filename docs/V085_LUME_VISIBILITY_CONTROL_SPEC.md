# v0.85 Lume Visibility Control Spec

## Scope

Add one battle-session-only Lume visibility control in eligible Lume missions.

## Control

The Lume HUD row shows:

`Links: Auto`

Available modes:

- `Auto`
- `Always`
- `Hidden`

## Behavior

`Auto`:

- Contextual default.
- Active stable links are subtle.
- Relevant private-demo guide link is faint.
- Optional link appears only after it becomes relevant.
- Transition and selection highlights are bright enough to teach the mechanic.

`Always`:

- Renders all eligible links persistently.
- Active links and endpoints are more readable.
- Inactive links remain faint so the map does not become dominant.

`Hidden`:

- Hides stable links and halos.
- Still permits brief activation, restoration, contested, and severed pulses.
- HUD tracker remains the persistent guidance surface.

## Persistence

- No save field.
- No localStorage field.
- No settings migration.
- Defaults to `Auto` for private demo and ordinary eligible Lume mission launches.
- Control is absent outside eligible Lume missions.

## Deferrals

- Accessibility settings menu integration.
- Per-player persistent overlay preference.
- Capture-site hover support if the battle input model later exposes a stable hover state.
