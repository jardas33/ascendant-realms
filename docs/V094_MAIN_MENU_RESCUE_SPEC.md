# v0.94 Main Menu Rescue Spec

## Purpose

Improve the first desktop impression without changing runtime title, saves, gameplay, progression, rewards, stable ids, maps, factions, or art assets.

## Scope

- Keep the visible title `Ascendant Realms`.
- Preserve all existing actions: New Campaign, Continue Campaign, Tutorial, Skirmish, Hero Inventory, Settings, Asset Gallery, Reset Save, and Credits / Info.
- Replace the narrow floating action stack with a wider desktop composition.
- Make New Campaign and Continue Campaign read as the primary play actions.
- Group secondary actions under Practice and Manage.
- Keep button height readable at 1920x1080, 1600x900, and 1366x768.

## Layout Rules

- Use one intentional desktop panel with a title/identity side and an action side.
- Keep primary actions immediately visible.
- Keep secondary actions visible and grouped, not scattered.
- Avoid final art, generated art, imported assets, and title rebranding.
- Avoid mobile-like single-column composition on desktop unless the viewport is genuinely narrow.

## Acceptance

- Main menu uses available width more deliberately.
- Primary campaign action is visible without default page scrolling.
- Secondary actions remain accessible.
- No horizontal overflow at desktop acceptance viewports.
- No functionality is removed.

## Deferrals

- Final illustrated background treatment.
- Public title migration.
- New art direction assets.
