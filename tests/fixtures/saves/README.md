# Save Fixture Test Data

This directory stores small, hand-authored save files used by the v0.5 save compatibility gate.

## Purpose

Save fixtures protect compatibility for old and current localStorage save shapes. They should prove that real saves keep loading after future migration, normalization, content validation, and campaign expansion work.

Fixtures are test data only. Production runtime modules must not import files from this directory.

## Naming

Use names that identify the save version and the risk being protected:

```text
v1-basic-hero.json
v2-settings-only.json
v2-campaign-progress.json
v2-affixed-inventory.json
v2-legacy-equipment-catalog-id.json
v2-retinue-rivals-cinderfen.json
v2-missing-optional-fields.json
v2-future-extra-fields.json
invalid-json.txt
```

Prefer one compatibility risk per fixture. Add a new fixture instead of editing an old one unless the old file was impossible or misleading.

The `v0102/` subdirectory is the browser save fixture library for the desktop translation-contract proof. Its manifest-driven fixtures cover V1/V2 migration, Act 1 progress, relic/equipment, skills, Retinue, rival state, settings, unknown fields, unknown content ids, corrupt JSON, missing required objects, and unsupported future versions. These fixtures remain fictional and deterministic; they are not user localStorage dumps.

## Update Policy

- Keep fixtures small enough to review in a normal diff.
- Use fixed timestamps and deterministic IDs.
- Do not store full browser localStorage dumps unless a future migration truly requires one.
- Do not store screenshots, Playwright traces, generated telemetry, or asset data here.
- Do not couple fixture assertions to UI copy, layout, route text, or generated item names unless that text becomes persisted save data.
- When adding a new persistent field, add a current-shape fixture and a missing-field/default test before relying on the field.
- Before a save-version bump, freeze at least one representative old-version fixture and add a migration test from that fixture to the new current shape.

## Compatibility Expectations

Current expectations:

- V1 saves migrate to current V2 in memory.
- V2 saves normalize to safe current V2 data.
- Settings-only saves keep settings but do not count as playable progress.
- Invalid JSON returns safe `null`/`false` behavior and must not clear or replace storage.
- Missing optional fields receive safe defaults.
- Unknown top-level fields do not crash loading.
- Unknown `statistics` fields are preserved under the current policy.

v0.102 adds a downstream-only translation contract:

- The browser runtime still owns `CURRENT_SAVE_VERSION = 2`.
- `npm run test:save-translation-contract` loads the `v0102/` fixtures, normalizes with existing rules, wraps accepted saves in a proposed desktop envelope for proof only, validates content ids against the v0.101 stable-ID snapshot, and writes ignored summary artifacts under `artifacts/save-translation-contract/latest/`.
- The proof command must never write localStorage, overwrite real saves, introduce a desktop save path, or become production persistence.
