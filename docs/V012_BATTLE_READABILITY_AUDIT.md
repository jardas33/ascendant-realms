# v0.12 Battle Readability Audit

Date: 2026-05-16

Scope: Phase 2 code/HUD audit for battle readability. This document inspects the current BattleScene, HUD, command, minimap, objective, pressure, and results surfaces and classifies improvements into quick safe fixes, test coverage needed, future visual asset overhaul, or broader mechanics design to defer.

No gameplay code was changed during this phase.

## Selected Unit Feedback

Current behavior:

- `BaseEntity` renders a ground selection ellipse for units, heroes, and buildings.
- `SelectionSystem` supports click, shift-additive click, and drag-select for non-building units.
- `SelectedEntityPanel` shows a single selected unit/building summary, or a multi-selection grid and aggregate order summary.
- `UnitOrderSummary` names states as Attacking, Attack-moving, Moving, or Guarding.

Issues:

- The selected ring is useful but subtle, especially under combat clutter or dark terrain.
- The selected panel order summary is correct but can visually read like another stat card.
- Multi-selection says counts such as `2 Moving, 1 Guarding`; it does not tell the player that this is the current command state for the selected group.
- The player does not get a direct status acknowledgement when a valid move command succeeds.

Classification:

- Quick safe fix: strengthen selected-panel copy and CSS hierarchy for order summaries.
- Test coverage needed: pure test coverage for order summary text if copy changes; e2e smoke/deep assertions if selectors or test IDs change.
- Future visual asset overhaul: new selection art, animated rings, faction-colored decals.
- Broader mechanics design, defer: control groups, formation UI, tactical stance toggles.

Likely files:

- `src/game/entities/BaseEntity.ts`
- `src/game/systems/SelectionSystem.ts`
- `src/game/ui/UnitOrderSummary.ts`
- `src/game/ui/hudPanels/SelectedEntityPanel.ts`
- `src/game/styles/battle-hud.css`
- `src/game/ui/UnitOrderSummary.test.ts`
- `tests/e2e/smoke.spec.ts`
- `tests/e2e/deep-flow.spec.ts`

## Unit Order State

Current behavior:

- `Unit.commandMove` clears explicit target and records `moveTarget` plus optional `attackMove`.
- `Unit.commandAttack` records target id and turns on attack-move behavior.
- `MovementSystem` clears `moveTarget` on arrival and reports path failures.
- `CombatSystem` moves units into range when explicit attack, attack-move, enemy units, or idle player units need to engage.

Issues:

- There is no on-screen differentiation between "guarding because idle" and "guarding after arriving at an accepted destination."
- Movement arrival is implicit; the player sees the order summary change from Moving to Guarding, but no top-level acknowledgement exists.
- Attack orders do not report the target name, which makes command acceptance less legible.

Classification:

- Quick safe fix: improve order-summary detail text and successful command status messages.
- Test coverage needed: preserve `Moving` assertion text or update tests deliberately without weakening the behavior.
- Future visual asset overhaul: destination marker art, attack-line art, formation indicators.
- Broader mechanics design, defer: persistent command queue, stance system, hold-position command.

Likely files:

- `src/game/ui/UnitOrderSummary.ts`
- `src/game/systems/InputSystem.ts`
- `src/game/battle/BattleSceneSystems.ts`
- `tests/e2e/smoke.spec.ts`
- `tests/e2e/deep-flow.spec.ts`

## Movement Command Feedback

Current behavior:

- Right-click hostile target issues attack.
- Right-click ground issues move or attack-move depending on mode.
- Path failures show `No clear path. Moving as close as possible.`
- Attack-move setup shows `Attack-move: right click a destination`.

Issues:

- Successful move and attack-move commands are quiet.
- Successful attack commands are quiet.
- Rally point setting has better feedback than normal unit movement because it uses both status text and a minimap ping.
- Resource income ticks can mask command feedback.

Classification:

