# v0.54 Control Groups Foundation Spec

## Goal

Add the first small RTS control-group layer for live battles so players can quickly recall army subsets without changing campaign saves, build order, or unit behavior systems.

## Scope

- Ctrl+1 through Ctrl+5 assigns the current living player unit and hero selection to a session-only group.
- 1 through 5 recalls a group and selects its living members.
- Dead, missing, enemy, neutral, building, and capture-site ids are ignored when assigning or recalling.
- Control groups are battle-session state only. They are not written to hero, campaign, settings, or runtime save data.
- The HUD can show compact group feedback and current group membership count, but there is no large army-management UI.

## Input Rules

- Existing browser/system shortcuts stay protected by the current keyboard focus guard.
- Ctrl+number assignment is handled before ability hotkeys.
- Plain number recall is handled only for stored groups with living members. Existing hero ability hotkeys still work when the number has no recalled group to consume it.
- H, Space, F, Escape, building placement, minimap, marquee select, and right-click command behavior remain unchanged.

## UI Copy

- Assignment feedback: `Group 1 assigned: 3 units`.
- Recall feedback: `Group 1 selected: 2 units`.
- Empty/dead recall feedback: `Group 1 is empty`.
- Group selection summary: `Control group ready. Ctrl+1-5 assigns; 1-5 recalls.`

## Validation

- Assignment filters invalid entities.
- Recall prunes dead ids.
- Recall updates the existing selection system rather than adding a parallel selection model.
- No save fields or save-version bump are introduced.

## Deferrals

- No persistent control groups.
- No camera jump on double-tap.
- No subgroup tabs, production-group binding, enemy/building grouping, or formation editor.
