# v0.8.2 Manifest Validation Hardening

Date: 2026-05-10  
Scope: source/license validation hardening for the visual asset manifest. This phase does not alter gameplay, save data, runtime visuals, asset files, screenshots, or loader behavior.

## What Changed

Validation now checks the new source-review fields and tightens production-approval rules.

Added validation coverage:

- `reviewStatus` must be one of the allowed values.
- `sourceReviewNotes` must be non-empty.
- Runtime assets cannot use `reviewStatus: "reference-only"` or `reviewStatus: "do-not-ship"`.
- `currentStatus: "final"` requires `allowedInProduction: true`.
- `allowedInProduction: true` requires `licenseStatus: "owned"` or `licenseStatus: "licensed"`.
- `allowedInProduction: true` cannot pair with unknown source/license or `sourceType: "external-reference"`.
- `reviewStatus: "approved-for-production"` requires `allowedInProduction: true`.
- `reviewStatus: "approved-for-production"` requires owned or licensed asset rights.
- `reviewStatus: "approved-for-production"` requires a known non-reference source.
- `reviewStatus: "deprecated"` cannot be runtime.
- `replacementPriority: "critical"` requires notes and source-review notes.

Existing validation remains in place:

- Unique ids.
- Valid category/status/source/license/usage/scale/readability/replacement values.
- Runtime file existence when the CLI provides the file-existence callback.
- Runtime coverage for explicit runtime asset ids.
- Runtime unknown-license assets must set `needsReview: true`.
- Runtime assets cannot use `licenseStatus: "reference-only"` or `licenseStatus: "do-not-ship"`.
- Deprecated assets cannot be runtime.
- Positive scale metadata values.
- Runtime entries require non-empty `usedBy`.

## What Stayed Allowed

The validation still allows honest unknown prototype assets when they are explicitly flagged:

- `licenseStatus: "unknown"`
- `reviewStatus: "needs-source-proof"`
- `needsReview: true`
- `allowedInProduction: false`
- non-empty `sourceReviewNotes`

This is intentional. v0.8.2 should make unknown assets visible and reviewable, not force broad asset moves or fake production approval.

## Test Coverage

Updated `src/game/data/contentValidation.test.ts` to cover:

- No current asset is `approved-for-production`.
- Current unknown-source images remain `needs-source-proof`.
- Owned prototype metadata uses `approved-for-prototype`.
- Invalid `reviewStatus` values are rejected.
- Runtime `reviewStatus: "reference-only"` is rejected.
- Production approval cannot be claimed without `allowedInProduction`, safe rights, known source, and review notes.
- Critical replacement priority requires notes and source-review notes.

## Design Decision

The validation does not infer legal rights from folder names such as `public/assets/final/`. It only trusts explicit metadata.

The validator also does not require new art, asset movement, or source proof that does not currently exist. Missing proof remains represented as review-needed metadata.

## Future Hardening Candidates

Later source/license work could add:

- A structured source-evidence object.
- License URL or license-file references.
- Author or creator fields.
- Generation tool/prompt hashes if generated assets are approved.
- A separate asset-review report generated from the manifest.

Those are deliberately deferred until the current metadata remains useful through screenshot QA expansion.

## v0.105 Follow-Up

v0.105 keeps the runtime visual asset manifest validation unchanged and adds a separate reference-only review registry:

- runtime visual asset metadata remains validated by `npm run validate:content`;
- future v0.88-style candidate review is validated by `npm run art:review:validate`;
- `style-approved` remains non-runtime;
- `runtime-integrated` requires separate future integration proof;
- candidate workspaces stay under ignored `artifacts/art-review/` folders and must not touch `public/assets/` or `src/game/assets/`.