- Quick safe fix: add concise accepted messages such as `Move order accepted: 3 units` and `Attack order accepted: Raiders` from existing command paths.
- Test coverage needed: e2e coverage should confirm valid move still reaches `Moving`/order summary and that status feedback appears without using canvas DOM fallback.
- Future visual asset overhaul: ground destination marker art.
- Broader mechanics design, defer: command preview, queued movement, attack-ground.

Likely files:

- `src/game/systems/InputSystem.ts`
- `src/game/battle/BattleStatusPriority.ts`
- `src/game/battle/BattleSceneAlerts.ts`
- `src/game/scenes/BattleScene.ts`

## Attack And Combat Feedback

Current behavior:

- `CombatSystem` shows floating damage text for hits of 5 or more.
- Burn/status effects show a small badge and floating status label.
- Health bars are always present for battle entities.
- Enemy waves generate minimap pings and defeated-wave messages.
- Command Hall under attack gets a minimap ping and status warning.

Issues:

- Damage numbers can stack without telling the player the broader combat state.
- Small damage under 5 is intentionally suppressed, but this can make weak/armor-reduced hits feel invisible.
- Burn/status badge is small and not named in the side panel.
- The player can miss whether a tower, commander, or wave is the main threat.

Classification:

- Quick safe fix: copy/hierarchy improvements for command and objective feedback; avoid changing damage spam rules unless evidence supports it.
- Test coverage needed: pure or e2e tests only if damage text thresholds or status labels change.
- Future visual asset overhaul: hit flashes, projectile VFX, status icons, clearer tower range indicators.
- Broader mechanics design, defer: detailed combat log, tactical threat meter, damage-type system.

Likely files:

- `src/game/systems/CombatSystem.ts`
- `src/game/systems/StatusEffectSystem.ts`
- `src/game/ui/FloatingText.ts`
- `src/game/ui/HealthBar.ts`
- `src/game/entities/BaseEntity.ts`
- `src/game/styles/battle-feedback.css`

## Health Bars

Current behavior:

- Health bars are drawn above units/buildings and update when damage/healing occurs.
- Player, enemy, and neutral health bars use distinct colors.
- Buildings also expose HP in the selected panel.

Issues:

- Health bars are compact and can be hard to scan in dense battles.
- Low-health urgency is not reflected in HUD copy or status messages.
- Selected unit panel shows HP but not whether the unit is in immediate danger.

Classification:

- Quick safe fix: selected-panel wording and stat ordering.
- Test coverage needed: minimal, unless DOM structure changes.
- Future visual asset overhaul: larger low-health indicators, animated bars, damage flash.
- Broader mechanics design, defer: retreat warning, auto-retreat, morale.

Likely files:

- `src/game/entities/BaseEntity.ts`
- `src/game/ui/hudPanels/SelectedEntityPanel.ts`
- `src/game/styles/battle-hud.css`

## Mana And Ability Readiness

Current behavior:

- Hero panel shows HP, mana, XP, and skill points.
- Ability buttons show name/cooldown from `abilityLabel` and mana cost.
- Ability failures explain not learned, cooling down, not enough mana, or no target.
- Successful ability casts show effect-specific messages and pulses.

Issues:

- Ability buttons do not appear disabled when mana/cooldown blocks casting; readiness is mostly label/text driven.
- Cooldown/mana explanation is split between button text and status messages after failed casts.
- Cast success messages can be terse, for example `Blink` or `Sanctified ground`.

Classification:

- Quick safe fix: clearer button text or small readiness labels, if it fits without layout churn.
- Test coverage needed: e2e deep battle has ability hotkey coverage; update only if copy/selectors change.
- Future visual asset overhaul: ability icon states, cooldown radial masks.
- Broader mechanics design, defer: targeting previews, smart-cast modes, ability loadouts.

Likely files:

- `src/game/ui/hudPanels/HeroHudPanel.ts`
- `src/game/ui/AbilityBar.ts`
- `src/game/systems/AbilitySystem.ts`
- `tests/e2e/deep-flow.spec.ts`

## Hero Panel

Current behavior:

- Hero panel is compact and always visible.
- It shows name, level, HP, mana, XP, and skill points.

Issues:

- It does not surface current hero order, selected state, or immediate threat.
- HP and mana share one text line, which is dense but stable.

