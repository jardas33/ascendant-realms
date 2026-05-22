# v0.16.10 Release-Candidate Decision

Date: 2026-05-22

## Decision

`83f146e` is ready for Emmanuel's manual retest and a small 2-5 external tester batch, provided the build is described as a private prototype release candidate rather than a final release.

v0.16.10 itself is a freeze and tester-kit polish pass. It does not change runtime gameplay.

## Automated Confidence

- v0.16.7 fixed the reported combat/control defects narrowly.
- v0.16.8 and v0.16.9 added focused unit, control-lab, hosted, full-release, visual QA, and package evidence.
- GitHub Actions #80 passed the enabled workflow-dispatch release matrix on the post-v0.16.7 runtime stack.
- GitHub Actions #83 passed Fast confidence on the v0.16.9 final hash.
- The v0.16.9 private package was clean and verified.

## Remaining Human Risk

- Emmanuel has not manually retested the v0.16.7/v0.16.9 package yet.
- Automated tests cannot prove attack cursor readability, combat feel, or whether retreat feedback is clear enough in dense fights.
- First external testers may still find onboarding confusion, Results copy gaps, or visual parsing problems that automated checks cannot judge.

## Known Watchpoints

- Hold Ground adjacent follow-up after the first enemy dies.
- Local melee enemy aggro beside the Command Hall.
- Retreat near multiple enemies, especially if one unit is physically blocked.
- Attack cursor visibility over enemy edges and dense clusters.
- Drag-select over HUD/minimap plus minimap click and `H` hero select.
- Tutorial defeat Results flow.
- Source/license proof for current prototype image assets before any production asset approval.

## Deferred Features

- Worker construction/builders.
- New units, buildings, maps, factions.
- Patrol runtime and formations.
- Combat VFX, new cursor art, target decals, and broader visual overhaul.
- Balance/stat/wave tuning.
- Save migrations.

## Release-Candidate Rule

If Emmanuel's manual retest finds a direct regression in v0.16.7's combat/control fixes, keep the response in v0.16.x and fix only that failing behavior. If the retest is clean, the next useful work is human playtest intake and v0.17 planning, not more speculative combat rewrites.
