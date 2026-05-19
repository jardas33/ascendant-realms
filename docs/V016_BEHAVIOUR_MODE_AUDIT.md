# v0.16 Behaviour Mode Audit

Date: 2026-05-19
Baseline commit: `27dfe1a` (`Checkpoint v0.15 RTS control behaviour foundation`)
Scope: code-level audit of the v0.15 behaviour-mode and RTS control stack before expanding v0.16 tests, diagnostics, and packaging.

## Files Audited

- `src/game/systems/BehaviourModeSystem.ts`
- `src/game/entities/Unit.ts`
- `src/game/systems/CombatSystem.ts`
- `src/game/systems/InputSystem.ts`
- `src/game/battle/BattleSceneSystems.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/ui/HUD.ts`
- `src/game/ui/UnitOrderSummary.ts`
- `src/game/ui/hudPanels/SelectedEntityPanel.ts`
- `tests/e2e/deep-flow.spec.ts`
- v0.15 unit/UI/package tests

## Findings

### Mode Separation

`BehaviourModeSystem` defines three original session-only modes and normalizes missing or invalid values to `Guard Area`. `Unit` owns the live `behaviourMode` field with default `Guard Area`; no save field or migration exists.

`CombatSystem` separates modes at opportunistic player target acquisition:

- `Hold Ground` acquires immediate-range/contact enemies and direct attackers within the normal guard leash.
- `Guard Area` uses the default local aggro leash.
- `Press Attack` uses a larger but still bounded local search radius.

The mode model is clearly separated enough for v0.16 hardening. The next useful work is broader tests, not a runtime redesign.

### Explicit Orders

Explicit attack orders remain respected because `attackTargetId` is resolved before opportunistic acquisition. Explicit move orders clear attack target state, set normal movement, and start `moveOrderCombatSuppressionSeconds`.

The suppression timer is decremented in `finally` after target resolution, so an update frame that begins suppressed cannot reacquire on the same frame the timer reaches zero. This directly protects the v0.15 retreat/snap-back fix.

### Melee And Retreat

Melee contact uses raw range plus unit radii and a small visual contact margin. This is intentionally an interpretation of contact, not a data-number rebalance.

Retreat is not invulnerability. Enemy units are not gated by player behaviour modes and can still chase or damage if they are in range or within their enemy aggro rules.

### Input And Attack Intent

`InputSystem` still owns real canvas pointer input. A selected alive player unit plus a valid hostile or neutral target sets the canvas attack cursor. Left-click only becomes an attack command through the same `issueAttackOrder` path used by right-click. Empty left-click falls through to selection.

Existing v0.15 browser coverage checks hover attack intent, HUD refresh survival, cursor clearing, empty left-click non-attack behavior, and left-click attack order.

### HUD And Group Controls

`SelectedEntityPanel` renders behaviour controls for selected player units and selected groups using existing text button styling. Mixed groups show `Mixed`. Buildings do not receive behaviour controls unless units are also selected in the group summary.

`BattleSceneSystems` filters selected entities to alive player `Unit` instances before applying a mode, so selected buildings and enemy/non-controllable entities should not corrupt mode state.

`UnitOrderSummary` reports explicit attack, attack-move, move, repositioning, holding, guarding, and pressing states. It is readable, but v0.16 should add more coverage for mixed orders and retreat copy.

### HUD / Minimap / Marquee Safeguards

`HUD` still defers DOM rebuilds while stable interaction zones are active, clears interaction focus after handled buttons/minimap clicks, and forces the next update after handled interactions. `InputSystem` continues global pointermove/pointerup handling for marquee drags across DOM HUD/minimap surfaces.

The deep-flow browser test already checks release-over-HUD, release-over-minimap, minimap camera movement, and `H` hero selection after HUD/minimap interaction. v0.16 should keep those checks and add behaviour-control-after-minimap coverage to make the relationship explicit.

### Side Panel Landmark Focus

The v0.15 side panel remains compact and scrollable. No audit finding suggests a redesign or runtime visual pass. v0.16 should preserve the current constrained panel behavior.

## Audit Question Answers

1. Hold Ground, Guard Area, and Press Attack are separated in acquisition logic.
2. Hold Ground fights contact/immediate threats and direct attackers without chasing distant idle enemies.
3. Guard Area is still the balanced default.
4. Press Attack pursues beyond Guard Area but remains bounded by a larger local leash.
5. Explicit move orders temporarily override reacquisition.
6. Explicit attack orders remain respected before mode logic.
7. Retreat/move-away clears explicit attack target and suppresses same-frame reacquisition.
8. Enemies still chase/damage through their existing enemy rules.
9. HUD controls apply to alive selected player units and groups.
10. Mixed-selection reporting is readable.
11. `H` hero-select refresh is wired to force HUD refresh after HUD/minimap interactions.
12. v0.14.4/v0.14.5 marquee and minimap protections remain in the code path and browser tests.
13. The side panel avoids broad landmark-covering redesign and remains scroll-constrained.
14. Existing tests cover several actual intent paths, but v0.16 should deepen coverage around mode boundaries, explicit overrides, and generated diagnostics.

## Risks To Harden

- Press Attack boundedness needs explicit regression coverage.
- Hold Ground direct-attacker behavior needs more focused tests.
- Group mode application is currently covered mostly through the HUD path; add pure tests around mixed/group state.
- Attack intent is browser-only; preserve real canvas pointer checks and avoid DOM fallback for world clicks.
- The package verifier still reflects v0.15 package contents and should require the new v0.16 retest materials.
- The automated evidence layer should state that deterministic diagnostics are not human fun, balance, or usability proof.

## Narrow Runtime Fix Found During Gauntlet Work

The initial audit did not find a broad runtime flaw. The subsequent focused gauntlet work did expose one narrow mismatch:

- `Hold Ground` could acquire a nearby direct attacker during target selection, but the chase gate still rejected movement toward that same direct attacker if the attacker was just outside immediate weapon/contact range.

The fix keeps Hold Ground passive against idle distant enemies, but lets it respond to a nearby unit that is directly attacking it within the normal guard leash. This aligns the runtime with the v0.15 spec wording: Hold Ground attacks immediate threats or enemies directly attacking the unit. No gameplay data numbers, save format, pathing, broad AI, art, maps, factions, or units changed.

Focused tests now cover Hold Ground direct-attacker response, distant-threat refusal, ranged over-pursuit refusal, explicit attack override, Guard Area local leash, and Press Attack bounded pursuit.
