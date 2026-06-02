# v0.103 Implementation Report

## Runtime Changed

- Added a private/dev-only performance profiler and Performance Lab launch scenarios.
- Added scene-level private counters for display objects, labels, Lume links, fog redraws, minimap refreshes, HUD updates, and notifications.
- Reduced capture-site steady-state ring and label clutter.
- Reduced stable Lume Auto rendering clutter while keeping selected endpoints and transition pulses readable.
- Compacted Lume HUD optional details and private preview button copy.

## Save Format

No save format change. `CURRENT_SAVE_VERSION` is unchanged. The profiler does not write localStorage or persistent saves.

## Private Safety

Performance Lab scenarios are private Playtest Hub entries. They use existing no-save fixture isolation and do not alter rewards, XP, Retinue, relics, reputation, campaign progress, or stable IDs.

## Verification

Passed:

- `node -e "JSON.parse(require('fs').readFileSync('docs/V0103_PERFORMANCE_LAB_SCENARIO_MANIFEST.json','utf8'))"`
- `npm test` - 103 files / 730 tests.
- `npm run build` - passed with the known Phaser/vendor chunk-size warning.
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run export:portable-content` - 229 stable-ID manifest entries.
- `npm run validate:portable-content` - deterministic two-pass export matched byte-for-byte.
- `npm run test:save-translation-contract` - 16 fixtures / 11 translated / 2 quarantined / 3 rejected.
- `npm run perf:profile:private` - 17 private scenarios.
- `npm run perf:report:private`
- `npm run test:e2e:smoke:fast` - 10 tests.
- `npm run test:e2e:smoke` - 17 tests.
- `npm run playtest:controls` - 18 rows passed.
- `npm run playtest:controls:extended` - 90 rows passed.
- `npm run playtest:controls:verify` - 1,658 checks.
- `npm run playtest:act1` - summarized 180 Act 1 runs from 255 deterministic simulator runs.
- `npm run test:e2e:release:hosted:smoke` - 17 tests.
- `npm run test:e2e:release:hosted:deep-battle` - 31 tests on rerun.
- `npm run test:e2e:release:hosted:deep-campaign-pressure` - 8 tests on rerun.
- `npm run test:e2e:release:hosted:layout-core` - 27 tests.
- `npm run test:e2e:release:hosted:layout-cinderfen` - 12 tests.
- `npm run visual:qa` - 172 screenshots, 0 console errors, 0 retries.
- `npm run visual:review-pack` - 172 screenshots, 7 contact sheets.
- `git diff --check` - passed with only the existing `.gitignore` Windows line-ending notice.

Non-pass evidence:

- Hosted deep-battle first wrapper timed out at 20 minutes; rerun passed with a longer wrapper.
- Hosted deep-campaign-pressure first rerun caught the old Lume Auto visible-link assertion; the assertion now verifies stable Auto is quiet and Always is explicit inspection.
- Visual QA first wrapper timed out at 30 minutes, then exposed the private profiler panel intercepting hub controls. The panel is now display-only for pointer events and the full visual QA rerun passed.

Final clean package generation and package verification are intentionally run after the checkpoint commit so the package path has no `-dirty` suffix.
