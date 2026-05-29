# v0.50 Implementation Report - Act 1 Release-Candidate Stabilization

## Scope

v0.48-v0.50 stabilizes the existing Act 1 route through deterministic telemetry, copy/readability polish, replay/reward clarity, package hardening, and release-candidate docs. It does not add a new major system.

## Runtime Changed

- Added Act 1 deterministic playability telemetry report generation.
- Added `npm run playtest:act1`.
- Added `ACT1_PLAYABILITY_TELEMETRY.json` and `ACT1_PLAYABILITY_TELEMETRY.md`.
- Polished Act 1 campaign and Results guidance for Worker training, production, resource sites, upgrades, army staging, skills, relics, and replay safety.
- Updated package metadata and validation for v0.48-v0.50.

## Save Format

No save-version bump and no new save fields.

## Act 1 Playability

The intended route remains:

1. Tutorial / Proving Grounds.
2. Border Village.
3. Old Stone Road.
4. Aether Well Ruins.
5. Bandit Hillfort.
6. Ashen Outpost.
7. Replay and optional objective cleanup.

Safe Beginner clears every Act 1 campaign battle in deterministic telemetry. Harder-node failures remain strategy-spread watchpoints instead of automatic numeric tuning triggers.

## Onboarding Polish

Copy now emphasizes:

- Train Workers early.
- Keep production active.
- Assign Workers to captured sites.
- Upgrade safe income before risky pushes.
- Build mixed armies and hold after waves.
- Spend skill points before milestone battles.
- Equip relics/gear and review relic choice after champion victory.
- Treat replay rewards and already-claimed objective credit as safe repeat-play rules.

## Results And Replay Clarity

Existing Results and campaign surfaces continue to distinguish:

- First clear.
- Replay.
- Already claimed.
- Optional objective recorded or still open.
- Relic reward choice/equipped state.
- Skill point reminders.
- Next mission unlocked.

## Verification

```text
npm test -- src/game/playtest/Act1PlayabilityTelemetry.test.ts src/game/core/FirstExperienceGuidance.test.ts src/game/core/campaign/CampaignActSpineRules.test.ts src/game/campaign/CampaignPresentationViewModels.test.ts src/game/results/ResultsViewModel.test.ts src/game/playtest/PlaytestPackageValidation.test.ts PASS, 6 files / 46 tests.
npm run playtest:act1 PASS, wrote ACT1_PLAYABILITY_TELEMETRY.md/json, summarized 180 Act 1 runs from 255 deterministic simulator runs.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
git diff --check PASS before final docs closeout.
npm test PASS, 75 files / 575 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "first campaign battle path|Ashen Outpost special objectives|Old Stone Road victory" --reporter=line PASS, 3 hosted proxy tests.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS on rerun with a longer budget, 14 tests. First attempt timed out without a summary and is non-pass evidence.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS on rerun, 27 tests. First attempt timed out at 10 minutes without a summary and is non-pass evidence.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run test:e2e:release TIMED OUT after 40 minutes without a summary; non-pass evidence.
npm run test:e2e:release:shard1of3 PASS after starting and verifying a local dev server, 44 tests. Earlier shard attempts timed out once and then failed 44/44 with ERR_CONNECTION_REFUSED before the server was manually started.
npm run test:e2e:release:shard2of3 PASS against the verified local dev server, 34 tests.
npm run test:e2e:release:shard3of3 PASS against the verified local dev server, 14 tests.
```

## Package

Package metadata now names `v0.48-v0.50 Act 1 playability and release-candidate stabilization`, and package validation requires v0.48-v0.50 docs plus the Act 1 telemetry artifacts. Regenerate the final clean package after the final checkpoint commit so build info can match the committed hash with dirty status `no`.
