# v0.9 Future Cinderfen Manifest Templates

Date: 2026-05-10  
Status: documentation templates only. These entries were not added to `src/game/assets/visualAssetManifest.ts`, no files were created, and no placeholders are marked as existing.

## Purpose

This document prepares conservative visual asset manifest templates for future Cinderfen style-frame and replacement work. The templates show how later assets should be described after they exist and after source/license metadata is available.

These are not runtime entries. They do not approve generated assets, downloaded images, unknown-source files, or placeholder paths.

## Naming Convention

Recommended id pattern:

```text
cinderfen_<asset_family>_<asset_name>_<state_or_variant>_<status>
```

Examples:

- `cinderfen_terrain_style_frame_reference`
- `cinderfen_causeway_material_candidate`
- `cinderfen_cinder_shrine_neutral_candidate`
- `ashen_stronghold_concept_reference`

Recommended placeholder file path format:

```text
docs/asset-review/cinderfen/<asset-family>/<asset-name>.<ext>
```

Do not create these paths during v0.9. Future runtime files, if ever approved, should use a separate implementation plan and should not be placed in runtime folders until source/license, manifest validation, and screenshot QA are complete.

## Shared Template Policy

For all future Cinderfen candidate/reference entries:

- `allowedInProduction` must stay `false` until evidence proves source/license and production review.
- `needsReview` should be `true` for every generated, candidate, external-reference, unknown-source, or unproven asset.
- `usage` should be `docs-reference`, `manual-reference`, or `unused` until runtime integration is approved.
- `currentStatus` should be `reference` for style frames and `candidate` for concrete replacement candidates.
- `sourceType` and `licenseStatus` must reflect evidence, not hope.
- `sourceReviewNotes` should name the prompt/source, tool/artist/vendor, license, reviewer, review date, and known restrictions.

## Template 1 - Cinderfen Terrain Style-Frame Reference

```ts
{
  id: "cinderfen_terrain_style_frame_reference",
  filePath: "docs/asset-review/cinderfen/terrain/cinderfen_terrain_style_frame_reference.png",
  category: "reference",
  displayName: "Cinderfen Terrain Style-Frame Reference",
  currentStatus: "reference",
  sourceType: "generated",
  licenseStatus: "generated-review-needed",
  reviewStatus: "generated-review-needed",
  usage: "docs-reference",
  usedBy: ["docs/V09_CINDERFEN_STYLE_FRAME_PROMPT_PACK.md"],
  visualFamily: "cinderfen terrain",
  scaleClass: "reference",
  silhouetteReadability: "unknown",
  styleConsistency: "unknown",
  replacementPriority: "critical",
  notes: "Reference-only style frame for Cinderfen ash-glass wetland, causeways, water, reeds, ruins, fog, and ember accents. Not a runtime texture.",
  sourceReviewNotes: "Example only. Fill with tool/artist/source, exact prompt, date, license terms, reviewer, and review outcome before adding a real entry.",
  allowedInProduction: false,
  needsReview: true,
  screenshotQaTargets: [
    "cinderfen-crossing-desktop.png",
    "cinderfen-crossing-tablet.png",
    "cinderfen-watch-desktop.png"
  ]
}
```

## Template 2 - Cinderfen Road / Causeway Material

```ts
{
  id: "cinderfen_causeway_material_candidate",
  filePath: "docs/asset-review/cinderfen/causeway/cinderfen_causeway_material_candidate.png",
  category: "terrain",
  displayName: "Cinderfen Causeway Material Candidate",
  currentStatus: "candidate",
  sourceType: "generated",
  licenseStatus: "generated-review-needed",
  reviewStatus: "generated-review-needed",
  usage: "unused",
  usedBy: ["docs/V09_CINDERFEN_TERRAIN_MATERIAL_SHEET_SPEC.md"],
  visualFamily: "cinderfen causeway",
  scaleClass: "terrain",
  silhouetteReadability: "unknown",
  styleConsistency: "unknown",
  replacementPriority: "critical",
  notes: "Candidate blackened raised road/causeway material. Must not be wired into runtime until path readability, source/license, and screenshot QA pass.",
  sourceReviewNotes: "Example only. Include generation prompt/source, license evidence, tile/world-size intent, reviewer, and whether it is reference-only or candidate production direction.",
  allowedInProduction: false,
  needsReview: true,
  screenshotQaTargets: [
    "cinderfen-crossing-desktop.png",
    "cinderfen-crossing-pressure-desktop.png",
    "cinderfen-watch-desktop.png"
  ]
}
```