Classification:

- Quick safe fix: leave hero panel mostly stable; prioritize selected panel/order summary instead.
- Test coverage needed: layout tests if panel dimensions change.
- Future visual asset overhaul: hero portrait and frame polish.
- Broader mechanics design, defer: hero equipment quick slots or status tray.

Likely files:

- `src/game/ui/hudPanels/HeroHudPanel.ts`
- `src/game/styles/battle-hud.css`
- `tests/e2e/layout.spec.ts`

## Side Panel

Current behavior:

- Side panel shows selected title, command tray, abilities, selection summary, stats, queues, and rally state.
- Updates defer while the pointer is inside stable panels to avoid hosted click instability.
- Scroll state is preserved for `.side-panel` and `.objectives-panel`.

Issues:

- Commands appear above selection summary, so selected order state can be pushed down when a building has many actions.
- Locked command buttons show reasons but cannot be clicked, so the player only learns from button text/title.
- Production/upgrade queues are useful but visually similar to stats.
- Multi-selection summary maxes at 12 names and does not say when more units are selected.

Classification:

- Quick safe fix: stronger order-summary copy/CSS and concise locked reason labels.
- Test coverage needed: layout side-panel reachability tests if structure changes.
- Future visual asset overhaul: command icons and stronger building/unit silhouettes.
- Broader mechanics design, defer: command categorization overhaul, drag-reorder queues.

Likely files:

- `src/game/ui/hudPanels/HudRoot.ts`
- `src/game/ui/hudPanels/CommandPanel.ts`
- `src/game/ui/hudPanels/SelectedEntityPanel.ts`
- `src/game/styles/battle-hud.css`
- `tests/e2e/layout.spec.ts`

## Objective Tracker

Current behavior:

- Objective tracker shows `Objectives completed/total`.
- Each row shows `Done` or `Open`, objective name, and description.
- Secondary objective completion writes `Objective complete: ...`.
- Objective completion can trigger map-specific battle effects, for example Burned Shrine weakening the gate Watchtower.

Issues:

- `Open` is technically correct but less helpful than "Next" or "Active".
- Long objective descriptions are small and can truncate on smaller viewports.
- The tracker does not distinguish "main win condition" from optional/special objectives.
- Some objectives have payoff words hidden late in the description.

Classification:

- Quick safe fix: improve state label, copy, and description length for existing objectives.
- Test coverage needed: e2e assertions for Cinderfen objective text and layout.
- Future visual asset overhaul: objective icons and map landmarks.
- Broader mechanics design, defer: full quest log, objective pinning, dynamic objective routing.

Likely files:

- `src/game/ui/hudPanels/ObjectivePanel.ts`
- `src/game/data/maps/ashenOutpost.ts`
- `src/game/data/maps/cinderfenCauseway.ts`
- `src/game/data/maps/cinderfenWatchpost.ts`
- `src/game/battle/BattleSceneObjectives.ts`
- `tests/e2e/smoke.spec.ts`
- `tests/e2e/layout.spec.ts`

## Battle Status Messages

Current behavior:

- Status priorities are `normal`, `pressure`, and `objective`.
- Objective messages last 4 seconds, pressure messages last 4.5 seconds, normal messages last 2.5 seconds.
- Incoming messages replace current messages when their priority rank is at least the current rank.
- Placement mode suppresses status-line rendering and uses a placement banner.

Issues:

- Normal income and command messages share priority, so income can overwrite important command acknowledgement.
- There is no command-specific priority/read window.
- Pressure/objective priority is useful and should be preserved.

Classification:

- Quick safe fix: add a `command` priority or equivalent command read window if tests can protect it.
- Test coverage needed: pure tests in `BattleStatusPriority.test.ts` for replacement/duration behavior.
- Future visual asset overhaul: richer status banners/icons.
- Broader mechanics design, defer: persistent combat log.

Likely files:

- `src/game/battle/BattleStatusPriority.ts`
- `src/game/battle/BattleStatusPriority.test.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/battle/BattleSceneSystems.ts`

## Minimap Marker Families

