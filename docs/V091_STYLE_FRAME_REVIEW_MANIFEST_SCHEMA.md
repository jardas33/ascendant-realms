# v0.9.1 Style-Frame Review Manifest Schema

Date: 2026-05-10  
Status: schema for future non-runtime Cinderfen style-frame candidate review. No candidate entries or runtime manifest entries are added by this document.

## Purpose

The style-frame review manifest is a future non-runtime catalogue for Cinderfen candidate images and their review decisions. It is separate from `src/game/assets/visualAssetManifest.ts`.

The runtime visual asset manifest answers: "What does the game know how to load or reference?"  
The style-frame review manifest answers: "Which non-runtime visual candidates have been submitted, reviewed, rejected, or approved for a later proposal?"

This schema supports future candidate comparison without turning review files into game assets.

## Location

Preferred future manifest path:

```text
art-review/cinderfen-style-frames/metadata/style-frame-review-manifest.json
```

Type definitions live in:

```text
tools/art-intake/StyleFrameReviewManifestTypes.ts
```

This location is intentionally tooling-only. Runtime code should not import it.

## Manifest Shape

```json
{
  "schemaVersion": 1,
  "updatedAt": "YYYY-MM-DD",
  "scope": "cinderfen-style-frames",
  "notes": "Non-runtime review manifest. Not a runtime asset manifest.",
  "candidates": []
}
```

Do not add candidate entries until actual candidate files or metadata records exist.

## Candidate Entry Fields

### candidateId

Stable id matching the candidate metadata file.

### metadataPath

Path to the source/license metadata record, normally under:

```text
art-review/cinderfen-style-frames/metadata/
```

### filePath

Path to the non-runtime candidate image or reference file. This must not be a runtime path.

### category

Controlled visual category:

- `terrain-style-frame`
- `causeway-material`
- `cinder-shrine-landmark`
- `cinder-shrine-state-sheet`
- `ashen-architecture`
- `ashen-stronghold`
- `ashen-barracks`
- `ashen-watchtower`
- `environmental-prop-sheet`
- `minimap-readability-reference`
- `ui-background-mood-frame`
- `other`

### reviewStage

Controlled review stage:

- `inbox`
- `metadata-complete`
- `reference-only`
- `candidate`
- `approved-for-prototype`
- `approved-for-runtime-test`
- `approved-for-production`
- `rejected`

v0.9.1 should not mark real candidates `approved-for-production`.

### sourceStatus

Controlled source status:

- `complete`
- `partial`
- `unknown`
- `blocked`

Unknown or blocked source status prevents runtime-test and production approval.

### licenseStatus

Controlled license status:

- `user-owned`
- `commissioned-owned`
- `licensed-commercial`
- `licensed-noncommercial`
- `internal-template`
- `unknown`
- `blocked`

Unknown or blocked license status prevents runtime-test and production approval.

### ipRisk

Controlled protected-IP risk:

- `low`
- `medium`
- `high`
- `unknown`

High or unknown IP risk prevents runtime-test and production approval.

### visualFitScore

Integer 1 to 5. Measures fit with Cinderfen identity, not technical readiness.

### readabilityScore

Integer 1 to 5. Measures likely battlefield readability from current browser prototype cameras.

### scaleFitScore

Integer 1 to 5. Measures fit with v0.9 unit/building/capture-site scale rules.

### cinderfenPillarFit

Object mapping v0.9 pillar ids to a status:

- `pass`
- `concern`
- `fail`
- `not-reviewed`

Expected pillar ids:

- `roads-read-first`
- `shrines-glow-second`
- `units-above-terrain-noise`
- `wetland-dangerous-not-messy`
- `ashen-architecture-angular-scorched-ritualized`
- `player-structures-grounded-readable`
- `fog-frames-decisions`
- `ui-labels-support-not-carry`

### screenshotTargets

List of screenshot QA targets that should be reviewed before runtime testing. Examples:

- `cinderfen-crossing-desktop.png`
- `cinderfen-crossing-tablet.png`
- `cinderfen-crossing-shrine-desktop.png`
- `cinderfen-crossing-pressure-desktop.png`
- `cinderfen-watch-desktop.png`
- `cinderfen-watch-pressure-desktop.png`
- `results-victory-desktop.png`
- `results-defeat-desktop.png`
- `inventory-desktop.png`
- `asset-gallery-desktop.png`

### replacementTargets

List of possible future replacement targets. Use empty list for reference-only style frames.

Examples:

- `cinder-shrine-landmark`
- `cinderfen-causeway-material`
- `ashen-stronghold`

This field does not authorize replacement.

### allowedNextStep

Controlled next step:

- `complete-metadata`
- `source-license-review`
- `visual-review`
- `screenshot-comparison`
- `runtime-test-proposal`
- `keep-reference-only`
- `reject`
- `none`

### notes

Reviewer notes, concerns, links to comparison docs, or reasons for stage limits.

## Approval Guardrails

- This review manifest is not the runtime visual asset manifest.
- It should not be imported by runtime code.
- It should not mark unknown-source files production-safe.
- `approved-for-runtime-test` still requires a separate implementation goal.
- `approved-for-production` is reserved for a later production approval process.
- `filePath` should remain under `art-review/` unless a later scoped runtime import goal has already happened.
- Empty candidate lists are valid.

## Example Empty Manifest

```json
{
  "schemaVersion": 1,
  "updatedAt": "2026-05-10",
  "scope": "cinderfen-style-frames",
  "notes": "No candidate style frames are currently present. This manifest is ready for future non-runtime review entries.",
  "candidates": []
}
```

## v0.9.1 Decision

The review manifest schema prepares future catalogue work only. It does not add candidate entries, runtime art, manifest runtime entries, gameplay changes, or production approval.
