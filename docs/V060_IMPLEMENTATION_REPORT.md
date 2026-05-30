# v0.60 Retinue Persistence Implementation Report

## Summary

v0.60 formalizes the existing Retinue Camp as a tiny persistent survivor roster. Eligible units are limited to Militia, Ranger, and Acolyte, and normal trained units remain battle-only unless the player explicitly adds an eligible survivor from Results.

## Runtime Changes

- Added an explicit five-unit Retinue roster cap.
- Added persistent `battlesSurvived` and `missionsDeployed` counters to Retinue entries.
- Filtered invalid Retinue unit types from save normalization, launch requests, and active roster helpers.
- Kept survivor recruitment opt-in through the existing Results action.
- Preserved duplicate blocking by Retinue id/source unit id.

## Save Format

- No save-version bump.
- Added backward-compatible optional Retinue counters.
- Existing saves without counters default to `0`.
- Existing saves with invalid, unknown, duplicate, or non-combat Retinue entries normalize safely.
- Tutorial and non-campaign routes still do not create Retinue recruitment UI.

## Verification Notes

- Focused Retinue/save/results/package tests passed.
- `npm test`, `npm run build`, content validation, art-intake validation, hosted Retinue proxy, required hosted lanes, visual QA, controls, Act 1 telemetry, package generation, package verification, and `git diff --check` passed.
- Local release shard 1/3 timed out after 20 minutes with no summary; shards 2/3 and 3/3 passed.
- Full closeout evidence is tracked in `LLM_GAME_HANDOFF.md` and `DEVELOPMENT_CHECKPOINT.md`.
