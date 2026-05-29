# v0.50 Act 1 Release-Candidate Notes

## Candidate Intent

This checkpoint packages Act 1 as a playable release-candidate loop for private retest:

- Tutorial / Proving Grounds stays practice-only.
- Border Village starts the persistent campaign.
- Old Stone Road teaches base development.
- Aether Well Ruins teaches resource control.
- Bandit Hillfort teaches rival pressure and staging.
- Ashen Outpost anchors champion defeat, relic choice, skill reminders, and Act 1 completion pressure.
- Replays remain safe for optional-objective cleanup and build practice.

## What Changed For Testers

- Act 1 telemetry report is included in the package as Markdown and JSON.
- Campaign and Results copy is more direct about Worker training, production, site assignment, army staging, relic equip, skill spending, and replay safety.
- Package validation now requires the v0.48-v0.50 audit, telemetry, release-candidate notes, implementation reports, and Emmanuel retest checklist.

## What Did Not Change

- No new maps or factions.
- No runtime art/assets.
- No save-version bump.
- No shop, crafting, giant quest system, or new major mechanic.
- No global rebalance.
- No broad AI/pathing rewrite.
- No Patrol or formations.
- No force-click or DOM fallback for canvas/world clicks.

## Release-Candidate Read

The deterministic Act 1 report supports copy/readability polish rather than numeric tuning. Safe Beginner clears every Act 1 campaign battle, while harder-node failures cluster around greedy/rushed scripts. Manual testers should focus on whether the route feels understandable, fair, and replay-safe.

## Package Requirements

The clean final package must:

- Have no `-dirty` suffix.
- Point to the final v0.48-v0.50 commit.
- Set working tree dirty to `no`.
- Include `V050_EMMANUEL_RETEST_CHECKLIST.md`.
- Include `ACT1_PLAYABILITY_TELEMETRY.md` and `ACT1_PLAYABILITY_TELEMETRY.json`.
- Pass `npm run verify:playtest-package`.
