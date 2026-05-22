# v0.16.10 Emmanuel Manual Retest Checklist

Date: 2026-05-22

Use the clean v0.16.10 package. Keep this pass focused on the v0.16.7 combat/control fixes.

1. Confirm Guard Area is still the default.
2. Hold Ground: let the first adjacent imp die and confirm the second adjacent imp engages instead of both sides idling.
3. Hold Ground: confirm distant idle enemies are still not chased.
4. Drag melee enemies beside the Command Hall and confirm they attack locally when no better target is active.
5. Retreat near multiple enemies and confirm move-away starts.
6. Confirm retreat is not instantly canceled by opportunistic reacquisition.
7. Confirm combat can resume after the suppression window if the unit remains in danger.
8. Hover enemy body/edge and confirm attack intent appears.
9. Hover empty terrain near an enemy and confirm it does not show attack intent.
10. Left-click an enemy and confirm intentional attack still works.
11. Drag-select over HUD/minimap, minimap-click, then press `H`; confirm the hero panel is not stale.
12. Sanity-check Tutorial defeat Results.

Deferred: worker construction remains a future feature/design pass and is not part of this retest.
