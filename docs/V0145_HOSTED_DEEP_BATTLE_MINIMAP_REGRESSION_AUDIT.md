# v0.14.5 Hosted Deep-Battle Minimap Regression Audit

Date: 2026-05-18  
Baseline commit: 9a1dc0a113144c9cb3132b689cec53fd772953f1  
Remote evidence source: Emmanuel's supplied GitHub Actions CI Release Matrix Dry Run #61 summary

## Failed Workflow Evidence

- Workflow: CI Release Matrix Dry Run #61.
- Commit: `9a1dc0a`.
- Failed group: `Release matrix (deep-battle)`.
- Failed test: `tests/e2e/deep-flow.spec.ts:1647`, `battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions @hosted-deep-battle`.
- Failure point: around `tests/e2e/deep-flow.spec.ts:1868`.
- Failure mode: `Timeout 1000ms exceeded while waiting on the predicate`.
- Failing predicate: the test expected `scene.inputSystem.dragStart` to remain active after a canvas drag crossed into the minimap DOM area.
- Other deep-battle tests: 10 passed.
- Other manually checked matrix lanes were green: fast confidence, deep-meta, deep-campaign-pressure, layout-core, layout-cinderfen, smoke, and release simulator.

The GitHub CLI was not installed in the local environment, so this audit records the supplied CI evidence rather than claiming direct log or artifact inspection.

## Why This Is Isolated

The failure sits in the v0.14.4 minimap/HUD drag-selection regression coverage, not in the battle launch path, campaign setup, combat loop, fog toggle, building placement, or command hall action logic. Local hosted repro and full hosted deep-battle both passed before the fix, which points to a hosted timing race rather than a deterministic product failure.

The failing sequence was:

1. Move the mouse to a battlefield canvas point.
2. Press the mouse button down.
3. Immediately move into the top-right minimap.
4. Poll for only 1000ms that the internal marquee drag state exists.

That poll preserved the correct behavioral intent, but it did not first prove the canvas pointerdown had been processed before the pointer crossed into the minimap.

## v0.14.4 Changes In This Area

v0.14.4 changed the relevant surface in three ways:

- `InputSystem` keeps active marquee drags rendering through global pointer movement while crossing DOM HUD/minimap surfaces.
- `HUD` clears handled minimap focus/deferred markup state so minimap interactions do not leave stale side-panel selection markup.
- `tests/e2e/deep-flow.spec.ts` added release-over-minimap marquee coverage in the same test that already covers minimap movement, fog toggle, placement cancel, and command hall actions.

## Likely Root Cause

The most likely root cause is a test race under hosted preview timing:

- the test moved from canvas to minimap immediately after `page.mouse.down()`;
- the test sampled active drag state only after the pointer had crossed into the minimap;
- the hosted check gave the predicate only 1000ms;
- the test did not guarantee `page.mouse.up()` cleanup if that midpoint assertion failed.

This is not evidence that v0.14.4's runtime minimap or marquee implementation is broadly broken. It is evidence that the new hosted regression check needed a stronger event-order precondition and cleanup.

## Assertions To Preserve

The fix must keep all of this coverage:

- minimap movement still moves the battle camera;
- marquee selection state remains active while crossing the minimap;
- release over the minimap clears marquee drag state promptly;
- fog toggle still works;
- building placement cancel still works;
- command hall actions still work;
- v0.14.4 stale-selection and drag-over-HUD/minimap fixes remain covered;
- no console errors are hidden.

No runtime gameplay numbers, save data, maps, factions, units, assets, or hosted matrix structure should change for this fix.
