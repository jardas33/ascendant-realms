# v0.76 Implementation Report - Rival Commander Phases

Date: 2026-05-30

## Summary

Captain Malrec now participates in the Ashen Outpost finale as a staged rival commander instead of being eligible for premature coordinated attack waves.

## Runtime Changes

- Added optional AI callback gating for enemy hero attack-wave participation.
- Ashen Outpost blocks Malrec from coordinated waves until phase 3 starts.
- Phase 3 starts after the enemy Barracks / fortified line objective is broken.
- Commander release records battle stats, status copy, and minimap ping through existing systems.
- Existing enemy hero abilities remain cooldown-gated; no new boss ability or respawn logic was added.

## Tactical Plan Interaction

- Resource Push supports phase 1 foothold play.
- Guarded Advance supports phase 2 survival.
- Champion Hunt supports phase 3 commander pressure.
- Plan support is represented through phase stats and Results copy only.

## Verification

Focused unit tests cover phase progression and commander release gating. Full checkpoint verification is summarized in the top-level handoff/checkpoint docs.
