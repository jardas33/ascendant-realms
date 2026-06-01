# v0.102 Save Fixture Library Spec

Status: implemented for the browser save translation-contract proof.

## Purpose

v0.102 freezes a deterministic fictional fixture library for future desktop save-translation experiments. The fixtures are not user saves, are not copied from localStorage, and do not change browser save behavior.

## Location

```text
tests/fixtures/saves/v0102/
```

The fixture manifest is:

```text
tests/fixtures/saves/v0102/manifest.json
```

## Fixture Coverage

The library includes:

- V1 fresh hero.
- V1 campaign in progress.
- V2 fresh hero.
- V2 Act 1 in progress.
- V2 relic and equipment state.
- V2 skill-tree state.
- V2 Retinue ready state.
- V2 Retinue recovering state.
- V2 completed Act 1 and replay posture.
- V2 rival state.
- V2 accessibility and UI-scale settings.
- V2 unknown extra field.
- V2 unknown content ID.
- Corrupt JSON.
- Missing required object.
- Unsupported future version.

## Rules

- Fixtures use fixed timestamps and deterministic IDs.
- Fixtures are compact and hand-authored for review.
- Fixtures must not contain real player names, full localStorage dumps, screenshots, telemetry captures, or private feedback.
- Accepted fixtures normalize through the existing browser save migration/normalization path.
- Unsafe fixtures are expected to produce either quarantine records or rejection records.

## Save Boundary

`CURRENT_SAVE_VERSION` remains `2`. v0.102 adds no browser save migration, no desktop save path, no profile UI, and no runtime save-field change.

