# P1 MINIMAP-01 — Tactical Minimap Readability and Visual Quality

## Scope

This bounded Godot-only lane improves the existing PLAYER minimap without changing
map generation, fog rules, navigation, camera behavior, combat, economy, or unit
and building semantics. The work is isolated to the minimap presentation layer and
its opt-in capture/validation wrapper.

Base: `570764fc582551d62a1f9e5e19b793b28ae634dc`
Branch: `codex/p1-minimap-01`
Worktree: `D:\CodexData\worktrees\ascendant-realms-p1-minimap-01`

## Player-facing improvement

The existing live-data minimap was already correlated with the authoritative map,
but its tactical hierarchy was weak: terrain, corridors, structures, resources,
units, and the viewport were rendered as similarly weighted marks. The refinement
adds:

- restrained four-by-four tactical grid lines;
- a stronger but still compact map frame and corner accents;
- outlined spawn/contested regions instead of broad translucent blobs;
- distinct structure glyphs with footprint, face, and roof-notch treatment;
- high-contrast unit diamonds with dark separation halos;
- resource glyphs with a consistent dark keyline;
- a clearer viewport polygon with fill, dark under-stroke, gold edge, and corner anchors;
- a more legible bridge glyph with deck and rail cues;
- unchanged live roads, water, capture points, resources, buildings, units, and map bounds.

The minimap remains a tactical abstraction of live world data. No hidden enemy
information is added and no second simulation is introduced.

## Before / after evidence

Baseline capture was taken before the visual change from the exact base HEAD:

`D:\CodexData\evidence\ascendant-realms-p1-minimap-01\run-20260814032237-570764fc\`

The after capture is written by the dedicated command to the same evidence root,
with its exact source SHA recorded in:

`D:\CodexData\evidence\ascendant-realms-p1-minimap-01\p1r3-capture-manifest.json`

Both 1920x1080 and 1366x768 are captured. The retained P1-R3 harness records
Hollowspan, Emberfall Rift, and Frostmere Basin at each resolution, providing
normal gameplay-scale views, terrain/water variation, roads, resources, units,
structures, and the camera viewport indicator.

## Validation contract

Dedicated commands:

- `npm run godot:capture:p1-minimap-01`
- `npm run godot:validate:p1-minimap-01`

The wrapper reuses the established live-map P1-R3 headed harness and adds a
MINIMAP-01 validator that checks exact source provenance, both resolutions, pass
status, opt-in capture autoload cleanup, and required PLAYER rendering tokens.

Certified runtime: Godot 4.6.3.stable.official.7d41c59c4 at
`D:\CodexData\tools\godot-4.6.3-stable\Godot_v4.6.3-stable_win64.exe`.

## Preserved

- canonical P1 UI presentation integration and validator-only branch repair;
- true default runtime and normal PLAYER launch behavior;
- map geometry, roads, water, fog/visibility, navigation, camera, selection,
  buildings, units, combat, economy, resources, saves, and stable IDs;
- existing P1-R3 live-map evidence harness;
- BUILD-01 surrogate untouched and PLAY-01A held;
- no push, PR, remote mutation, merge, promotion, or protected-checkout change.

## Review note

The minimap is intentionally compact. The stronger keylines and glyph hierarchy
are designed to survive 1920x1080 and 1366x768 without turning the HUD into a
large decorative map or leaking debug prose into normal PLAYER mode.
