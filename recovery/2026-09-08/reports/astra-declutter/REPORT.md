# Hollowspan Astra Settlement Declutter R1

## Current classification

`CANDIDATE_01_PROVISIONAL_HUMAN_REVIEW_REQUIRED`

Candidate-01 is a bounded, presentation-only spatial candidate. Fresh headed Godot 4.6.3 captures show a clearer HQ breathing ring and less crowded defensive/logistics composition at ordinary RTS scale. This is not an integration or visual approval: independent human classification is still required before any commit or promotion.

## Candidate change

- `guard_tower`: local composition position `(-4, 0, 11)` -> `(-1, 0, 8)`.
- `supply_awning`: `(17, 0, -1)` -> `(20, 0, 2)` within the existing logistics zone.
- settlement anchor: `(8, 0, 8)` -> `(12, 0, 12)`, moving the existing 14-piece Astra kit 5.657 m farther from the starting HQ without changing its internal asset set.

## Evidence

- Baseline: [01_R14_HOLLOWSPAN.png](D:/CodexData/evidence/hollowspan-astra-declutter-r1/baseline/direct/01_R14_HOLLOWSPAN.png)
- Candidate: [01_R14_HOLLOWSPAN.png](D:/CodexData/evidence/hollowspan-astra-declutter-r1/candidate-01/01_R14_HOLLOWSPAN.png)
- Runtime manifests: `baseline/direct/tactical-hierarchy-manifest.json` and `candidate-01/tactical-hierarchy-manifest.json`.

Both captures passed the existing headed tactical-hierarchy hook at 1920x1080, default zoom 40.0, camera pitch -55 degrees, with intended Godot exit code 0. The capture directly boots the production GameWorld and pauses for a stable frame; it is a runtime smoke/capture proof, not a fresh full public-input route.

## Gate

No production commit, stage, push, merge, rebase, or integration was performed. The candidate remains local-only and uncommitted on the visual-convergence lane pending Director/human visual review.
