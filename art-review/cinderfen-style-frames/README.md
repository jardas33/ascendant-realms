# Cinderfen Style-Frame Review

This directory is the non-runtime intake area for future Cinderfen style-frame candidates.

It exists to support source/license review, visual-fit review, Cinderfen pillar review, and screenshot QA planning before any runtime art work begins. It does not authorize runtime asset replacement.

## Folder Structure

```text
art-review/cinderfen-style-frames/
  inbox/      received candidate files that still need metadata and review
  metadata/   source/license forms, JSON records, and review manifests
  reviewed/   candidates that have completed a non-runtime review stage
  rejected/   candidates rejected for source, license, originality, format, or readability reasons
```

## What Belongs Here

- Metadata templates.
- Candidate metadata records.
- Review manifests.
- Human review notes.
- Explicitly approved future candidate images, only when source/license metadata is present or being completed in the same review.

## What Does Not Belong Here

- Runtime art.
- Files referenced by `src/game/assets/AssetKeys.ts`.
- Files added to `src/game/assets/visualAssetManifest.ts` as runtime assets.
- Scraped images, franchise screenshots, copied protected references, or unknown-source files marked safe.
- Large binaries unless Emmanuel explicitly approves committing them for review.

## Intake Rule

Every future image candidate needs a metadata record before it can advance beyond inbox. Unknown source means not production-safe.
