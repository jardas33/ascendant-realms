# v0.138 Contact-Sheet Tooling

Status: reference-only local review tooling. It must not mutate runtime registries.

## Scripts

| Script | Purpose |
| --- | --- |
| `npm run art:reference:init` | Creates the ignored v0.138 workspace. |
| `npm run art:reference:validate` | Validates candidate metadata and candidate-file posture. |
| `npm run art:reference:contact-sheet` | Generates a local SVG contact sheet and manifest from placed candidates. |
| `npm run art:reference:review-pack` | Generates validation, contact-sheet, checklist, and summary outputs. |

## Outputs

All outputs are local and ignored:

- `artifacts/art-review/v0138/contact-sheets/v0138-reference-contact-sheet.svg`
- `artifacts/art-review/v0138/contact-sheets/v0138-reference-contact-sheet.json`
- `artifacts/art-review/v0138/review-notes/reference-validation.md`
- `artifacts/art-review/v0138/review-notes/reference-validation.json`
- `artifacts/art-review/v0138/review-notes/v0138-reference-review-checklist.md`
- `artifacts/art-review/v0138/review-notes/v0138-reference-review-pack.json`

## Empty Workspace Status

The v0.138 tools are expected to work before any image exists:

- Validation status: `PENDING_V0138_REFERENCE_ART_CANDIDATES`.
- Contact-sheet status: `PENDING_V0138_CONTACT_SHEET_NO_CANDIDATES`.
- Review-pack status: `PENDING_V0138_REFERENCE_REVIEW_PACK_NO_CANDIDATES`.

These pending statuses are not runtime approval and not a reason to import art.

## Candidate Image Handling

The contact sheet can display `.png`, `.jpg`, `.jpeg`, and `.webp` files placed under `artifacts/art-review/v0138/candidates/`. It records SHA-256 hashes for every candidate. PNG and JPEG dimensions are read automatically when possible.

## Guardrails

- The tools do not create generated art.
- The tools do not download assets.
- The tools do not write to `public/`, `src/game/art/`, Godot scenes, save fixtures, stable-ID files, or runtime asset registries.
- The tools do not approve runtime integration.
