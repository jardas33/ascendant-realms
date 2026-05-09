# v0.6 Tutorial Onboarding And Testing Foundation Report

Last updated: 2026-05-08

## Summary

v0.6 strengthens the first playable Tutorial / Proving Grounds shell into a safer onboarding and testing foundation.

This checkpoint does not add new gameplay content. It preserves the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, v0.4 technical groundwork, v0.5 save/content/determinism gate, and the existing no-reward playable tutorial shell.

## What Changed

- Added `docs/V06_TUTORIAL_FEEL_AUDIT.md`.
- Tightened tutorial copy and hierarchy.
- Improved mobile-short tutorial overlay layout.
- Added a session-only main-menu completion notice after successful tutorial completion.
- Reviewed e2e runtime placement and kept full tutorial completion in smoke while the lane remains near 5 minutes.
- Added a test-only semantic command-log V1 helper for one tutorial completion smoke path.
- Added `docs/COMMAND_LOG_V1_TEST_ONLY_PLAN.md`.
- Added `docs/COMMAND_LOG_V1_REPORT.md`.
- Added tutorial accessibility polish: polite live-region semantics, `aria-describedby`, and explicit button labels.
- Added `docs/DESKTOP_2026_VISUAL_DIRECTION.md` as planning-only future direction.

## What Did Not Change

- No rewards.
- No tutorial completion persistence.
- No campaign reward changes.
- No campaign progression changes.
- No save-version changes.
- No maps.
- No units.
- No factions.
- No workers.
- No enemy construction.
- No crafting, diplomacy, procedural generation, multiplayer, desktop packaging, external generated assets, paid APIs, or broad systems.
- No Cinderfen route balance changes.
- No production gameplay dependency on command logs.

## Tutorial Polish

The tutorial remains a twelve-step linear flow:

1. Camera Controls.
2. Select Hero.
3. Move Hero.
4. Capture Crown Shrine.
5. Gather Resources.
6. Select Command Hall.
7. Build Barracks.
8. Train Militia.
9. Set Rally Point.
10. Use Hero Ability.
11. Hold Safe Pressure.
12. Finish Training.

The copy pass shortened several instructions, removed test-hook language from player-facing hints, and made the final no-reward copy explicit. The current risk is still human feel: twelve steps may be long for first contact, and building/training/rally timing still needs real play review.

## Overlay Improvements

The overlay now has:

- Safer max-width and wrapping.
- Better mobile-short width.
- Compact two-button footer behavior.
- Polite live-region semantics.
- Instruction and condition text connected through `aria-describedby`.
- Explicit accessible labels for Next/Complete and Exit Tutorial.
- Layout coverage across desktop, tablet-short, mobile-tall, and mobile-short viewports.

## No-Reward Policy

Tutorial / Proving Grounds remains training only.

It does not grant:

- Hero XP.
- Items.
- Campaign resources.
- Campaign node completion.
- Reputation changes.
- Retinue entries.
- Rival rewards.
- Trophies.
- Stronghold changes.

The final tutorial step and the session-only main-menu completion notice both say that no rewards, resources, or campaign progress were granted and that nothing was saved.

## Save And Persistence Safety

The tutorial remains non-persistent:

- It creates transient Aster launch data only.
- It does not write a hero save.
- It does not write settings.
- It does not write campaign progress.
- It does not write inventory, equipment, XP, skills, resources, event choices, town services, Stronghold upgrades, retinue, rivals, or trophies.
- It does not store a tutorial-completed flag.

Smoke coverage continues to assert that completion and exit leave the save key absent.

## Command-Log V1 Status

Command Log V1 is implemented as test-only infrastructure:

- Helper: `tests/e2e/semantic-command-log.ts`.
- First consumer: Tutorial / Proving Grounds full completion smoke path.
- Scope: semantic Playwright/test-hook sequencing only.
- Status: useful enough to keep, not ready to expand broadly.

It remains outside production code. It is not a production replay system, not deterministic lockstep, not multiplayer infrastructure, not a save feature, and not a player-facing command recorder.

Recommended next command-log candidate after the final v0.6 gate: the existing deep-flow capture/build/train/rally/victory reward path, only if the tutorial command log remains stable and makes failures easier to diagnose.

## E2E Lane Impact

Current lane policy:

- Keep full Tutorial / Proving Grounds completion in smoke while smoke remains near 5 minutes.
- Move full tutorial completion deeper only if smoke repeatedly exceeds the 6-7 minute watch band or becomes flaky.
- Keep at least one tutorial launch/overlay/exit/no-save smoke test if completion ever moves out of smoke.
- Preserve release coverage.

Recent v0.6 runtime evidence:

- Smoke: 12 tests in 4.8m after command-log and accessibility polish.
- Layout: 25 tests in 12.5m after accessibility polish.
- Release: 65 tests in 28.8m after command-log V1.

## Desktop Future Direction

`docs/DESKTOP_2026_VISUAL_DIRECTION.md` documents a future desktop-quality aspiration without implementation.

Recommended stance:

- Keep proving the browser game first.
- Do not add desktop packaging, an engine switch, 3D rewrite, or asset-production dependency now.
- Use original IP guardrails for future factions, visuals, UI language, audio, and lore.
- Consider a tiny desktop prototype spike only after the browser gameplay, tutorial, save/content validation, command-log testing, and performance foundation are stronger.

## Remaining Risks

- Human tutorial feel remains unproven.
- The tutorial may feel long for experienced players.
- Mobile-short overlay is automated-width-safe but still needs real-device-style review.
- No-reward completion clarity may need warmer copy after human play.
- Command-log V1 is intentionally young and should not spread until it proves useful.
- Release lane remains green but slow, especially layout and deep-flow.
- The Phaser vendor chunk warning remains known.
- Future desktop/visual ambition could distract from browser gameplay if acted on too early.

## Next Recommended Goal

Recommended next long-running goal:

Human-play Tutorial / Proving Grounds and perform a small v0.6.1 tutorial feel pass.

Suggested scope:

- Human-paced tutorial run on desktop and mobile-ish viewport.
- Copy tweaks from real play only.
- Minor overlay hierarchy/spacing adjustments.
- Confirm no-reward completion clarity.
- Keep command-log V1 at one consumer unless failures show a concrete reason to expand.
- No new maps, units, factions, rewards, save persistence, campaign integration, workers, enemy construction, crafting, diplomacy, procedural generation, multiplayer, desktop packaging, external assets, or broad systems.

## Phase 11 Verification

```text
npm test
PASS: 42 files / 315 tests.

npm run build
PASS with the known Phaser vendor warning.
App JS: assets/index-DN-Hs_qy.js, 459.85 kB / gzip 123.62 kB.
CSS: assets/index-BzEbtAWy.css, 44.19 kB / gzip 9.11 kB.
Vendor JS: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 tests in 5.0m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.
Telemetry regenerated with no git diff.

git diff --check
PASS.
```
