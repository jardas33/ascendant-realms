# v0.39 Campaign Progression Foundation Implementation Report

Date: 2026-05-28

## Scope

v0.39 makes the campaign map present mission progression more clearly. Completed battle nodes are now replayable, selected-node details distinguish first-clear and replay state, and mission reward previews show whether campaign node rewards are still available or already claimed.

## Runtime Changes

- Completed battle nodes can be launched again through the existing campaign map start button.
- Completed battle node cards read as replayable while preserving the completed marker for existing tests and player scanning.
- Selected-node details show first-clear/replay status, campaign reward state, replay rules, reward preview, optional objective summary, and small Warrior / Seer / Commander build hints for rival commander battles.

## Save Format

No save-version bump is used. Replay state is derived from existing `completedNodeIds`, `nodeRewardsClaimedIds`, and hero `clearedMapIds`.

## Deferrals

No new maps, factions, art/assets, shop, crafting, broad campaign rewrite, broad AI/pathing rewrite, Patrol, formations, or global rebalance were added.

## Verification

Final verification is recorded in `docs/V041_IMPLEMENTATION_REPORT.md`.
