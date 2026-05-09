# v0.7.1 Pressure Warning Visibility Audit

Date: 2026-05-09

Status: Phase 3 visibility/message-priority audit and small safe fix. This pass does not add a new UI panel, HUD redesign, tutorial overlay change, live reinforcement, capture-site contest AI, defensive hold behavior, workers, construction, economy AI, new maps, new units, new factions, rewards, or save changes.

## Current Status Surface

Pressure warnings use the existing battle status line:

- DOM renderer: `src/game/ui/hudPanels/AlertPanel.ts`
- Styling: `src/game/styles/battle-feedback.css`
- Status owner: `src/game/scenes/BattleScene.ts`
- Pressure caller: `src/game/battle/EnemyPressureRuntime.ts` through `BattleScene`'s `showWarning` callback

This is the right surface for v0.7.1 because it keeps the center playfield clear, avoids a new panel, and reuses a familiar line that already works in battle and e2e.

## Visibility Problem

Before Phase 3, every battle status message used the same priority:

- `showMessage()` directly replaced `statusMessage`.
- The default status timer was 2.5 seconds.
- Any later generic message could replace a pressure warning immediately.
- When the status timer reached zero, the line returned to generic AI/time copy.

This meant the runtime could correctly record pressure telemetry while a human player might miss the warning if a capture message, resource alert, wave alert, or objective update appeared immediately afterward.

## Tutorial Overlay Check

The tutorial overlay remains separate from the battle status line:

- Tutorial panel z-index: 3.
- Status line z-index: 2.
- Tutorial launches do not create an enemy pressure runtime.

Phase 3 did not change tutorial overlay priority, tutorial reward behavior, tutorial launch data, or tutorial persistence.

## Safe Fix Applied

Phase 3 added `src/game/battle/BattleStatusPriority.ts` with a tiny priority rule:

- `normal` status priority for existing battle messages.
- `pressure` status priority for enemy pressure warnings.
- `objective` status priority for critical objective/capture-bonus feedback such as `Cinder Shrine Surge`.
- Active pressure status does not lose to lower-priority normal messages until its timer expires.
- Pressure can still replace normal status.
- Objective feedback can still replace active pressure status, so important reward/capture clarity is preserved.
- Normal status resumes after the timer expires.

Pressure messages now use a 4.5 second status-line read window instead of the normal 2.5 second window. Floating text still appears for lower-priority messages even if the status line remains protected, so generic battle feedback is not removed.

## Why This Is Safe

- No new UI panel or layout surface was added.
- Existing generic messages keep their floating text feedback.
- Critical objective feedback keeps status-line priority over pressure.
- Normal status messages still show when no pressure warning is active.
- The status line still returns to normal AI/time or placement copy after the timer expires.
- The change is local to status-line presentation and does not alter pressure triggers, actions, wave timing, telemetry labels, simulator logic, saves, rewards, maps, units, factions, or enemy AI behavior.

## Tests

Added `src/game/battle/BattleStatusPriority.test.ts`:

- Active pressure warnings remain ahead of normal status.
- Pressure messages can replace normal status.
- Normal status can replace pressure after the timer expires.
- Pressure warnings have a longer read window than normal messages.

Existing smoke coverage still validates the broader browser routes after this status presentation change.

Phase 4 also hardened `tests/e2e/enemy-pressure.spec.ts` so the targeted pressure browser lane verifies that an active pressure warning remains visible after a generic normal status message attempts to replace it. Tutorial and skirmish no-pressure guards remain in the same release-suite spec.

## Remaining Human-Play Risk

The warning is more durable now, but human play still needs to judge:

- Whether 4.5 seconds is readable without feeling sticky.
- Whether the status line is visually noticeable during combat.
- Whether pressure warnings need a future visual category treatment.
- Whether Cinderfen Watch's early warning feels fair.
- Whether Cinderfen Crossing pressure is noticeable for non-Fast-Army paths.

## Phase 3 Decision

Keep the fix. It is a narrow visibility hardening step, not a gameplay expansion. Do not add a panel, icon, animation system, live reinforcement, route contesting, defensive hold behavior, workers, construction, or economy AI inside v0.7.1.
