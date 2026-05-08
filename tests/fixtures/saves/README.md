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

