# v0.21.1 Worker Repair Closeout And CI Verification

Date: 2026-05-24
Status: closeout/package metadata pass

## Scope

v0.21.1 closes out v0.21 without adding gameplay features. It pushes the Worker repair foundation, records remote CI status, refreshes package metadata, and keeps Emmanuel's next retest focused on repair confidence.

No harvesting, repair expansion, enemy repair AI, enemy construction AI, new units/buildings/maps/factions, runtime art/assets, save migration, broad AI/pathing rewrite, global rebalance, Patrol, formations, or test weakening are included.

## Baseline

- Starting commit: `79d038b`, `Checkpoint v0.21 worker repair foundation`.
- Starting branch state: clean `main`, ahead of `origin/main` by one commit.
- Pushed `79d038b` to `origin/main`; branch returned clean/synced.
- Runtime changed in this closeout: no.

## Remote CI

- GitHub Actions push run `26374133694` on `main` / `79d038b`: Fast confidence passed.
- Push workflow rules skipped Optional visual QA, Release simulator, hosted release groups, and Full release e2e.
- Exact workflow-dispatch release matrix for `79d038b` was not triggered from this environment because the local `gh` CLI is unavailable and the available GitHub connector does not expose workflow_dispatch creation. Run CI Release Matrix Dry Run manually on `main` with `run_release_matrix=true` if exact remote hosted/simulator evidence is needed.

## Package Metadata

- Package checkpoint string now identifies `v0.21.1 worker repair closeout and CI verification`.
- Private playtest packages now include this closeout note as `V0211_WORKER_REPAIR_CLOSEOUT.md`.
- Package validation now requires the closeout note and the v0.21.1 checkpoint string.

## Worker Repair Retest Focus

1. Command Hall still trains Workers only.
2. Workers still build Barracks, Mystic Lodge, and Watchtower.
3. Construction pause/resume and base-cluster pathing still behave like v0.18.3.
4. Damaged friendly completed buildings can be repaired by a nearby Worker.
5. Explicit move or attack pauses repair without pulling the Worker back.
6. Moving the Worker back or reissuing Repair resumes repair.
7. Enemy buildings cannot be repaired.
8. Full-health buildings show already repaired/full-health feedback and do not start repair.
9. Incomplete buildings remain construction sites and do not become repair targets.
10. Completed Barracks, Mystic Lodge, Watchtower, and upgrade roles remain stable.

## Verification

Requested v0.21.1 closeout gate:

```text
npm exec vitest run src/game/playtest/PlaytestPackageValidation.test.ts -- --reporter=dot PASS, 1 file / 3 tests.
npm test PASS, 64 files / 478 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-79d038b-dirty generated.
npm run verify:playtest-package PASS, 57 checks.
git diff --check PASS.
```

Closeout note: after the v0.21.1 metadata commit, regenerate and verify the final clean package from the final commit and confirm the package name does not end in `-dirty`.
