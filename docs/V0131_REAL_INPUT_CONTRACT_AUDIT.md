# v0.131 Real Input Contract Audit

Status: `REAL_INPUT_CONTRACT_REPAIRED`

Scope: player-facing Godot Salto review slice only. This audit does not approve a full Godot port, final engine choice, artwork import, save change, stable-ID change, or browser-runtime replacement.

## Expected Player Contract

| Path | Contract |
| --- | --- |
| Hover | Moving the mouse over a visible unit shows hover feedback. |
| Select | Left-click selects Aster, Worker, or friendly soldiers through enlarged screen-space hitboxes. |
| Deselect | Left-clicking empty terrain clears the selection when no friendly hitbox is under the cursor. |
| Box select | Left-drag across friendly soldiers selects a squad and shows squad feedback. |
| Move | Right-clicking terrain with a selected friendly unit issues a move order and shows a move marker. |
| Attack | Right-clicking a hostile unit with a selected friendly unit issues an attack order and shows an attack marker. |
| Camera pan | Existing camera pan hook remains scriptable and bounded. |
| Zoom | Existing zoom posture remains scriptable and bounded. |
| HUD command | HUD Move and Attack buttons remain discoverable alternatives, but normal right-click is the primary RTS command path. |
| Objective state | Objective 1 advances only after Aster is selected, receives a real movement order, and visibly displaces. |

## Private Harness Versus Player Input

The private harness may still call fixture functions directly for engineering proof. v0.131 human playability cannot use that as evidence. The proof source is the packaged player slice with normal mouse events: title click, briefing click, Aster hover/click, right-click move, Worker click, and squad drag.

## Root Cause

Emmanuel's v0.130 playtest exposed a combined interaction failure:

- Real battlefield mouse routing was missing from the 2.5D player-facing scene.
- The player UI overlay could block title and battle input if its root ignored or consumed the wrong events.
- Aster was visually present but not staged, labeled, pulsed, or hitboxed clearly enough for a human first click.
- Objective progression was validated by scripted state transitions rather than a real movement event.
- Player-facing movement did not have a live frame advance tied to headed play.

The bug was not a save, content adapter, stable-ID, browser runtime, or linked_ward issue.

Prompt-category classification: hitbox mismatch, Control node consuming mouse events, camera/world coordinate conversion risk, invisible or tiny click target, order dispatch not wired, unit movement not updating, and player-facing launcher proof relying on scripted showcase validation instead of real input.

## Repair Summary

- Aster now starts in a separated safe staging position.
- Aster receives a pulsing ring, compact `ASTER` label, focus arrow, minimap marker, and auto-centered camera during Objective 1.
- Screen-space hitboxes are larger than the visible primitives.
- The player-facing 2.5D scene handles real mouse hover, left-click, right-click, and drag selection.
- The player overlay passes input through outside active buttons and labels/backgrounds ignore battlefield clicks.
- Live movement advances during player-facing battle.
- Objective 1 advances only after the real movement displacement gate.
