# v0.138 Reference-Art Workflow

Status: reference-only workflow. No image generation, downloads, art import, runtime registry mutation, Godot wiring, save change, stable-ID change, or final engine choice is authorized.

## Purpose

v0.138 prepares the external GPT image-generation workflow for the first four reference-only style frames. It creates a local ignored workspace, source metadata expectations, validation, contact-sheet tooling, review-pack tooling, and copy-ready briefs.

## Workspace

Run:

```powershell
npm run art:reference:init
```

This creates the ignored local workspace:

- `artifacts/art-review/v0138/candidates/`
- `artifacts/art-review/v0138/contact-sheets/`
- `artifacts/art-review/v0138/metadata/`
- `artifacts/art-review/v0138/review-notes/`
- `artifacts/art-review/v0138/README.md`

The workspace is ignored by git. It is for manually placed, reference-only candidate images and review outputs.

## External Generation Flow

1. Open one copy-ready brief from `docs/art-prompts/`.
2. Paste its prompt into an external image-generation tool.
3. Do not download or place any generated image unless Emmanuel chooses to review it.
4. If a candidate is placed locally, put it under `artifacts/art-review/v0138/candidates/`.
5. Create one metadata JSON file under `artifacts/art-review/v0138/metadata/`.
6. Keep `runtimeIntegrationStatus` exactly `forbidden`.
7. Run validation and contact-sheet tooling.

## Commands

```powershell
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
```

Empty candidate folders produce pending status instead of failure.

## Forbidden Actions

- Do not generate images as part of v0.138 implementation.
- Do not import art into Godot or the browser runtime.
- Do not wire image paths into runtime registries, save data, stable IDs, public assets, or build scripts.
- Do not mark any candidate final, approved for production, or runtime-integrated.
- Do not start v0.139 automatically.

## Green Meaning

v0.138 is green when the tracked tooling and docs are in place, the ignored workspace initializes, empty-workspace validation reports pending cleanly, contact-sheet tooling reports pending cleanly, review-pack tooling reports pending cleanly, and all required repository verification commands pass.
