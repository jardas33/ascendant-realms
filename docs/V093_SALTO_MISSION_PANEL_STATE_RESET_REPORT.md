# v0.93 Salto Mission Panel State Reset Report

Checkpoint: v0.93 Runtime UI Foundation Tokens and Mission-Panel State Reset

## Problem

The campaign map could preserve a scrolled, expanded selected-mission panel posture after inspecting another mission. In practice this made returning to Salto Outskirts feel like the player landed midway through a details drawer, with the primary action less confidently framed.

## Fix

`CampaignMapScene` now treats campaign node changes as an explicit presentation-state boundary.

When the selected node id changes:

- selected mission panel `scrollTop` resets to `0`;
- ordinary `More Details` collapses;
- choice-bearing details can remain open for choice nodes;
- the selected mission panel receives safe focus after the render pass;
- the primary action remains visible without default page scroll.

When the same node is re-rendered by a non-selection change, the panel can preserve its current details/scroll posture.

## Save Safety

No save fields were added. The only saved campaign value touched by node selection remains the existing `selectedNodeId` and `selectedChapterId` behavior. The regression test compares completion and reward-claim arrays before and after the reset path to prove mission progress and reward state are not changed by the presentation reset.

## Lock And Progression Safety

The fix does not alter:

- campaign unlock rules;
- locked-node preview rules;
- fresh-campaign Salto selection;
- battle launch eligibility;
- reward, XP, replay, or Tutorial behavior.

## Regression Coverage

Added Playwright coverage for:

- selecting locked Aether Well Ruins;
- opening and scrolling its details;
- returning to Salto Outskirts;
- verifying scroll reset;
- verifying `More Details` collapsed;
- verifying primary action visible above the fold;
- verifying click target size;
- verifying no node overlap, horizontal overflow, text clipping, or nested-card clutter;
- verifying campaign completion/reward arrays are unchanged.

## Verification

Verified in:

- `npx playwright test tests/e2e/layout.spec.ts --grep "v0.93" --reporter=line` - PASS, 1 test.
- `npm run test:e2e:release:hosted:layout-core` - PASS, 26 tests, including the v0.93 Salto reset regression.
- `npm run test:e2e:smoke:fast` - PASS after tightening campaign shell vertical spacing.
- `npm run visual:qa` - PASS with `v093-salto-panel-reset-1366.png`.

Non-pass evidence: the first focused v0.93 layout run showed panel focus was not reliably retained after DOM replacement; the reset now repeats focus after the browser click/default cycle. The first smoke-fast rerun showed map height at `408.7px` against the `410px` acceptance floor; the campaign shell gap was reduced from `7px` to `5px`, and the rerun passed.
