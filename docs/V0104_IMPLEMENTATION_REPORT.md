# v0.104 Implementation Report

## Summary

v0.104 implements profiler-guided rendering skips and HUD-density controls within the existing battle HUD, private profiler, private playtest hub, visual QA, and package-validation systems.

## Code Changes

- `BattleScene` now skips ordinary HUD snapshot construction until the existing 0.1s UI cadence is due, while forced refreshes remain immediate.
- Fog and Lume rendering now use signatures to skip redundant redraws when rendered state is unchanged.
- `MinimapView` caches stable SVG markup by marker/camera/ping/fog signature.
- `HudDensity` defines public Minimal and private Standard/Debug density behavior.
- `HudRoot`, `HeroHudPanel`, and `ObjectivePanel` render density-aware markup and private Debug counters.
- Private Performance Lab now includes `perf_hud_minimal`, `perf_hud_standard`, and `perf_hud_debug`.
- Performance scripts now write v0.104 summaries and v0.103-to-v0.104 deltas.
- Visual QA now includes a 17-screenshot v0.104 HUD-density group.
- Playtest package validation now requires the v0.104 reports/checklists.

## Safety

No save data, localStorage, campaign progression, rewards, XP, Retinue, relics, reputation, gameplay values, stable IDs, maps, factions, imported/generated art, Lume rules, pathing, or runtime/internal title were changed.

## Verification

```text
npm test - PASS, 105 files / 736 tests.
npm run build - PASS with the known Phaser/vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS.
npm run export:portable-content - PASS, 229 stable-ID manifest entries.
npm run validate:portable-content - PASS, deterministic two-pass export.
npm run test:save-translation-contract - PASS, 16 fixtures / 11 translated / 2 quarantined / 3 rejected.
npm run perf:profile:private - PASS, 20 private scenarios.
npm run perf:report:private - PASS.
npm run test:e2e:smoke:fast - PASS, 10 tests.
npm run test:e2e:smoke - PASS, 17 tests.
npm run test:e2e:release:hosted:smoke - PASS, 17 tests.
npm run test:e2e:release:hosted:deep-meta - PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle - PASS, 31 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure - PASS, 8 tests.
npm run test:e2e:release:hosted:layout-core - PASS, 27 tests.
npm run test:e2e:release:hosted:layout-cinderfen - PASS after aligning the two Ashen Outpost hosted layout checks with the existing Cinderfen battle timeout, 12 tests.
npm run visual:qa - PASS, 189 screenshots, 0 console errors, 0 screenshot retries.
npm run visual:review-pack - PASS, 189 screenshots and 7 contact sheets.
npm run playtest:controls - PASS, 18 rows.
npm run playtest:controls:extended - PASS, 90 rows.
npm run playtest:controls:verify - PASS, 1,658 checks.
npm run playtest:act1 - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
```

Final clean package generation and package verification are run after the checkpoint commit so the package does not carry a dirty suffix.
