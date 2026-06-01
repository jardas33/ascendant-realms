# v0.96 Tutorial UX Rescue Report

Status: implemented and verified; final command evidence is recorded in `docs/V096_IMPLEMENTATION_REPORT.md`.

## Tutorial Sequence

The Proving Grounds sequence is tightened to:

1. Select Aster.
2. Select starting troops.
3. Move to the road.
4. Capture Crown Shrine.
5. Select Command Hall.
6. Build Barracks.
7. Assign a Worker to Crown Shrine.
8. Train Militia.
9. Set rally point.
10. Cast Rally Banner.
11. Defeat Raider pressure.
12. Complete training.

## Readability Changes

- The previous opening camera-only step is moved into More Help so the first visible task is concrete.
- Long visible instructions are split into short action plus optional reason.
- Worker site assignment becomes a distinct objective instead of hidden prose.
- Completion feedback, progress, next action, and no-reward copy remain explicit.

## Safety

- Tutorial launch remains `mode: tutorial` with `rewardsDisabled`.
- Tutorial completion still ends through the existing no-reward Results path.
- No save fields, reward rules, campaign node state, stable IDs, or map data are changed.
- Lume remains excluded from Tutorial.

## Known Limits

- The Tutorial still uses the existing First Claim map rather than a custom teaching arena.
- Worker assignment requires the player to train or select a Worker through existing production controls.
- Focus Objective is a camera assist, not a navigation autopilot.