## Template 3 - Cinder Shrine Neutral

```ts
{
  id: "cinderfen_cinder_shrine_neutral_candidate",
  filePath: "docs/asset-review/cinderfen/cinder-shrine/cinderfen_cinder_shrine_neutral_candidate.png",
  category: "capture-site-icon",
  displayName: "Cinder Shrine Neutral Candidate",
  currentStatus: "candidate",
  sourceType: "generated",
  licenseStatus: "generated-review-needed",
  reviewStatus: "generated-review-needed",
  usage: "unused",
  usedBy: ["docs/V09_CINDER_SHRINE_LANDMARK_SPEC.md"],
  visualFamily: "cinderfen shrine",
  scaleClass: "capture-site",
  intendedWorldHeightPx: 72,
  currentRenderHeightPx: 72,
  silhouetteReadability: "unknown",
  styleConsistency: "unknown",
  replacementPriority: "high",
  notes: "Neutral Cinder Shrine landmark candidate. Must remain visible inside the current capture ring without implying ownership.",
  sourceReviewNotes: "Example only. Record prompt/tool/artist, transparent-background status, license terms, state-sheet relation, reviewer, and screenshot review notes.",
  allowedInProduction: false,
  needsReview: true,
  screenshotQaTargets: [
    "cinderfen-crossing-shrine-desktop.png",
    "cinderfen-crossing-tablet.png"
  ]
}
```

## Template 4 - Cinder Shrine Player-Owned

```ts
{
  id: "cinderfen_cinder_shrine_player_owned_candidate",
  filePath: "docs/asset-review/cinderfen/cinder-shrine/cinderfen_cinder_shrine_player_owned_candidate.png",
  category: "capture-site-icon",
  displayName: "Cinder Shrine Player-Owned Candidate",
  currentStatus: "candidate",
  sourceType: "generated",
  licenseStatus: "generated-review-needed",
  reviewStatus: "generated-review-needed",
  usage: "unused",
  usedBy: ["docs/V09_CINDER_SHRINE_LANDMARK_SPEC.md"],
  visualFamily: "cinderfen shrine ownership",
  scaleClass: "capture-site",
  intendedWorldHeightPx: 72,
  currentRenderHeightPx: 72,
  silhouetteReadability: "unknown",
  styleConsistency: "unknown",
  replacementPriority: "high",
  notes: "Player-owned shrine state candidate. Must keep the same silhouette as neutral and support current green ownership ring readability.",
  sourceReviewNotes: "Example only. Record state-sheet source, prompt, license, reviewer, and whether ownership can be read without label text.",
  allowedInProduction: false,
  needsReview: true,
  screenshotQaTargets: [
    "cinderfen-crossing-shrine-desktop.png",
    "cinderfen-crossing-pressure-desktop.png"
  ]
}
```

## Template 5 - Cinder Shrine Enemy-Owned

```ts
{
  id: "cinderfen_cinder_shrine_enemy_owned_candidate",
  filePath: "docs/asset-review/cinderfen/cinder-shrine/cinderfen_cinder_shrine_enemy_owned_candidate.png",
  category: "capture-site-icon",
  displayName: "Cinder Shrine Enemy-Owned Candidate",
  currentStatus: "candidate",
  sourceType: "generated",
  licenseStatus: "generated-review-needed",
  reviewStatus: "generated-review-needed",
  usage: "unused",
  usedBy: ["docs/V09_CINDER_SHRINE_LANDMARK_SPEC.md"],
  visualFamily: "cinderfen shrine ownership",
  scaleClass: "capture-site",
  intendedWorldHeightPx: 72,
  currentRenderHeightPx: 72,
  silhouetteReadability: "unknown",
  styleConsistency: "unknown",
  replacementPriority: "high",
  notes: "Enemy-owned shrine state candidate. Must keep the same silhouette as neutral and support current red ownership ring readability without looking like an Ashen building.",
  sourceReviewNotes: "Example only. Record state-sheet source, prompt, license, reviewer, and protected-IP check notes.",
  allowedInProduction: false,
  needsReview: true,
  screenshotQaTargets: [
    "cinderfen-crossing-shrine-desktop.png",
    "cinderfen-crossing-pressure-desktop.png"
  ]
}
```

