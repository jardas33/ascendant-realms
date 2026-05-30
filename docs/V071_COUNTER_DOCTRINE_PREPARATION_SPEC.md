# V071 Counter-Doctrine Preparation Spec

## Goal

Make doctrine reads useful by pairing each enemy doctrine with recommended tactical plans and response copy. Recommendations guide the player without forcing choices or inflating difficulty.

## Recommendation Matrix

- Raider: Guarded Advance. Protect Workers and resource sites; screen with Militia.
- Fortress: Resource Push. Build economy and prepare sustained assault before pushing defenses.
- Hunter: Guarded Advance or Champion Hunt. Keep hero and Retinue covered; avoid isolated dives.
- Warband: Guarded Advance or Champion Hunt. Regroup before late pressure and save Retinue reinforcement for a safe timing.

## Runtime Relationship

- Tactical plans do not change doctrine selection.
- Doctrine selection remains based on mission type, modifiers, commander, and existing data.
- Plan effects are modest launch modifiers and do not globally rebalance Act 1.
- Retinue, reinforcement, hero skills/relics, Workers/sites/upgrades, control groups, Patrol, formation-aware movement, replay rules, and Tutorial protection must remain intact.

## Results Copy

Results should show:

- selected plan name,
- effect summary,
- expected doctrine/counterplay continuity,
- short after-action line,
- reminder that tactical plans are launch-local and do not alter saves.

## Save Compatibility

- No new save fields.
- Existing saves load unchanged.
- Plan id is carried only in the battle launch request and Results data.
- Unknown plan ids fall back safely.

## Deferrals

- Enemy adaptation to player plans.
- Persistent campaign intel.
- Tactical plan unlock trees.
- Plan-specific animations or art.
