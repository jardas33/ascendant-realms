# v0.87 Campaign Shell Second Polish Spec

## Scope

v0.87 improves the campaign shell presentation only. It does not change campaign progression, rewards, save data, stable ids, maps, factions, art, or gameplay rules.

## Goals

- Make the campaign default tab feel map-first instead of dashboard-first.
- Use more available desktop width and height while keeping the selected mission action immediately visible.
- Improve progression readability with clearer chapter lanes, routes, and node states.
- Keep Border Village selected on a fresh campaign.
- Keep locked-node preview available for Aether Well Ruins and later chapter nodes.
- Avoid default map-tab page scrolling at 1920x1080 and 1366x768.

## Campaign Map Layout

The campaign map uses presentation-only node coordinates derived from existing node ids and chapter ids. Source node definitions remain unchanged. Chapter 1 stays in a broad left-to-mid route lane, while Chapter 2 is reserved as a future lane on the right. Route lines connect existing unlock relationships.

Required visible states:

- Completed: green completed/replayable frame.
- Selected: gold highlight and stronger depth.
- Available: blue active frame.
- Locked: muted frame with readable preview.
- Future/upcoming: locked presentation plus upcoming copy from existing placeholder fields.
- Replayable: completed battle label continues to say `Replayable (Completed)`.

## Selected Mission Panel

The default selected mission panel shows:

- Mission title.
- Mission type.
- State.
- One short description.
- Primary objective.
- Concise reward preview.
- Difficulty/pacing label.
- Lock reason when needed.
- Primary action.
- `More Details`.

Secondary information remains available inside `More Details`:

- Build hints.
- Doctrine details.
- Modifiers.
- Rival information.
- Replay notes.
- Extended rewards.
- Telemetry-style explanations.
- Tactical plan selector when applicable.
- Event choices when applicable.

## Campaign Tabs

Map, Stronghold, Hero, Inventory, Intel, and Reputation should use card-based hierarchy. Long prose should move into small summary cards or details blocks. Existing actions, purchase buttons, inventory launch, retinue controls, tactical plans, and private playtest controls remain available.

## Save Compatibility

No save schema changes are permitted for this milestone. All map positions, lanes, disclosure state, and tab hierarchy are render-only.

## Deferrals

- No new chapter content.
- No campaign logic rewrite.
- No new art or map assets.
- No per-user layout persistence.
- No desktop or multiplayer shell work.
