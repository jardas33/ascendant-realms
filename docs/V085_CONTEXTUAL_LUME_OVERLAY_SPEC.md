# v0.85 Contextual Lume Overlay Spec

## Scope

v0.85 keeps the existing Aether Well Lume Network rules and makes its battlefield overlay contextual. It does not add gameplay systems, maps, art, persistent state, save fields, rewards, or broader Lume rules.

## Stable Auto Mode

`Auto` is the default battle-session mode for eligible Lume missions.

- Active links render as thin, low-opacity teal lines.
- Stable active endpoints render with subtle halos.
- Stable active lines sit below capture-site labels, unit labels, and interaction affordances.
- Inactive links are hidden during ordinary play.
- The guided private demo may show only the currently relevant incomplete link as a faint teaching guide.
- The optional North Aether Spring link remains hidden until the first Lume link has awakened.

## Highlight Rules

Links and endpoint halos become brighter only while there is a reason:

- activation pulse, about three seconds;
- restored pulse, about three seconds;
- contested pulse, about three seconds;
- severed pulse, about three seconds, then hidden or faded;
- either endpoint selected;
- explicit `Links: Always` visibility mode.

Hover highlighting is deferred because the current battle input system does not expose a stable capture-site hover state.

## State Colors

- Active stable: low-opacity teal.
- Activation/restored/selected/Always: brighter teal.
- Contested: amber pulse.
- Severed: red pulse, then fade.
- Guided incomplete link: faint teal guide.

## Layering

The Lume graphics layer remains procedural Phaser graphics above terrain and below most unit, building, label, and HUD affordances. Fog of war remains authoritative.

## Deferrals

- No final VFX.
- No imported icons or link art.
- No shield icon over every protected unit.
- No map-authored Lume paths.
- No broad battlefield-shell redesign.