Current behavior:

- Minimap renders capture sites, camps, buildings, rally markers, enemy hero markers, units, pings, fog, and camera rectangle.
- Colorblind palette is supported.
- Rally points, commander sightings, enemy waves, capture bonuses, and under-attack warnings ping the minimap.

Issues:

- Marker families are present and test-covered, but labels only exist as SVG aria labels; the visual language is still small.
- Pings are short-lived and can stack.
- Fog cells are effective but make small markers harder to parse.

Classification:

- Quick safe fix: use existing ping labels for clearer copy, avoid visual overhaul.
- Test coverage needed: preserve minimap marker family tests if markup changes.
- Future visual asset overhaul: minimap legend, icon set, larger markers.
- Broader mechanics design, defer: minimap filters, tactical alerts panel.

Likely files:

- `src/game/ui/MinimapView.ts`
- `src/game/battle/BattleSceneSnapshots.ts`
- `src/game/battle/BattleSceneAlerts.ts`
- `src/game/styles/minimap.css`
- `src/game/ui/MinimapView.test.ts`
- `tests/e2e/deep-flow.spec.ts`

## Fog-Of-War Readability

Current behavior:

- Fog can be enabled by battle difficulty and is reflected in minimap fog cells.
- `F` debug toggle exists, with a guard when fog is disabled.
- Cinderfen Watch fog hides central threats until scouting.

Issues:

- Fog makes objectives like tower/raider camp harder to interpret, and the objective panel does not always say "scout into fog" plainly.
- The fog debug message is developer-like and should not be the focus of player feel work.

Classification:

- Quick safe fix: objective/pressure copy that names scouting/regrouping.
- Test coverage needed: layout and smoke assertions if objective text changes.
- Future visual asset overhaul: fog edge art and landmark silhouettes.
- Broader mechanics design, defer: scouting units, detection mechanics.

Likely files:

- `src/game/data/maps/cinderfenWatchpost.ts`
- `src/game/systems/FogOfWarSystem.ts`
- `src/game/battle/BattleSceneSnapshots.ts`
- `tests/e2e/layout.spec.ts`

## Pressure Warnings

Current behavior:

- `EnemyPressureRuntime` activates only for campaign nodes with matching plan, map, and node.
- Pressure plans explicitly avoid workers, construction, harvesting, and save-affecting progression.
- Stages show warning copy, adjust next-wave timing, or record telemetry; reinforcement/contest/defensive-hold actions remain copy/telemetry-only.
- Warnings use `pressure` status priority.

Issues:

- Some warning copy explains enemy intent but not player counterplay.
- Warning-only pressure can be misread as a hidden full AI system unless wording stays plain.
- Current test coverage asserts specific warning strings.

Classification:

- Quick safe fix: improve warning copy to say what is happening and what the player should do, while preserving warning-only scope.
- Test coverage needed: update `enemy-pressure.spec.ts` and `enemyPressurePlans.test.ts` if exact copy changes.
- Future visual asset overhaul: pressure alert iconography.
- Broader mechanics design, defer: enemy workers, construction AI, economy AI, full strategic planner.

Likely files:

- `src/game/data/enemyPressurePlans.ts`
- `src/game/battle/EnemyPressureRuntime.ts`
- `src/game/data/enemyPressurePlans.test.ts`
- `tests/e2e/enemy-pressure.spec.ts`

## Phase 2 Implementation Recommendation

Recommended v0.12 implementation slice:

1. Add command-level status priority and concise success acknowledgements for unit move, attack, attack-move, build placement, training, research, and rally.
2. Improve selected order summary hierarchy and copy without changing selection mechanics.
3. Clarify objective state labels and shorten high-impact Cinderfen/Ashen objective descriptions.
4. Clarify pressure warning counterplay without expanding pressure behavior.
5. Improve results guidance and defeat advice using existing battle stats.

Recommended deferrals:

- Visual asset replacement, terrain/icon art, new minimap art, or generated images.
- Full combat log, control groups, stances, command queue, or tactical planner.
- New AI economy/construction systems.
- Balance changes without simulator evidence.
