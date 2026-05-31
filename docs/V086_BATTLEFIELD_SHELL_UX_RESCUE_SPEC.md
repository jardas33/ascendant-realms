# v0.86 Battlefield Shell UX Rescue Spec

## Goal

v0.86 is a presentation-only cleanup pass for the live battlefield shell. It keeps gameplay, saves, actions, hotkeys, IDs, maps, factions, art, balance, and Lume rules unchanged while making the active battle UI easier to read during ordinary Act 1 play.

## Scope

- Compact the right-side command panel so actions are first, costs stay visible, and long explanations move behind disclosure details or tooltips.
- Improve capture-site label contrast and state readability without changing capture rules.
- Strengthen selection outlines for friendly, enemy, and neutral entities without adding glow clutter.
- Soften fog-of-war presentation while preserving visibility logic exactly.
- Improve minimap marker contrast for player, enemy, neutral-site, and objective-site markers without changing click behavior.

## Command Panel Rules

- Primary actions remain visible as buttons.
- Costs, short lock reasons, and hotkey/action names remain visible.
- Long descriptions and effect text move into a compact details disclosure and remain available through accessible labels.
- Existing data-action values, test ids, and command behavior remain stable.
- Disabled buttons still explain the shortest actionable reason.

## Battlefield Readability Rules

- Capture labels use high-contrast chips and clear state prefixes: neutral, held, enemy, contested, or selected.
- Selection rings use restrained team colors and modest fill alpha.
- Fog uses distinct unexplored and explored-muted treatments but does not change line-of-sight.
- Minimap markers remain compact and clickable through the existing minimap surface.

## Deferrals

- No final art pass or imported cursor/marker assets.
- No command redesign or new command model.
- No minimap rewrite or Lume graph screen.
- No gameplay, balance, or save changes.
