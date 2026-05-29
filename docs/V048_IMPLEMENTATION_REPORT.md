# v0.48 Implementation Report - Act 1 Playability Audit

## Scope

v0.48 adds the Act 1 playability audit layer and deterministic telemetry output for the release-candidate stabilization pass. It does not add maps, factions, runtime art/assets, shop, crafting, new save fields, or broad gameplay systems.

## Runtime Changed

- Added `Act1PlayabilityTelemetry` to summarize the existing deterministic simulator for the Act 1 route.
- Added `npm run playtest:act1`.
- Added machine-readable `ACT1_PLAYABILITY_TELEMETRY.json`.
- Added human-readable `ACT1_PLAYABILITY_TELEMETRY.md`.
- Tightened Act 1 onboarding copy for Worker training, production, site assignment, army staging, relic equip, skill spending, and replay-safe rewards.

## Save Format

No save-version bump and no new save fields. The audit and guidance are content/tooling changes over existing campaign, replay, reward, relic, and skill state.

## Telemetry Result

The v0.48 telemetry pass summarized 180 Act 1 campaign battle runs from the 255-run deterministic simulator suite. Safe Beginner wins every Act 1 campaign node, so no numeric tuning was made from automation alone. Aether Well Ruins, Bandit Hillfort, and Ashen Outpost remain manual watchpoints for strategy spread and staging clarity.

## Tests Added

- `Act1PlayabilityTelemetry.test.ts` covers route coverage, Tutorial evidence boundary, Safe Beginner stability, strategy-spread labeling, and Markdown rendering.

## Verification

Final verification is recorded in `V050_IMPLEMENTATION_REPORT.md`. Focused v0.48 coverage passed: Act 1 telemetry/guidance/package tests with 46 tests, `npm run playtest:act1`, content validation, art-intake validation, and the focused hosted Act 1 proxy.
