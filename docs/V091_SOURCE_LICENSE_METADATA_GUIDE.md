# v0.9.1 Source And License Metadata Guide

Date: 2026-05-10  
Status: metadata guide for future non-runtime Cinderfen style-frame candidates. No image files are included or approved by this guide.

## Purpose

Every future Cinderfen style-frame candidate needs source/license metadata before it can be committed, reviewed, compared, or proposed for runtime testing. This guide explains the metadata fields in:

- `art-review/cinderfen-style-frames/metadata/CANDIDATE_METADATA_TEMPLATE.md`
- `art-review/cinderfen-style-frames/metadata/CANDIDATE_METADATA_TEMPLATE.json`

The metadata is deliberately conservative. A candidate can look perfect and still be blocked if its source, license, originality, or usage rights are unclear.

## Required Metadata Fields

### candidateId

Stable lowercase id for the candidate. Use descriptive ids such as `cinderfen_terrain_ash_glass_style_frame_01` or `cinder_shrine_neutral_waystone_01`.

### title

Human-readable candidate title.

### fileName

The exact file name of the candidate image when one exists.

### filePath

The non-runtime review path, normally under `art-review/cinderfen-style-frames/inbox/`, `reviewed/`, or `rejected/`. Do not use runtime paths such as `public/assets/final/`.

### submittedBy

Who provided the candidate to the project. If Emmanuel provides it, record `Emmanuel`.

### createdBy

The human artist, tool, generator, studio, or collaborator that created the candidate.

### sourceType

Use a controlled value:

- `user-generated`
- `user-owned`
- `commissioned`
- `handmade`
- `licensed-original`
- `internal-template`
- `unknown`

`unknown` blocks production approval and runtime testing.

### toolOrSoftware

Record the tool, software, generator, art package, or manual process. Include version/model/provider when known.

### generationPrompt

Required for generated candidates. Preserve the full prompt that produced the image. If the image is hand-made, describe the manual creation process instead.

### generationNegativePrompt

Record the negative prompt if generation used one. If none, write `none`.

### dateCreated

Use `YYYY-MM-DD` when known.

### dateSubmitted

Use `YYYY-MM-DD` for the date the candidate entered the project review process.

### licenseStatus

Use a controlled value:

- `user-owned`
- `commissioned-owned`
- `licensed-commercial`
- `licensed-noncommercial`
- `internal-template`
- `unknown`
- `blocked`

`unknown` and `blocked` are never production-safe.

### usagePermission

Plain-language statement of what Ascendant Realms may do with the candidate. Examples:

- `Non-runtime review only.`
- `Reference-only art direction discussion.`
- `Prototype runtime test allowed after validation.`
- `Commercial production use allowed under attached license.`

### commercialUseAllowed

Boolean. Use `false` unless explicit permission exists.

### derivativeUseAllowed

Boolean. Use `false` unless explicit permission exists to modify, crop, redraw, composite, or derive new work from the candidate.

### attributionRequired

Boolean. If true, record the required attribution text in `notes`.

### referenceSources

List concept references, source links, artist briefs, or source files. Do not include protected game screenshots or scraped images as asset sources.

### protectedIpRisk

Use a controlled value:

- `low`
- `medium`
- `high`
- `unknown`

`high` and `unknown` block runtime-test approval.

### originalityNotes

Explain how the candidate avoids copied franchise expression. Mention original silhouettes, symbols, materials, layout, and palette decisions.

### intendedUse

Examples:

- `style-frame-reference`
- `terrain-material-reference`
- `shrine-landmark-reference`
- `ashen-architecture-reference`
- `future-runtime-test-candidate`

### visualFamily

For this goal, usually `cinderfen`.

### assetCategory

Examples:

- `terrain-style-frame`
- `causeway-material`
- `cinder-shrine-landmark`
- `cinder-shrine-state-sheet`
- `ashen-stronghold`
- `ashen-barracks`
- `ashen-watchtower`
- `environmental-prop-sheet`
- `minimap-readability-reference`
- `ui-background-mood-frame`

### relatedPromptPackSection

Name the prompt section from `docs/V09_CINDERFEN_STYLE_FRAME_PROMPT_PACK.md`.

### relatedSpecDoc

Reference the closest v0.9 spec doc, such as:

- `docs/V09_CINDERFEN_TERRAIN_MATERIAL_SHEET_SPEC.md`
- `docs/V09_CINDER_SHRINE_LANDMARK_SPEC.md`
- `docs/V09_ASHEN_OUTPOST_ARCHITECTURE_SPEC.md`
- `docs/V09_UNIT_BUILDING_SCALE_REFERENCE.md`
- `docs/V09_CINDERFEN_VISUAL_PILLARS.md`

### replacementTarget

Use `none-runtime` for style frames. If the candidate is meant for later runtime testing, name only the future target, such as `cinder-shrine-landmark`, `cinderfen-causeway-material`, or `ashen-stronghold`. This field does not authorize replacement.

### scaleNotes

Record whether the image is a reference frame, sprite candidate, material sheet, icon sheet, or architecture sheet. For sprite-like candidates, note intended world height or current render-size comparison if known.

### readabilityNotes

Record road clarity, shrine visibility, unit contrast, fog impact, minimap implications, mobile/tablet concerns, and UI compatibility.

### reviewer

Who performed the review.

### reviewDate

Use `YYYY-MM-DD`.

### reviewStatus

Use a controlled value:

- `inbox`
- `metadata-complete`
- `reference-only`
- `candidate`
- `approved-for-prototype`
- `approved-for-runtime-test`
- `approved-for-production`
- `rejected`
- `template`

v0.9.1 should not mark actual candidates `approved-for-production`.

### productionApprovalStatus

Use:

- `not-approved`
- `blocked`
- `not-applicable`
- `future-review-required`
- `approved`

Only a later explicit production approval process may use `approved`.

### reasonForRejection

Required when `reviewStatus` is `rejected`.

### notes

Freeform review notes, attribution text, license links, reviewer concerns, and next steps.

## Approval Rules

- Missing `candidateId` blocks validation.
- Missing `sourceType` blocks validation.
- Unknown source blocks production approval.
- Unknown license blocks production approval.
- High or unknown protected-IP risk blocks runtime-test approval.
- Runtime-test approval requires complete source/license fields.
- Rejected candidates need a rejection reason.
- Missing related spec doc should be fixed before candidate comparison.
- Candidate image existence is optional while status is draft/template, but submitted candidates should point to a review file path.

## v0.9.1 Decision

Metadata can advance the project only by making future decisions safer. It does not approve art, add runtime assets, or replace visuals by itself.
