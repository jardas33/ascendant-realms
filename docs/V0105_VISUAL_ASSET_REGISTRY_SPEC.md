# v0.105 Visual Asset Registry Spec

Status: tooling/schema/reference registry only. No images are generated, imported, or approved for runtime by v0.105.

## Purpose

v0.105 promotes the v0.88 vertical-slice asset plan into a committed deterministic registry:

- `src/game/art/visual-asset-registry.schema.json`
- `src/game/art/visual-asset-registry.json`

The registry is an art-intake source of truth for future candidate review. It does not replace the existing runtime visual asset manifest and it is not imported by runtime code.

## Source

The registry is seeded from `docs/V088_VERTICAL_SLICE_ASSET_MANIFEST.json`.

All v0.88 asset IDs remain present. Entries are ordered by `assetId` so contact sheets, reports, and validation output remain deterministic.

## Preserved Fields

Each entry preserves or extends the v0.88 planning fields:

- `assetId`
- `category`
- `faction`
- `runtimeSlot`
- `conceptStage`
- `reviewStatus`
- `source`
- `license`
- `generatedBy`
- `promptVersion`
- `visualConsistencyNotes`
- `approvalStatus`
- `integrationReadiness`
- `replacementHistory`

v0.105 adds review-state and workspace fields:

- `reviewState`
- `promptTemplateReference`
- `negativePromptReference`
- `sourceLicensePosture`
- `protectedIpPosture`
- `reviewWorkspace`

## Registry Rules

- `generatedAssetsIncluded` must be `false`.
- `runtimeIntegrationApproved` must be `false`.
- `status` must remain `reference-registry-only`.
- Registry `runtimeSlot` values must remain `not-runtime`.
- Workspace paths must stay under `artifacts/art-review/`.
- Workspace paths must not point at `public/assets/` or `src/game/assets/`.
- Current entries start as `not-created`, `not-approved`, and `not-ready-reference-only`.

## Validation

`npm run art:review:validate` checks:

- schema JSON parses;
- registry JSON parses;
- v0.88 asset IDs are preserved;
- asset IDs are unique;
- asset ordering is deterministic;
- required registry fields are present;
- registry entries do not claim generated assets or runtime approval.

`npm run validate:content` remains the runtime/content validation gate. The v0.105 registry is intentionally separate from runtime asset loading.
