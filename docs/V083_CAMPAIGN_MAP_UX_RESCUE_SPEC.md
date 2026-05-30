# v0.83 Campaign Map UX Rescue Spec

## Scope

v0.83 rescues the existing campaign map presentation without changing campaign content, save schema, mission rewards, Lume balance, or Act 1 progression. The campaign screen should open as a map-first command surface instead of a long vertical dump of every campaign subsystem.

## Problems Addressed

- The campaign map is currently buried below hero, bank, stronghold, retinue, rival, reputation, modifier, and chapter panels.
- Node cards can feel cramped or overlap at common desktop playtest sizes.
- The selected-node panel exposes too much detail immediately.
- The primary launch action is separated from the selected mission context.
- Emmanuel needs faster confidence when checking fresh saves, locked nodes, and the Aether Well Lume slice.

## Layout Rules

- Default tab: Map.
- Fresh campaign default selection: Border Village.
- The first viewport should show the top status strip, campaign map, selected mission summary, and primary action.
- Secondary systems move behind existing-surface tabs: Stronghold, Hero, Inventory, Intel, Reputation.
- Selected-node detail remains available behind a More Details disclosure.
- Event and town choices remain visible and usable when that node is selected.
- Node cards must be readable at 1920x1080 and 1366x768 without obvious overlap.
- Use existing HTML/CSS surfaces and existing art only.

## Map Rules

- All existing campaign nodes remain visible.
- No node ids, prerequisites, rewards, map ids, mission ids, or save fields are renamed.
- Locked nodes remain selectable for preview.
- Completed battle nodes remain replayable through the existing rules.
- The map may use smaller node cards and adjusted presentation spacing, but not new map content.

## Selected Mission Panel

The selected panel should show:

- status,
- node name,
- concise mission description,
- reward preview,
- map and mission type,
- locked/replay/first-clear state,
- primary launch or resolve action,
- More Details disclosure for doctrine, modifiers, Lume, optional objectives, and full reward rows.

## Deferrals

- No large campaign UI rewrite.
- No map pan/zoom.
- No new campaign art.
- No new missions, factions, maps, rewards, or save migration.
- No broader runtime display-copy migration.
