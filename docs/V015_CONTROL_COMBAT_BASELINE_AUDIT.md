# v0.15 Control And Combat Baseline Audit

Date: 2026-05-18  
Baseline commit: 5ab64f5ec56324ba0f9abd4d69d51f109e0adeca  
Scope: inspect the v0.14.x control/combat state before adding a narrow RTS behaviour-mode foundation.

## Baseline Status

- v0.14.5 is complete and pushed.
- `main` is clean and synced with `origin/main`.
- Latest checkpoint before v0.15: `Checkpoint v0.14.5 hosted deep-battle minimap fix`.
- No v0.15 code should change maps, factions, units, runtime art/assets, save format, or broad balance numbers.

## Current Input State

- `InputSystem` owns canvas pointer input, right-click move/attack, left-click selection/attack, attack-move keyboard prep, rally-point right-clicks, building placement, hero selection, hotkeys, and global pointer cleanup.
- Active marquee drags now continue drawing through global `pointermove` while crossing DOM HUD/minimap surfaces.
- Global `pointerup`, `pointercancel`, and window blur clear or complete active drags so HUD/minimap release zones do not trap the selection rectangle.
- Keyboard focus is guarded so editable inputs keep normal typing.

## Current Attack Command State

- Right-clicking a hostile or neutral target with selected units issues `commandAttack`.
- v0.14.4 added left-click attack when selected units hover a targetable hostile/neutral target.
- Canvas cursor state becomes a crosshair and `data-battle-cursor="attack"` while a selected player unit hovers a targetable enemy.
- Attack command feedback uses the battle status line and floating command text.

## Current Retreat / Move-Away State

- `Unit.commandMove` clears explicit attack target, sets normal movement, and starts a short `moveOrderCombatSuppressionSeconds` window.
- Combat skips opportunistic target acquisition for player units during that suppression window.
- Enemies can still attack or chase; retreat is not invulnerability.
- If pathing cannot fully reach a clicked point, `MovementSystem` reports "No clear path. Moving as close as possible."

## Current Melee Engagement State

- `CombatSystem` uses attack target resolution, cooldown, effective range, and optional chase movement.
- v0.14.3 added body-radius reach for melee.
- v0.14.4 added a small visual contact margin so sprite-adjacent melee units can fight without requiring a movement nudge.
- Adjacent enemy attacks and post-kill adjacent target reacquisition have unit coverage.

## Current HUD / Order Summary State

- `SelectedEntityPanel` shows selected entity stats, current order summary, training/research queues, rally point state, ability descriptions, and building commands.
- `UnitOrderSummary` distinguishes Attacking, Attack-moving, Moving, and Guarding.
- Multi-selection summarizes order counts.
- There is no runtime behaviour/stance mode shown before v0.15.

## Current Behaviour-Mode Design State

- `docs/V0143_UNIT_BEHAVIOUR_MODES_DESIGN.md` is design-only.
- The safest v0.15 implementation path is session-only unit state:
  - `Hold Ground`
  - `Guard Area`
  - `Press Attack`
- Patrol remains deferred because it would require route state, path visualization, and broader pathing reliability.

## Known Risks

- Adding persistent behaviour modes would require save schema decisions. v0.15 should keep modes session-only.
- A behaviour UI could overcrowd the compact side panel if it becomes too wordy.
- Press Attack can feel like the game is playing itself if its leash is too large.
- Hold Ground can look broken if the HUD does not explain that the unit is intentionally not chasing.
- Retreat reliability can be harmed if behaviour-mode reacquisition ignores explicit move orders.
- Hosted release lanes are sensitive to actionability and timing; do not weaken coverage or use force-click shortcuts.

## Must Not Regress

- v0.14.1 hero rename input accepting W/A/S/D.
- Tutorial objective progression and no-save/no-reward tutorial assertions.
- Pause/menu confirmation.
- Drag marquee selection, including release over HUD/minimap.
- Minimap click/camera movement and stale-selection flush.
- Attack-hover cursor and left-click attack order.
- Melee contact engagement.
- Retreat/move-away intent.
- Side-panel, settings, hosted release, and smoke assertions.
