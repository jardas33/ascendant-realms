# Tutorial Content Validation Gate

Date: 2026-05-08

Status: active for the first playable Tutorial / Proving Grounds shell.

## Purpose

Tutorial / Proving Grounds is now a small playable onboarding shell, so tutorial metadata must fail fast when a future edit breaks launch safety, no-reward policy, or existing-content references.

This gate intentionally validates metadata only. It does not add maps, units, factions, rewards, save fields, campaign nodes, workers, enemy construction, crafting, diplomacy, procedural generation, multiplayer, or desktop packaging.

## What Validates

`npm run validate:content` runs `tools/validateContent.ts`, which imports the same `validateContent()` path used by `src/game/data/contentValidation.test.ts`.

Tutorial-specific validation lives in `src/game/data/validation/validateTutorials.ts` and currently checks:

- Tutorial IDs are unique.
- Tutorial status is one of `planned`, `scaffolded`, or `playable`.
- Tutorial launch mode, when present, is `battle`.
- Playable tutorials include a valid `mapId`.
- Referenced tutorial maps exist.
- `proving_grounds_basics` keeps `noReward: true`.
- Tutorials include at least one step.
- Step IDs are unique within each tutorial.
- Each step has title, description, and instruction copy.
- Step `type`, `objectiveType`, and `requiredAction` are from the supported fixed lists.
- Step references to maps, units, buildings, abilities, resources, and capture sites exist.
- Capture site references belong to the tutorial map when a tutorial map is set.

## Current Tutorial Metadata

Current tutorial:

- `id`: `proving_grounds_basics`
- `status`: `playable`
- `launchMode`: `battle`
- `mapId`: `first_claim`
- `noReward`: `true`
- Step count: 12

The tutorial reuses current First Claim content only. It has no tutorial reward table, no campaign node, no save field, and no persisted completion flag.

## Required Tests

Current test coverage in `src/game/data/contentValidation.test.ts` includes:

- Duplicate tutorial IDs are rejected.
- Duplicate step IDs are rejected.
- Playable tutorial without `mapId` and without steps is rejected.
- Invalid tutorial status and launch mode are rejected.
- Invalid step type, objective type, and required action are rejected.
- Invalid tutorial-level and step-level map references are rejected.
- Missing unit, building, ability, resource, and capture-site references are rejected.
- `noReward: false` on `proving_grounds_basics` is rejected.
- Current valid tutorial metadata produces no validation errors through the full content gate.

## Edit Policy

Future tutorial edits should follow `CONTENT_GUIDE.md`:

- Keep `proving_grounds_basics` no-reward.
- Keep steps short, linear, and metadata-driven.
- Reference existing content IDs in `references` so validation catches typos.
- Do not expose a playable launch path unless metadata validates.
- Do not add persistence without a separate save fixture/audit phase.
- Do not add tutorial rewards, campaign node completion, new maps, new units, new factions, workers, enemy construction, crafting, diplomacy, procedural generation, multiplayer, desktop packaging, or external assets.

## Commands

Run after any tutorial metadata edit:

```bash
npm run validate:content
npm test -- src/game/data/contentValidation.test.ts
```

For tutorial runtime or UI changes, also run:

```bash
npm run build
npm run test:e2e:smoke
```

## Known Gaps

- The validator does not prove tutorial step ordering feels good. That remains a readability/playtest concern.
- The validator does not prove live controls satisfy each step. Smoke e2e covers the current path.
- The validator does not validate future branching tutorials because the first shell is deliberately linear.
- The validator does not allow any tutorial reward policy beyond the current `noReward` first shell.
