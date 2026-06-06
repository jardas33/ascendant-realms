# v0.138 Emmanuel Reference-Art Guide

Status: one-click guide for reference-only art review preparation. No runtime art integration is approved.

## Start The Workspace

From the repository root:

```powershell
npm run art:reference:init
```

This creates the local ignored folder:

`artifacts/art-review/v0138/`

## Generate Outside The Repo

Use the four prompt docs:

- `docs/art-prompts/V0138_01_SALTO_2_5D_ENVIRONMENT_STYLE_FRAME.md`
- `docs/art-prompts/V0138_02_HUD_STYLE_FRAME.md`
- `docs/art-prompts/V0138_03_ASTER_HERO_SILHOUETTE_SHEET.md`
- `docs/art-prompts/V0138_04_WORKER_SILHOUETTE_SHEET.md`

Copy one prompt into the external image-generation tool. v0.138 itself does not generate images.

## Place A Candidate For Review

If you want to review a candidate:

1. Put the image in `artifacts/art-review/v0138/candidates/`.
2. Add a matching JSON metadata file in `artifacts/art-review/v0138/metadata/`.
3. Use `docs/V0138_REFERENCE_METADATA_SCHEMA.md` as the template.
4. Keep `runtimeIntegrationStatus` exactly `forbidden`.

## Build The Local Review Pack

Run:

```powershell
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
```

If no candidate exists yet, the tools report pending status and still create useful local reports.

## Review Questions

- Does the image feel like original Barrosan highland fantasy?
- Does it avoid protected-game lookalikes?
- Does it improve tactical readability for a modern top-down RTS/RPG?
- Does it avoid a generic mobile-game or developer-dashboard look?
- Does it stay reference-only with no runtime approval?

## Stop Conditions

Stop and ask for a new explicit goal before any runtime import, Godot wiring, browser runtime change, save/stable-ID change, final art selection, or v0.139 work.