## Template 6 - Ashen Stronghold Concept

```ts
{
  id: "ashen_stronghold_concept_reference",
  filePath: "docs/asset-review/cinderfen/ashen-architecture/ashen_stronghold_concept_reference.png",
  category: "building-concept",
  displayName: "Ashen Stronghold Concept Reference",
  currentStatus: "reference",
  sourceType: "generated",
  licenseStatus: "generated-review-needed",
  reviewStatus: "generated-review-needed",
  usage: "docs-reference",
  usedBy: ["docs/V09_ASHEN_OUTPOST_ARCHITECTURE_SPEC.md"],
  visualFamily: "Ashen outpost stronghold",
  scaleClass: "building-large",
  intendedWorldHeightPx: 124.96,
  currentRenderHeightPx: 124.96,
  silhouetteReadability: "unknown",
  styleConsistency: "unknown",
  replacementPriority: "high",
  notes: "Reference concept for future enemy stronghold identity. Not a runtime replacement for enemy_stronghold_building_sprite.",
  sourceReviewNotes: "Example only. Include prompt/tool/artist/source, license, IP review, footprint notes, reviewer, and screenshot review notes before adding a real entry.",
  allowedInProduction: false,
  needsReview: true,
  screenshotQaTargets: [
    "cinderfen-watch-desktop.png",
    "cinderfen-watch-pressure-desktop.png"
  ]
}
```

## Template 7 - Ashen Barracks Concept

```ts
{
  id: "ashen_barracks_concept_reference",
  filePath: "docs/asset-review/cinderfen/ashen-architecture/ashen_barracks_concept_reference.png",
  category: "building-concept",
  displayName: "Ashen Barracks Concept Reference",
  currentStatus: "reference",
  sourceType: "generated",
  licenseStatus: "generated-review-needed",
  reviewStatus: "generated-review-needed",
  usage: "docs-reference",
  usedBy: ["docs/V09_ASHEN_OUTPOST_ARCHITECTURE_SPEC.md"],
  visualFamily: "Ashen outpost production",
  scaleClass: "building-medium",
  intendedWorldHeightPx: 90.88,
  currentRenderHeightPx: 90.88,
  silhouetteReadability: "unknown",
  styleConsistency: "unknown",
  replacementPriority: "medium",
  notes: "Reference concept for future enemy barracks/war-camp production identity. Not a runtime replacement.",
  sourceReviewNotes: "Example only. Record source/prompt/license, production-readability review, footprint notes, reviewer, and whether visible props could be confused with units.",
  allowedInProduction: false,
  needsReview: true,
  screenshotQaTargets: [
    "cinderfen-watch-desktop.png",
    "cinderfen-watch-pressure-desktop.png"
  ]
}
```

## Template 8 - Ashen Watchtower Concept

```ts
{
  id: "ashen_watchtower_concept_reference",
  filePath: "docs/asset-review/cinderfen/ashen-architecture/ashen_watchtower_concept_reference.png",
  category: "building-concept",
  displayName: "Ashen Watchtower Concept Reference",
  currentStatus: "reference",
  sourceType: "generated",
  licenseStatus: "generated-review-needed",
  reviewStatus: "generated-review-needed",
  usage: "docs-reference",
  usedBy: ["docs/V09_ASHEN_OUTPOST_ARCHITECTURE_SPEC.md"],
  visualFamily: "Ashen outpost tower",
  scaleClass: "building-small",
  intendedWorldHeightPx: 102.24,
  currentRenderHeightPx: 102.24,
  silhouetteReadability: "unknown",
  styleConsistency: "unknown",
  replacementPriority: "medium",
  notes: "Reference concept for a future Ashen watchtower. Current game has no dedicated enemy tower replacement entry; this is planning only.",
  sourceReviewNotes: "Example only. Record source/prompt/license, tower-threat readability review, and confirmation that it does not resemble a capture site.",
  allowedInProduction: false,
  needsReview: true,
  screenshotQaTargets: [
    "cinderfen-watch-desktop.png",
    "cinderfen-watch-pressure-desktop.png"
  ]
}
```

