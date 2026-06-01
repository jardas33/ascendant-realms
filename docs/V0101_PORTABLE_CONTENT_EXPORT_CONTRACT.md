# v0.101 Portable Content Export Contract

Status: implemented for v0.101 as a downstream-only tooling contract. TypeScript content definitions remain authoritative.

## Purpose

The portable export gives later engine experiments deterministic JSON content without hand-copying engine-native data. It is not a new runtime source of truth and must not be edited as design data.

## Commands

```text
npm run export:portable-content
npm run validate:portable-content
```

Generated output:

```text
artifacts/portable-content/latest/content-export.json
artifacts/portable-content/latest/stable-id-manifest.json
artifacts/portable-content/latest/content-export-summary.md
artifacts/portable-content/latest/content-export-hashes.json
```

The generated artifact folder is ignored by git. The committed freeze point is the compact snapshot at `src/game/portable/stable-id-snapshot.json`.

## Export Rules

- TypeScript definitions remain authoritative.
- Exported JSON is deterministic and sorted by category and id.
- Export includes no timestamps, machine-local absolute paths, random seeds, or dirty-state markers.
- Export uses only existing source data and rules references.
- Export does not change runtime behavior, saves, stable IDs, balance, gameplay, package posture, or engine posture.
- Validation runs existing content validation first, then portable-export checks.
- Validation generates twice and compares the four output files byte-for-byte.

## Included Categories

The v0.101 export includes factions, resources, hero classes, origins, abilities, skills, relics, equipment, units, unit roles, buildings, upgrades, Stronghold upgrades, maps, capture sites, chapters, campaign nodes, mission types, rewards, optional objectives, modifiers, enemy personalities, enemy pressure plans, enemy heroes, enemy hero abilities, enemy doctrines, elite squads, tactical plans, battlefield events, Act 1 campaign spine, Act 1 finale definitions, Lume networks, and Retinue rule references.

## Validation Failures

Validation fails on duplicate ids, missing categories, empty categories, unsorted categories, non-portable ids, missing references, unknown references, stable-ID snapshot drift, nondeterministic output, inconsistent hashes, and invalid existing content data.

## Deferrals

- No engine-native file generation.
- No save translation.
- No desktop runtime integration.
- No hand-authored JSON source of truth.
- No generated or imported art.