## Template 9 - Cinderfen Prop Sheet

```ts
{
  id: "cinderfen_environmental_prop_sheet_reference",
  filePath: "docs/asset-review/cinderfen/props/cinderfen_environmental_prop_sheet_reference.png",
  category: "terrain",
  displayName: "Cinderfen Environmental Prop Sheet Reference",
  currentStatus: "reference",
  sourceType: "generated",
  licenseStatus: "generated-review-needed",
  reviewStatus: "generated-review-needed",
  usage: "docs-reference",
  usedBy: ["docs/V09_CINDERFEN_STYLE_FRAME_PROMPT_PACK.md"],
  visualFamily: "cinderfen props",
  scaleClass: "terrain",
  silhouetteReadability: "unknown",
  styleConsistency: "unknown",
  replacementPriority: "medium",
  notes: "Reference sheet for dead reeds, ash stones, ruins, road markers, and wetland dressing. Not approved for map placement or runtime use.",
  sourceReviewNotes: "Example only. Record source/prompt/license, prop scale notes, reviewer, and confirmation that props do not resemble units, pickups, blockers, or capture sites.",
  allowedInProduction: false,
  needsReview: true,
  screenshotQaTargets: [
    "cinderfen-crossing-desktop.png",
    "cinderfen-watch-desktop.png"
  ]
}
```

## Template 10 - Future Production-Ready Terrain / Material Set

```ts
{
  id: "cinderfen_production_terrain_material_set_candidate",
  filePath: "docs/asset-review/cinderfen/terrain-set/cinderfen_production_terrain_material_set_candidate.json",
  category: "terrain",
  displayName: "Cinderfen Production Terrain Material Set Candidate",
  currentStatus: "candidate",
  sourceType: "unknown",
  licenseStatus: "unknown",
  reviewStatus: "needs-source-proof",
  usage: "unused",
  usedBy: ["docs/V09_CINDERFEN_VISUAL_REPLACEMENT_IMPLEMENTATION_PLAN.md"],
  visualFamily: "cinderfen terrain production set",
  scaleClass: "terrain",
  silhouetteReadability: "unknown",
  styleConsistency: "unknown",
  replacementPriority: "critical",
  notes: "Placeholder structure for a future reviewed terrain/material set covering roads, mud, water, pools, reeds, fog, ruins, and embers. Replace unknown source/license fields only after real proof exists.",
  sourceReviewNotes: "Example only. Do not use owned/licensed/final statuses unless source files, author, rights, license terms, reviewer, and production approval are documented.",
  allowedInProduction: false,
  needsReview: true,
  screenshotQaTargets: [
    "cinderfen-crossing-desktop.png",
    "cinderfen-crossing-tablet.png",
    "cinderfen-crossing-pressure-desktop.png",
    "cinderfen-watch-desktop.png",
    "cinderfen-watch-pressure-desktop.png"
  ]
}
```

## Source Review Notes Examples

Generated candidate:

```text
Generated with <tool/version> on <date> from prompt in docs/V09_CINDERFEN_STYLE_FRAME_PROMPT_PACK.md. No external source images were used. License terms: <terms>. Reviewer <name/date> still needs to confirm original-IP safety, production eligibility, and screenshot readability. Keep allowedInProduction false until approved.
```

Commissioned/manual candidate:

```text
Created by <artist/vendor> under <contract/license> on <date>. Source files stored at <location>. Reviewer <name/date> confirmed allowed uses: <uses>. Production approval still pending screenshot QA and final manifest review.
```

External reference:

```text
External reference only from <source> under <license/terms>. Do not ship, trace, ingest, or adapt directly. Use only as broad conceptual research if license permits. Keep usage docs-reference and allowedInProduction false.
```

## v0.9 Decision

These templates prepare future manifest work but do not add entries to the runtime manifest, do not create files, do not mark placeholders as existing, and do not promote any unknown-source asset.
